
_G.SSDONode = {}
SSDONode.Power = 1
SSDONode.Canvae = Canvas.new(1, 1, {format = "rgba8", readable = true, msaa = 0, mipmaps="none"})
SSDONode.Canvae.renderWidth = 1
SSDONode.Canvae.renderHeight = 1
SSDONode.meshquad = _G.MeshQuad.new(1,1, LColor.new(255, 255, 255, 255))

SSDONode.LineWidth = 4;
SSDONode.Color = LColor.new(255,0,0,255);
SSDONode.Threshold = 1
SSDONode.Execute = function(Canva1, screennormalmap, screendepthmap, scene)
   
    if SSDONode.Canvae.renderWidth ~= Canva1.renderWidth  or SSDONode.Canvae.renderHeight ~= Canva1.renderHeight then
        SSDONode.Canvae = Canvas.new(Canva1.renderWidth , Canva1.renderHeight , {format = "rgba8", readable = true, msaa = 0, mipmaps="none"})
        SSDONode.Canvae.renderWidth = Canva1.renderWidth
        SSDONode.Canvae.renderHeight = Canva1.renderHeight

        SSDONode.meshquad = _G.MeshQuad.new(SSDONode.Canvae.renderWidth, SSDONode.Canvae.renderHeight , LColor.new(255, 255, 255, 255))
    end
    
    love.graphics.setCanvas(SSDONode.Canvae.obj)
    love.graphics.clear(scene.bgColor._r, scene.bgColor._g, scene.bgColor._b, scene.bgColor._a) 
    SSDONode.meshquad:setCanvas(Canva1)
    SSDONode.meshquad.shader = Shader.GetSSDOShader(screennormalmap, screendepthmap, SSDONode.Canvae.renderWidth , SSDONode.Canvae.renderHeight )
    SSDONode.meshquad:draw()
    love.graphics.setCanvas()
    return SSDONode.Canvae
end

function Shader.GetSSDOShader(screennormalmap, screendepthmap, sw, sh)
    if Shader["ssdo"] then
        Shader["ssdo"].setValue(Shader["ssdo"], screennormalmap, screendepthmap)
        return Shader["ssdo"]
    end
    local pixelcode = [[
    uniform sampler2D screennormalmap;
    uniform sampler2D screendepthmap;
    //uniform sampler2D screencolormap;

    uniform mat4 projectionViewMatrix;

    uniform mat4 Inverse_ProjectviewMatrix;

    uniform float viewsizew;
    uniform float viewsizeh;
    uniform float ssaooffset;
    uniform float depthlimit;
    uniform float SSDOPower;
    // Maps standard viewport UV to screen position.
    vec2 ViewportUVToScreenPos(vec2 ViewportUV)
    {
        return vec2(2 * ViewportUV.x - 1, 1 - 2 * ViewportUV.y);
    }

    vec2 ScreenPosToViewportUV(vec2 ScreenPos)
    {
        return vec2(0.5 + 0.5 * ScreenPos.x, 0.5 - 0.5 * ScreenPos.y);
    }

    vec4 CacleValue(sampler2D tex, float value1, vec4 vpos1, vec4 normal, vec4 spos, vec4 rpos1)
    {
        
        if(value1 < 1)
            return vec4(0, 0, 0, 0);

        vec4 vonormal = texture2D(screennormalmap, ScreenPosToViewportUV(vpos1.xy));
        vonormal = normalize(vonormal * 2.0 - vec4(1.0, 1.0, 1.0, 1.0));
    
       // vonormal = projectionViewMatrix * vonormal;
        float weight = dot(vonormal.xyz, normal.xyz);
        if(weight > 0)
        {
            vec3 dir = normalize(spos.xyz - rpos1.xyz);
            float dis = distance(spos.xyz, rpos1.xyz);

            weight = clamp(dot(vonormal.xyz, dir), 0, 1);
            weight *= clamp(dot(normal.xyz, dir), 0, 1);

            weight /= 3.14 * dis * dis;
            //weight *= dis * dis;
            vec4 vocolor = vec4(0);
            vocolor.xyz = texture2D(tex, ScreenPosToViewportUV(vpos1.xy)).xyz * weight;
            vocolor.w = weight;
            return vocolor;
        }
        else
        {
            return vec4(0, 0, 0, 0);
        }

    }
    vec4 effect( vec4 color, sampler2D tex, vec2 texture_coords, vec2 screen_coords )
    {
       float depth = texture2D(screendepthmap, texture_coords).r;
       //depth = (depth - 0.5) *2;
       vec2 uv = ViewportUVToScreenPos(texture_coords);
       vec4 vpos = vec4(uv.x, uv.y, depth, 1.0);

     vec4 spos = Inverse_ProjectviewMatrix * vpos;
     //vec4 spos =  vpos * Inverse_ProjectviewMatrix;
       spos /= spos.w;

       vec4 normal = texture2D(screennormalmap, texture_coords);
       normal = normalize(normal * 2.0 - vec4(1.0, 1.0, 1.0, 1.0));

       //normal = projectionViewMatrix * normal;//TODO.. 需要切换到切线空间

       vec4 rpos1 = vec4(  0.5     ,       0.5     ,       0.70710678118655,	1);
        vec4 rpos2 = vec4( 1       ,       6.1232339957368e-17     ,       0,	1);
        vec4 rpos3 = vec4( 0.57735026918963        ,       -0.57735026918963       ,       0.57735026918963,1);
        vec4 rpos4 = vec4( 1.2246467991474e-16     ,       -1      ,       0,	1);
        vec4 rpos5 = vec4( -0.5    ,       -0.5    ,       0.70710678118655,	1);
        vec4 rpos6 = vec4( -0.73450955526776       ,       -1.3492721637027e-16    ,       0.67859834454585,	1);
        vec4 rpos7 = vec4( -0.66040155174815       ,       0.66040155174815        ,       0.35740674433659,	1);
        vec4 rpos8 = vec4( -2.4492935982947e-16    ,       1       ,       0,	1);

        vec2 screenpos0 = vpos.xy + vec2(1 * (1/viewsizew), 0.0);
        vec2 uv0 = vec2((screenpos0.x + 1) * 0.5, 1 - (screenpos0.y + 1) * 0.5);
        vec4 ScenePosition0 = Inverse_ProjectviewMatrix * vec4(screenpos0.x, screenpos0.y, texture2D(screendepthmap, uv0).r, 1);

        ScenePosition0 /= ScenePosition0.w;

        vec2 screenpos1 = vpos.xy - vec2( 0.0, 1 * (1/viewsizeh) );  
        vec2 uv1 = vec2((screenpos1.x + 1) * 0.5, 1 - (screenpos1.y + 1) * 0.5);
        vec4 ScenePosition1 = Inverse_ProjectviewMatrix * vec4(screenpos1.x, screenpos1.y, texture2D(screendepthmap, uv1).r, 1);

        ScenePosition1 /= ScenePosition1.w;

        float offset = ssaooffset;
        //normal.xyz = normalize(cross(ScenePosition0.xyz - spos.xyz, ScenePosition1.xyz - spos.xyz));
        
        rpos1.xyz = faceforward(rpos1.xyz, normal.xyz, rpos1.xyz) * offset + spos.xyz;

        rpos2.xyz = faceforward(rpos2.xyz, normal.xyz, rpos2.xyz)  * offset+ spos.xyz;

        rpos3.xyz = faceforward(rpos3.xyz, normal.xyz, rpos3.xyz) * offset + spos.xyz;

        rpos4.xyz = faceforward(rpos4.xyz, normal.xyz, rpos4.xyz) * offset + spos.xyz;

        rpos5.xyz = faceforward(rpos5.xyz, normal.xyz, rpos5.xyz)  * offset+ spos.xyz;

        rpos6.xyz = faceforward(rpos6.xyz, normal.xyz, rpos6.xyz) * offset + spos.xyz;

        rpos7.xyz = faceforward(rpos7.xyz, normal.xyz, rpos7.xyz) * offset + spos.xyz;

        rpos8.xyz = faceforward(rpos8.xyz, normal.xyz, rpos8.xyz)  * offset+ spos.xyz;

        vec4 vpos1 = projectionViewMatrix *  rpos1;
        vpos1 /= vpos1.w;
        vec4 vpos2 = projectionViewMatrix *  rpos2;
        vpos2 /= vpos2.w;
        vec4 vpos3 = projectionViewMatrix *  rpos3;
        vpos3 /= vpos3.w;
        vec4 vpos4 = projectionViewMatrix *  rpos4;
        vpos4 /= vpos4.w;
        vec4 vpos5 = projectionViewMatrix *  rpos5;
        vpos5 /= vpos5.w;
        vec4 vpos6 = projectionViewMatrix *  rpos6;
        vpos6 /= vpos6.w;

        vec4 vpos7 = projectionViewMatrix *  rpos7;
        rpos7 /= vpos1.w;
        vec4 vpos8 = projectionViewMatrix *  rpos8;
        vpos8 /= vpos8.w;

        float depth1 = texture2D(screendepthmap, ScreenPosToViewportUV(vpos1.xy)).r;
        float depth2 = texture2D(screendepthmap, ScreenPosToViewportUV(vpos2.xy)).r;
        float depth3 = texture2D(screendepthmap, ScreenPosToViewportUV(vpos3.xy)).r;
        float depth4 = texture2D(screendepthmap, ScreenPosToViewportUV(vpos4.xy)).r;
        float depth5 = texture2D(screendepthmap, ScreenPosToViewportUV(vpos5.xy)).r;
        float depth6 = texture2D(screendepthmap, ScreenPosToViewportUV(vpos6.xy)).r;

        float depth7 = texture2D(screendepthmap, ScreenPosToViewportUV(vpos7.xy)).r;
        float depth8 = texture2D(screendepthmap, ScreenPosToViewportUV(vpos8.xy)).r;

        float T = depthlimit;
		float value1 = vpos1.z - depth1 > T ? 1 : 0;
		float value2 = vpos2.z- depth2 > T ? 1 : 0;
        float value3 = vpos3.z- depth3 > T ? 1 : 0;
        float value4 = vpos4.z- depth4 > T ? 1 : 0;
        float value5 = vpos5.z- depth5 > T ? 1 : 0;
        float value6 = vpos6.z- depth6 > T ? 1 : 0;

        float value7 = vpos7.z - depth7 > T ? 1 : 0;
		float value8 = vpos8.z - depth8 > T ? 1 : 0;

        if(depth1 == 1)
        {
            value1 = 0;
        }
        if(depth2 == 1)
        {
            value2 = 0;
        }
        if(depth3 == 1)
        {
            value3 = 0;
        }
        if(depth4 == 1)
        {
            value4 = 0;
        }
        if(depth5 == 1)
        {
            value5 = 0;
        }
        if(depth6 == 1)
        {
            value6 = 0;
        }
        if(depth7 == 1)
        {
            value7 = 0;
        }
        if(depth8 == 1)
        {
            value8 = 0;
        }

        vec4 vocolor =vec4(0, 0, 0, 0);
        
        vocolor += CacleValue(tex, value1, vpos1, normal, spos, rpos1);
        vocolor += CacleValue(tex, value2, vpos2, normal, spos, rpos1);
        vocolor += CacleValue(tex, value3, vpos3, normal, spos, rpos1);
        vocolor += CacleValue(tex, value4, vpos4, normal, spos, rpos1);
        vocolor += CacleValue(tex, value5, vpos5, normal, spos, rpos1);
        vocolor += CacleValue(tex, value6, vpos6, normal, spos, rpos1);
        vocolor += CacleValue(tex, value7, vpos7, normal, spos, rpos1);

       vec4 basecolor = texture2D(tex, texture_coords);

       if(vocolor.w == 0)
       {
            vocolor.w = 1;
            vocolor.xyz = vec3(0);
       }
        else
        {
            vocolor.xyz /= vocolor.w;
        }
       
       basecolor.xyz +=  vocolor.xyz * SSDOPower;//max(vocolor.xyz, vec3(0));
       basecolor.w = 1;
//       vocolor.w *= 0.5;
 //      vocolor.w += 1;
//       basecolor.xyz /= vocolor.w;

       //return vec4(vec3(depth1),1);
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
    Shader["ssdo"] = shader;
    shader.setValue = function (shader, screennormalmap, screendepthmap)
        if shader:hasUniform("screennormalmap") then
            shader:send("screennormalmap", screennormalmap.obj)
        end

        if shader:hasUniform("screendepthmap") then
            shader:send("screendepthmap", screendepthmap.obj)
        end

        if shader:hasUniform("depthlimit") then
            shader:send("depthlimit", RenderSet.getSSAODepthLimit())
        end

        if shader:hasUniform("SSDOPower") then
            shader:send("SSDOPower", SSDONode.Power )
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

        if shader:hasUniform("ssaooffset") then
            shader:send("ssaooffset", RenderSet.getSSAOValue())
        end
        
    end
    
    shader.setValue(shader,screennormalmap, screendepthmap)
    return shader
end