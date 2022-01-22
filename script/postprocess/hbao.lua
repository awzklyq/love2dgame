
_G.HBAONode = {}
HBAONode.Canvae = Canvas.new(1, 1, {format = "rgba8", readable = true, msaa = 0, mipmaps="none"})
HBAONode.Canvae.renderWidth = 1
HBAONode.Canvae.renderHeight = 1
HBAONode.meshquad = _G.MeshQuad.new(1,1, LColor.new(255, 255, 255, 255))

HBAONode.LineWidth = 4;
HBAONode.Color = LColor.new(255,0,0,255);
HBAONode.Threshold = 1
HBAONode.Execute = function(Canva1, screendepthmap)
   
    if HBAONode.Canvae.renderWidth ~= Canva1.renderWidth  or HBAONode.Canvae.renderHeight ~= Canva1.renderHeight then
        HBAONode.Canvae = Canvas.new(Canva1.renderWidth , Canva1.renderHeight , {format = "rgba8", readable = true, msaa = 0, mipmaps="none"})
        HBAONode.Canvae.renderWidth = Canva1.renderWidth
        HBAONode.Canvae.renderHeight = Canva1.renderHeight

        HBAONode.meshquad = _G.MeshQuad.new(HBAONode.Canvae.renderWidth, HBAONode.Canvae.renderHeight , LColor.new(255, 255, 255, 255))
    end
    
    love.graphics.setCanvas(HBAONode.Canvae.obj)
    love.graphics.clear()
    HBAONode.meshquad:setCanvas(Canva1)
    HBAONode.meshquad.shader = Shader.GetHBAOShader(screendepthmap, HBAONode.Canvae.renderWidth , HBAONode.Canvae.renderHeight )
    HBAONode.meshquad:draw()
    love.graphics.setCanvas()
    return HBAONode.Canvae
end

function Shader.GetHBAOShader(screendepthmap, sw, sh)
    if Shader["shader_HBAO"] then
        Shader["shader_HBAO"].setHBAOValue(Shader["shader_HBAO"],  screendepthmap)
        return Shader["shader_HBAO"]
    end
    local pixelcode = [[
    uniform sampler2D screendepthmap;

    uniform mat4 projectionViewMatrix;

    uniform mat4 Inverse_ProjectviewMatrix;

    uniform float viewsizew;
    uniform float viewsizeh;
    uniform float HBAOLenght;
    uniform float HBAOBaseAngle;
    uniform float depthlimit;
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

       float offset_h = 1/viewsizeh;
       float offset_w = 1/viewsizew;
       float rand1 = rand(texture_coords) * 0.785;
       float rand2 = rand(texture_coords + vec2(0, offset_h * 2))* 0.785;
       float rand3 = rand(texture_coords + vec2(offset_w * 2, offset_h * 2))* 0.785;
       float rand4 = rand(texture_coords + vec2(offset_w * 2, 0))* 0.785;

        vec4 rpos1 = vec4(cos(rand1)  ,sin(rand1), 0, 0) * HBAOLenght;
        vec4 rpos2 = vec4(-cos(rand2)  ,sin(rand2), 0, 0) * HBAOLenght;
        vec4 rpos3 = vec4(-cos(rand3)  ,-sin(rand3), 0, 0) * HBAOLenght;
        vec4 rpos4 = vec4(cos(rand4)  ,-sin(rand4), 0, 0) * HBAOLenght;

        rpos1 = spos + rpos1;
        rpos2 = spos + rpos2;
        rpos3 = spos + rpos3;
        rpos4 = spos + rpos4;

        vec2 screenpos0 = vpos.xy + vec2(1 * (1/viewsizew), 0.0);
        vec2 uv0 = vec2((screenpos0.x + 1) * 0.5, 1 - (screenpos0.y + 1) * 0.5);
        vec4 ScenePosition0 = Inverse_ProjectviewMatrix * vec4(screenpos0.x, screenpos0.y, texture2D(screendepthmap, uv0).r, 1);

        ScenePosition0 /= ScenePosition0.w;

        vec2 screenpos1 = vpos.xy - vec2( 0.0, 1 * (1/viewsizeh) );  
        vec2 uv5 = vec2((screenpos1.x + 1) * 0.5, 1 - (screenpos1.y + 1) * 0.5);
        vec4 ScenePosition1 = Inverse_ProjectviewMatrix * vec4(screenpos1.x, screenpos1.y, texture2D(screendepthmap, uv5).r, 1);

        ScenePosition1 /= ScenePosition1.w;

        vec4 normal = vec4(0,0,0,1);
        normal.xyz = normalize(cross(ScenePosition0.xyz - spos.xyz, ScenePosition1.xyz - spos.xyz));

        vec4 vpos1 = projectionViewMatrix *  rpos1;
        vpos1 /= vpos1.w;
        vec4 vpos2 = projectionViewMatrix *  rpos2;
        vpos2 /= vpos2.w;
        vec4 vpos3 = projectionViewMatrix *  rpos3;
        vpos3 /= vpos3.w;
        vec4 vpos4 = projectionViewMatrix *  rpos4;
        vpos4 /= vpos4.w;

        vec2 uv1 = ScreenPosToViewportUV(vpos1.xy);
        vec2 uv2 = ScreenPosToViewportUV(vpos2.xy);
        vec2 uv3 = ScreenPosToViewportUV(vpos3.xy);
        vec2 uv4 = ScreenPosToViewportUV(vpos4.xy);
        float depth1 = texture2D(screendepthmap, ScreenPosToViewportUV(uv1)).r;
        float depth2 = texture2D(screendepthmap, ScreenPosToViewportUV(uv2)).r;
        float depth3 = texture2D(screendepthmap, ScreenPosToViewportUV(uv3)).r;
        float depth4 = texture2D(screendepthmap, ScreenPosToViewportUV(uv4)).r;

        float BaseAngle = radians(HBAOBaseAngle);
        vec4 spos1 = Inverse_ProjectviewMatrix * vec4(uv1.x, uv1.y, depth1, 1);
        float T = depthlimit;
        float AnglePos1 = 1 / depth1  - 1 / depth> T ? 0 : atan(spos1.z / length(spos1.xy));

        vec4 spos2 = Inverse_ProjectviewMatrix * vec4(uv2.x, uv2.y, depth2, 1);
        float AnglePos2 = 1 / depth2 - 1 / depth > T ? 0 : atan(spos2.z / length(spos2.xy));

        vec4 spos3 = Inverse_ProjectviewMatrix * vec4(uv3.x, uv3.y, depth3, 1);
        float AnglePos3 = 1 / depth3 - 1 / depth > T ? 0 : atan(spos3.z / length(spos3.xy));

        vec4 spos4 = Inverse_ProjectviewMatrix * vec4(uv4.x, uv4.y, depth4, 1);
        float AnglePos4 = 1 / depth4 - 1 / depth > T ? 0 : atan(spos4.z / length(spos4.xy));

        float MaxAngle = max(max(AnglePos1, AnglePos2), max(AnglePos3, AnglePos4));

        MaxAngle = step(BaseAngle, MaxAngle) * MaxAngle;
        vec4 basecolor = texture2D(tex, texture_coords);
        if (MaxAngle == 0)
            return basecolor;

        float TargentAngle = 0.785 - atan(normal.z / length(normal.xy));
        

        float weight = clamp(1 - sin(MaxAngle) + sin(TargentAngle), 0.5, 1.0);
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
    Shader["shader_HBAO"] = shader;
    shader.setHBAOValue = function (shader, screendepthmap)
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

        if shader:hasUniform("HBAOLenght") then
            shader:send("HBAOLenght", RenderSet.getHBAORayMatchLength())
        end

        if shader:hasUniform("HBAOBaseAngle") then
            shader:send("HBAOBaseAngle", RenderSet.getHBAOBaseAngle())
        end

        if shader:hasUniform("depthlimit") then
            shader:send("depthlimit", RenderSet.getSSAODepthLimit())
        end
        
    end
    
    shader.setHBAOValue(shader, screendepthmap)
    return shader
end