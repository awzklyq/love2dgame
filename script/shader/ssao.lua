
function Shader.GetSSAOShader(screennormalmap, screendepthmap)
    if Shader["ssao"] then
        Shader["ssao"].setValue(Shader["ssao"], screennormalmap, screendepthmap)
        return Shader["ssao"]
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
    // Maps standard viewport UV to screen position.
    vec2 ViewportUVToScreenPos(vec2 ViewportUV)
    {
        return vec2(2 * ViewportUV.x - 1, 1 - 2 * ViewportUV.y);
    }

    vec2 ScreenPosToViewportUV(vec2 ScreenPos)
    {
        return vec2(0.5 + 0.5 * ScreenPos.x, 0.5 - 0.5 * ScreenPos.y);
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
       normal = normalize((normal - vec4(0.5, 0.5, 0.5, 0.5)) * 2);

       vec4 rpos1 = vec4(2.8700, 0.8735, -2.2461, 1);
        vec4 rpos2 = vec4(-0.9971, -0.0767, 2.6844, 1);
        vec4 rpos3 = vec4(-1.7354, 0.9942, 0.6508, 1);
        vec4 rpos4 = vec4(1.7282, 1.0066, -1.2724, 1);
        vec4 rpos5 = vec4(-0.9985, -0.0555, -1.4700, 1);
        vec4 rpos6 = vec4(0.4876, -0.8731, 1.1225, 1);
        vec4 rpos7 = vec4(-0.9574, 0.2887, 1.2917, 1);
        vec4 rpos8 = vec4(-2.4360, -1.7509, 2.3980, 1);
        vec4 rpos9 = vec4(-0.8183, -0.5748, -0.0390, 1);
        vec4 rpos10 = vec4(-2.7717, 1.1479, 0.2520, 1);
        vec4 rpos11 = vec4(2.1213, 2.1213, -1.0145, 1);
        vec4 rpos12 = vec4(0.3280, 2.9820, -2.0278, 1);

        vec2 screenpos0 = vpos.xy + vec2(1 * (1/viewsizew), 0.0);
        vec2 uv0 = vec2((screenpos0.x + 1) * 0.5, 1 - (screenpos0.y + 1) * 0.5);
        vec4 ScenePosition0 = Inverse_ProjectviewMatrix * vec4(screenpos0.x, screenpos0.y, texture2D(screendepthmap, uv0).r, 1);

        ScenePosition0 /= ScenePosition0.w;

        vec2 screenpos1 = vpos.xy - vec2( 0.0, 1 * (1/viewsizeh) );  
        vec2 uv1 = vec2((screenpos1.x + 1) * 0.5, 1 - (screenpos1.y + 1) * 0.5);
        vec4 ScenePosition1 = Inverse_ProjectviewMatrix * vec4(screenpos1.x, screenpos1.y, texture2D(screendepthmap, uv1).r, 1);

        ScenePosition1 /= ScenePosition1.w;

        float offset = 1;
        normal.xyz = normalize(cross(ScenePosition0.xyz - spos.xyz, ScenePosition1.xyz - spos.xyz));
        
        rpos1.xyz = faceforward(rpos1.xyz, normal.xyz, rpos1.xyz) * offset + spos.xyz;

        rpos2.xyz = faceforward(rpos2.xyz, normal.xyz, rpos2.xyz)  * offset+ spos.xyz;

        rpos3.xyz = faceforward(rpos3.xyz, normal.xyz, rpos3.xyz) * offset + spos.xyz;

        rpos4.xyz = faceforward(rpos4.xyz, normal.xyz, rpos4.xyz) * offset + spos.xyz;

        rpos5.xyz = faceforward(rpos5.xyz, normal.xyz, rpos5.xyz)  * offset+ spos.xyz;

        rpos6.xyz = faceforward(rpos6.xyz, normal.xyz, rpos6.xyz) * offset + spos.xyz;

        rpos7.xyz = faceforward(rpos7.xyz, normal.xyz, rpos7.xyz) * offset + spos.xyz;

        rpos8.xyz = faceforward(rpos8.xyz, normal.xyz, rpos8.xyz)  * offset+ spos.xyz;

        rpos9.xyz = faceforward(rpos9.xyz, normal.xyz, rpos9.xyz) * offset + spos.xyz;

        rpos10.xyz = faceforward(rpos10.xyz, normal.xyz, rpos10.xyz) * offset + spos.xyz;

        rpos11.xyz = faceforward(rpos11.xyz, normal.xyz, rpos11.xyz)  * offset+ spos.xyz;

        rpos12.xyz = faceforward(rpos12.xyz, normal.xyz, rpos12.xyz) * offset + spos.xyz;

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
        vec4 vpos9 = projectionViewMatrix *  rpos9;
        vpos9 /= vpos9.w;
        vec4 vpos10 = projectionViewMatrix *  rpos10;
        vpos10 /= vpos10.w;
        vec4 vpos11 = projectionViewMatrix *  rpos11;
        vpos11 /= vpos11.w;
        vec4 vpos12 = projectionViewMatrix *  rpos12;
        vpos12 /= vpos12.w;

        float depth1 = texture2D(screendepthmap, ScreenPosToViewportUV(vpos1.xy)).r;
        float depth2 = texture2D(screendepthmap, ScreenPosToViewportUV(vpos2.xy)).r;
        float depth3 = texture2D(screendepthmap, ScreenPosToViewportUV(vpos3.xy)).r;
        float depth4 = texture2D(screendepthmap, ScreenPosToViewportUV(vpos4.xy)).r;
        float depth5 = texture2D(screendepthmap, ScreenPosToViewportUV(vpos5.xy)).r;
        float depth6 = texture2D(screendepthmap, ScreenPosToViewportUV(vpos6.xy)).r;

        float depth7 = texture2D(screendepthmap, ScreenPosToViewportUV(vpos7.xy)).r;
        float depth8 = texture2D(screendepthmap, ScreenPosToViewportUV(vpos8.xy)).r;
        float depth9 = texture2D(screendepthmap, ScreenPosToViewportUV(vpos9.xy)).r;
        float depth10 = texture2D(screendepthmap, ScreenPosToViewportUV(vpos10.xy)).r;
        float depth11 = texture2D(screendepthmap, ScreenPosToViewportUV(vpos11.xy)).r;
        float depth12 = texture2D(screendepthmap, ScreenPosToViewportUV(vpos12.xy)).r;

		float value1 = vpos1.z -  depth1 > ssaooffset ? 0 : 1;
		float value2 = vpos2.z -  depth2 > ssaooffset ? 0 : 1;
        float value3 = vpos3.z -  depth3 > ssaooffset ? 0 : 1;
        float value4 = vpos4.z -  depth4 > ssaooffset ? 0 : 1;
        float value5 = vpos5.z -  depth5 > ssaooffset ? 0 : 1;
        float value6 = vpos6.z -  depth6 > ssaooffset ? 0 : 1;

        float value7 = vpos7.z -  depth7 > ssaooffset ? 0 : 1;
		float value8 = vpos8.z -  depth8 > ssaooffset ? 0 : 1;
        float value9 = vpos9.z -  depth9 > ssaooffset ? 0 : 1;
        float value10 = vpos10.z -  depth10 > ssaooffset ? 0 : 1;
        float value11 = vpos11.z -  depth11 > ssaooffset ? 0 : 1;
        float value12 = vpos12.z -  depth12 > ssaooffset ? 0 : 1;

       vec4 basecolor = texture2D(tex, texture_coords);
       float value = value1 + value2 + value3 + value4 + value5 + value6 + value7 + value8 + value9 + value10 + value11 + value12;
       basecolor.xyz *=  value / 12;

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
    Shader["ssao"] = shader;
    shader.setValue = function (shader, screennormalmap, screendepthmap)
        if shader:hasUniform("screennormalmap") then
            shader:send("screennormalmap", screennormalmap.obj)
        end

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
            shader:send("viewsizew", RenderSet.screenwidth)
        end

        if shader:hasUniform("viewsizeh") then
            shader:send("viewsizeh", RenderSet.screenheight)
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