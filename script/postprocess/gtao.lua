
_G.GTAONode = {}
GTAONode.Canvae = Canvas.new(1, 1, {format = "rgba8", readable = true, msaa = 0, mipmaps="none"})
GTAONode.Canvae.renderWidth = 1
GTAONode.Canvae.renderHeight = 1
GTAONode.meshquad = _G.MeshQuad.new(1,1, LColor.new(255, 255, 255, 255))

GTAONode.LineWidth = 4;
GTAONode.Color = LColor.new(255,0,0,255);
GTAONode.Threshold = 1
GTAONode.Execute = function(Canva1, normalmap, screendepthmap, eye)
   
    if GTAONode.Canvae.renderWidth ~= Canva1.renderWidth  or GTAONode.Canvae.renderHeight ~= Canva1.renderHeight then
        GTAONode.Canvae = Canvas.new(Canva1.renderWidth , Canva1.renderHeight , {format = "rgba8", readable = true, msaa = 0, mipmaps="none"})
        GTAONode.Canvae.renderWidth = Canva1.renderWidth
        GTAONode.Canvae.renderHeight = Canva1.renderHeight

        GTAONode.meshquad = _G.MeshQuad.new(GTAONode.Canvae.renderWidth, GTAONode.Canvae.renderHeight , LColor.new(255, 255, 255, 255))
    end
    
    love.graphics.setCanvas(GTAONode.Canvae.obj)
    love.graphics.clear()
    GTAONode.meshquad:setCanvas(Canva1)
    GTAONode.meshquad.shader = Shader.GetGTAOShader(normalmap, screendepthmap, GTAONode.Canvae.renderWidth , GTAONode.Canvae.renderHeight, eye )
    GTAONode.meshquad:draw()
    love.graphics.setCanvas()
    return GTAONode.Canvae
end

function Shader.GetGTAOShader(normalmap, screendepthmap, sw, sh, eye)
    if Shader["shader_GTAO"] then
        Shader["shader_GTAO"].setGTAOValue(Shader["shader_GTAO"],  normalmap, screendepthmap, eye)
        return Shader["shader_GTAO"]
    end
    local pixelcode = [[
    uniform sampler2D screendepthmap;
    uniform sampler2D normalmap;
    uniform mat4 projectionViewMatrix;

    uniform mat4 Inverse_ProjectviewMatrix;

    uniform float viewsizew;
    uniform float viewsizeh;
    uniform float GTAOLenght;
    uniform float GTAOBaseAngle;
    uniform float depthlimit;
    uniform vec3 CameraEye;
    // Maps standard viewport UV to screen position.
    vec2 ViewportUVToScreenPos(vec2 ViewportUV)
    {
        return vec2(2 * ViewportUV.x - 1, 1 - 2 * ViewportUV.y);
    }

    vec2 ScreenPosToViewportUV(vec2 ScreenPos)
    {
        return vec2(0.5 + 0.5 * ScreenPos.x, 0.5 - 0.5 * ScreenPos.y);
    }

    
    float rand(vec2 co)
    {
        return fract(sin(dot(co.xy, vec2(12.9898,78.233))) * 43758.5453);
    }   

    vec4 effect( vec4 color, sampler2D tex, vec2 texture_coords, vec2 screen_coords )
    {
       float depth = texture2D(screendepthmap, texture_coords).r;
       //depth = (depth - 0.5) *2;
       vec2 uv = ViewportUVToScreenPos(texture_coords);
       vec4 vpos = vec4(uv.x, uv.y, depth, 1.0);

        vec4 spos = Inverse_ProjectviewMatrix * vpos;
       spos /= spos.w;

        vec2 screenpos0 = vpos.xy + vec2(1 * (1/viewsizew), 0.0);
        vec2 uv0 = vec2((screenpos0.x + 1) * 0.5, 1 - (screenpos0.y + 1) * 0.5);
        vec4 ScenePosition0 = Inverse_ProjectviewMatrix * vec4(screenpos0.x, screenpos0.y, texture2D(screendepthmap, uv0).r, 1);

        ScenePosition0 /= ScenePosition0.w;

        vec2 screenpos1 = vpos.xy - vec2( 0.0, 1 * (1/viewsizeh) );  
        vec2 uv5 = vec2((screenpos1.x + 1) * 0.5, 1 - (screenpos1.y + 1) * 0.5);
        vec4 ScenePosition1 = Inverse_ProjectviewMatrix * vec4(screenpos1.x, screenpos1.y, texture2D(screendepthmap, uv5).r, 1);

        ScenePosition1 /= ScenePosition1.w;

       // vec4 normal = vec4(0,0,0,1);
      //  normal.xyz = normalize(cross(ScenePosition0.xyz - spos.xyz, ScenePosition1.xyz - spos.xyz));

        vec4 normal = texture2D(normalmap, texture_coords);
        normal = normalize(normal * 2.0 - vec4(1.0, 1.0, 1.0, 1.0));

        normal = projectionViewMatrix * normal;//TODO.. 需要切换到切线空间

        vec3 ViewDir = normalize(spos.xyz - CameraEye.xyz);

        vec4 rpos1 = vec4(  0.5     ,       0.5     ,       0.70710678118655,	1);
        vec4 rpos2 = vec4( 1       ,       6.1232339957368e-17     ,       0,	1);

        float offset = GTAOLenght;
        rpos1.xyz = faceforward(rpos1.xyz, ViewDir.xyz, rpos1.xyz) * offset + spos.xyz;

        rpos2.xyz = faceforward(rpos2.xyz, ViewDir.xyz, rpos2.xyz)  * offset+ spos.xyz;

        vec4 vpos1 = projectionViewMatrix *  rpos1;
        vpos1 /= vpos1.w;
        vec4 vpos2 = projectionViewMatrix *  rpos2;
        vpos2 /= vpos2.w;

       float offset_h = 1/viewsizeh;
       float offset_w = 1/viewsizew;

       float depth_1 = texture2D(screendepthmap, ScreenPosToViewportUV(vpos1.xy)).r;
       float depth_2 = texture2D(screendepthmap, ScreenPosToViewportUV(vpos2.xy)).r;

        float T = depthlimit;
        float AnglePos1 = 1 / depth_1  - 1 / depth> T ? 0 : 0.785 - acos(dot(normalize(rpos1.xyz - spos.xyz), normalize(ViewDir.xyz)));

        float AnglePos2 = 1 / depth_2 - 1 / depth > T ? 0 : 0.785 - acos(dot(normalize(rpos2.xyz - spos.xyz), normalize(ViewDir.xyz)));

        vec4 basecolor = texture2D(tex, texture_coords);
        if (AnglePos1 == 0 || AnglePos2 == 0)
        {
           // return basecolor;
        }
        
        float cosweight1 = ((1 - cos(AnglePos1)) + (1 - cos(AnglePos2)));// * (1 - dot(normalize(ViewDir.xyz), normal.xyz));
   
        float weight = clamp(cosweight1, 0.5, 1.0);
        
       basecolor.xyz *=  weight;

       return basecolor;
    }
]]
 
    local vertexcode = [[
    vec4 position( mat4 transform_projection, vec4 vertex_position )
    {
        return transform_projection * vertex_position;
    }
]]

-- log(vertexcode)
-- log(pixelcode)
    local shader =   Shader.new(pixelcode, vertexcode)
    Shader["shader_GTAO"] = shader;
    shader.setGTAOValue = function (shader, normalmap, screendepthmap, eye)
        shader:sendValue('CameraEye', eye:getShaderValue())

        shader:sendValue('normalmap', normalmap.obj)
        if shader:hasUniform("screendepthmap") then
            shader:send("screendepthmap", screendepthmap.obj)
        end

        local viewm = RenderSet.getUseViewMatrix()
        local projectm = RenderSet.getUseProjectMatrix()
        if shader:hasUniform("projectionViewMatrix") then
            local mat = Matrix3D.copy(projectm);
            mat:mulRight(Matrix3D.transpose(Matrix3D.transpose(viewm)))--Todo..
            shader:send("projectionViewMatrix", mat)
        end

        if shader:hasUniform("viewsizew") then
            shader:send("viewsizew", sw)
        end

        if shader:hasUniform("viewsizeh") then
            shader:send("viewsizeh", sh)
        end

        if shader:hasUniform("Inverse_ProjectviewMatrix") then
            local mat = Matrix3D.copy(projectm);
            mat:mulRight(Matrix3D.transpose(Matrix3D.transpose(viewm)))--Todo..
            shader:send("Inverse_ProjectviewMatrix",  Matrix3D.inverse(mat))
        end

        if shader:hasUniform("GTAOLenght") then
            shader:send("GTAOLenght", RenderSet.getHBAORayMatchLength())
        end

        if shader:hasUniform("GTAOBaseAngle") then
            shader:send("GTAOBaseAngle", RenderSet.getHBAOBaseAngle())
        end

        if shader:hasUniform("depthlimit") then
            shader:send("depthlimit", RenderSet.getSSAODepthLimit())
        end
        
    end
    
    shader.setGTAOValue(shader, normalmap, screendepthmap, eye)
    return shader
end