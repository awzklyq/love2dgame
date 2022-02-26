
_G.TAANode = {}
TAANode.Canvae = Canvas.new(1, 1, {format = "rgba8", readable = true, msaa = 0, mipmaps="none"})

TAANode.PreCanvae = Canvas.new(1, 1, {format = "rgba8", readable = true, msaa = 0, mipmaps="none"})

TAANode.Canvae.renderWidth = 1
TAANode.Canvae.renderHeight = 1
TAANode.meshquad = _G.MeshQuad.new(1,1, LColor.new(255, 255, 255, 255))

TAANode.LineWidth = 4;
TAANode.Color = LColor.new(255,0,0,255);
TAANode.Threshold = 1

TAANode.Init = function()
    TAANode.PreImage = nil
end

TAANode.Execute = function(Canva1, screennormalmap, screendepthmap)
   
    if TAANode.Canvae.renderWidth ~= Canva1.renderWidth  or TAANode.Canvae.renderHeight ~= Canva1.renderHeight then
        TAANode.Canvae = Canvas.new(Canva1.renderWidth , Canva1.renderHeight , {format = "rgba8", readable = true, msaa = 0, mipmaps="none"})

        TAANode.PreCanvae = Canvas.new(Canva1.renderWidth , Canva1.renderHeight , {format = "rgba8", readable = true, msaa = 0, mipmaps="none"})

        TAANode.Canvae.renderWidth = Canva1.renderWidth
        TAANode.Canvae.renderHeight = Canva1.renderHeight

        TAANode.meshquad = _G.MeshQuad.new(TAANode.Canvae.renderWidth, TAANode.Canvae.renderHeight , LColor.new(255, 255, 255, 255))

        love.graphics.setCanvas(Canva1.obj)
        love.graphics.clear()
        TAANode.meshquad:setCanvas(TAANode.Canvae)
        TAANode.meshquad.shader =  Shader.GetBaseShader()
        TAANode.meshquad:draw()
        love.graphics.setCanvas()
    end

    -- if not TAANode.PreImage then
    --     TAANode.PreImage = ImageEx.new(Canva1:newImageData())
    --     return Canva1;
    -- end
    
    love.graphics.setCanvas(TAANode.Canvae.obj)
    love.graphics.clear()
    TAANode.meshquad:setCanvas(Canva1)
    TAANode.meshquad.shader = Shader.GetTAAShader(TAANode.Canvae.renderWidth , TAANode.Canvae.renderHeight )
    TAANode.meshquad:draw()
    love.graphics.setCanvas()

    love.graphics.setCanvas(TAANode.PreCanvae.obj)
    love.graphics.clear()
    TAANode.meshquad:setCanvas(TAANode.Canvae)
    TAANode.meshquad.shader =  Shader.GetBaseShader()
    TAANode.meshquad:draw()
    love.graphics.setCanvas()

    return TAANode.Canvae
end



function Shader.GetTAAShader(w, h)
    if Shader["taa"] then
        Shader["taa"]:SetTaaShaderValue(w, h)
        return Shader["taa"]
    end
    local pixelcode = [[
    uniform float w;
    uniform float h;

    uniform int JitterIndex;
    
    uniform sampler2D MotionVectorMap;
    uniform sampler2D PreImage;

    const mat3 RGBToYCoCgMatrix = mat3(0.25, 0.5, -0.25, 0.5, 0.0, 0.5, 0.25, -0.5, -0.25);

    const mat3 YCoCgToRGBMatrix = mat3(1.0, 1.0, 1.0, 1.0, 0.0, -1.0, -1.0, 1.0, -1.0);

  //  vec3 RPGToYCoCg(float R, float G, float B)
 //   {
 //       float Y = ((R + 2*G + B)+ 2)/4;
 //       float Co = ((R - B) + 1))/2;
 //       float Cg = (( - R + 2*G - B) + 2)/4;
//
//        return vec3(Y, Co, Cg);
 //   }

    float luma(vec4 color)
    {
        return dot(color.rgb, vec3(0.299, 0.587, 0.114));
    }

    vec4 effect( vec4 color, sampler2D tex, vec2 texture_coords, vec2 screen_coords )
    {
        float power = 0.5;
        float offsetw = power / (w);
        float offseth = power / (h);

        vec2 JitterVec[16];
        JitterVec[0] = vec2( (0.5 -   0.5 ) * offsetw, (0.5 - 0.92592592592593) * offseth);
        JitterVec[1] = vec2( (0.5 - 0.5) * offsetw, (0.5 - 0.33333333333333) * offseth);
        JitterVec[2] = vec2( (0.5 - 0.5) * offsetw, (0.5 - 0.66666666666667) * offseth);
        JitterVec[3] = vec2( (0.5 - 0.75) * offsetw, (0.5 -  0) * offseth);
        JitterVec[4] = vec2( (0.5 - 0) * offsetw, (0.5 - 0.44444444444444) * offseth);

        JitterVec[5] = vec2( (0.5 - 0.5) * offsetw, (0.5 -  0.77777777777778) * offseth);
        JitterVec[6] = vec2( (0.5 - 0.375) * offsetw, (0.5 - 0.22222222222222) * offseth);

        JitterVec[7] = vec2( (0.5 - 0.875) * offsetw, (0.5 -  0.55555555555556) * offseth);
        JitterVec[8] = vec2( (0.5 - 0) * offsetw, (0.5 - 0.88888888888889) * offseth);

        JitterVec[9] = vec2( (0.5 - 0.25) * offsetw, (0.5 -  0.33333333333333) * offseth);
        JitterVec[10] = vec2( (0.5 - 0.75) * offsetw, (0.5 - 0.66666666666667) * offseth);

        JitterVec[11] = vec2( (0.5 - 0.1875) * offsetw, (0.5 -  0.14814814814815) * offseth);
        JitterVec[12] = vec2( (0.5 -  0.6875) * offsetw, (0.5 - 0.48148148148148) * offseth);

        JitterVec[13] = vec2( (0.5 - 0.4375) * offsetw, (0.5 -  0.81481481481481) * offseth);
        JitterVec[14] = vec2( (0.5 -  0.9375) * offsetw, (0.5 - 0.25925925925926) * offseth);

        JitterVec[15] = vec2( (0.5 - 0.0) * offsetw, (0.5 -  0.59259259259259) * offseth);

        vec2 uv = vec2(texture_coords.x + JitterVec[JitterIndex].x, texture_coords.y + JitterVec[JitterIndex].y);

        vec2 MotionInfo = texture2D(MotionVectorMap, texture_coords).xy;

        vec4 PreColor = texture2D(PreImage, uv - MotionInfo);
        vec4 CurColor = texture2D(tex, texture_coords);

        vec3 PreYCoCg = RGBToYCoCgMatrix * PreColor.xyz;
        vec3 CurYCoCg = RGBToYCoCgMatrix * CurColor.xyz;

        vec3 AABBMin = CurYCoCg;
        vec3 AABBMax = CurYCoCg;

       // offsetw /= power;
       // offseth /= power;
        for(int iii = -1; iii <= 1; iii ++)
        {
            for(int jjj = -1; jjj <= 1; jjj ++)
            {
                vec3 C = RGBToYCoCgMatrix * texture2D(tex, texture_coords + vec2(offsetw * iii, offseth * jjj)).xyz;
                AABBMin = min(AABBMin, C);
                AABBMax = min(AABBMax, C);
            }
        }

        PreColor.xyz = YCoCgToRGBMatrix * clamp(PreYCoCg, AABBMin, AABBMax);
        return vec4(mix(PreColor.xyz, CurColor.xyz, 0.025), CurColor.w);

    }
]]
 
    local vertexcode = [[
    vec4 position( mat4 transform_projection, vec4 vertex_position )
    {
        return transform_projection * vertex_position;
    }
]]

    log(pixelcode)

    local shader =   Shader.new(pixelcode, vertexcode)

    shader.SetTaaShaderValue = function(obj, w, h)
       -- assert(obj:hasUniform( "w") and obj:hasUniform( "h"))
        obj:sendValue('w', w)
        obj:sendValue('h', h)

        if TAANode.PreCanvae then
            obj:sendValue('PreImage', TAANode.PreCanvae.obj)
        end

        if MotionVectorNode.Canvas then
            obj:sendValue('MotionVectorMap', MotionVectorNode.Canvas.obj)
        end

        obj:sendValue('JitterIndex', math.fmod(RenderSet.frameToken, 16) )
    end

    Shader["taa"] = shader;
    return shader
end