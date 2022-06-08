
_G.TAANode = {}
TAANode.Canvae = Canvas.new(1, 1, {format = "rgba8", readable = true, msaa = 0, mipmaps="none"})

TAANode.PreCanvae = Canvas.new(1, 1, {format = "rgba8", readable = true, msaa = 0, mipmaps="none"})

TAANode.Canvae.renderWidth = 1
TAANode.Canvae.renderHeight = 1
TAANode.meshquad = _G.MeshQuad.new(1,1, LColor.new(255, 255, 255, 255))

TAANode.LineWidth = 4;
TAANode.Color = LColor.new(255,0,0,255);
TAANode.Threshold = 0.1

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

    uniform float ThresholdTAA;

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
        float power = 1;
        float offsetw = power / (w);
        float offseth = power / (h);

        vec2 JitterVec[64];
        JitterVec[0] = vec2( (0.5 - 0.5) * offsetw, (0.5 -  0.33333333333333) * offseth);
        JitterVec[1] = vec2( (0.5 - 0) * offsetw, (0.5 -  0.66666666666667) * offseth);
        JitterVec[2] = vec2( (0.5 - 0.75) * offsetw, (0.5 -  0) * offseth);
        JitterVec[3] = vec2( (0.5 - 0) * offsetw, (0.5 -  0.44444444444444) * offseth);
        JitterVec[4] = vec2( (0.5 - 0.5) * offsetw, (0.5 -  0.77777777777778) * offseth);
        JitterVec[5] = vec2( (0.5 - 0.375) * offsetw, (0.5 -  0.22222222222222) * offseth);
        JitterVec[6] = vec2( (0.5 - 0.875) * offsetw, (0.5 -  0.55555555555556) * offseth);
        JitterVec[7] = vec2( (0.5 - 0) * offsetw, (0.5 -  0.88888888888889) * offseth);
        JitterVec[8] = vec2( (0.5 - 0.5) * offsetw, (0.5 -  0) * offseth);
        JitterVec[9] = vec2( (0.5 - 0.25) * offsetw, (0.5 -  0.33333333333333) * offseth);
        JitterVec[10] = vec2( (0.5 - 0.75) * offsetw, (0.5 -  0.66666666666667) * offseth);
        JitterVec[11] = vec2( (0.5 - 0.1875) * offsetw, (0.5 -  0.14814814814815) * offseth);
        JitterVec[12] = vec2( (0.5 - 0.6875) * offsetw, (0.5 -  0.48148148148148) * offseth);
        JitterVec[13] = vec2( (0.5 - 0.4375) * offsetw, (0.5 -  0.81481481481481) * offseth);
        JitterVec[14] = vec2( (0.5 - 0.9375) * offsetw, (0.5 -  0.25925925925926) * offseth);
        JitterVec[15] = vec2( (0.5 - 0) * offsetw, (0.5 -  0.59259259259259) * offseth);
        JitterVec[16] = vec2( (0.5 - 0.5) * offsetw, (0.5 -  0.92592592592593) * offseth);
        JitterVec[17] = vec2( (0.5 - 0.25) * offsetw, (0.5 -  0.074074074074074) * offseth);
        JitterVec[18] = vec2( (0.5 - 0.75) * offsetw, (0.5 -  0.40740740740741) * offseth);
        JitterVec[19] = vec2( (0.5 - 0.125) * offsetw, (0.5 -  0.74074074074074) * offseth);
        JitterVec[20] = vec2( (0.5 - 0.625) * offsetw, (0.5 -  0.18518518518519) * offseth);
        JitterVec[21] = vec2( (0.5 - 0.375) * offsetw, (0.5 -  0.51851851851852) * offseth);
        JitterVec[22] = vec2( (0.5 - 0.875) * offsetw, (0.5 -  0.85185185185185) * offseth);
        JitterVec[23] = vec2( (0.5 - 0.09375) * offsetw, (0.5 -  0.2962962962963) * offseth);
        JitterVec[24] = vec2( (0.5 - 0.59375) * offsetw, (0.5 -  0.62962962962963) * offseth);
        JitterVec[25] = vec2( (0.5 - 0.34375) * offsetw, (0.5 -  0.96296296296296) * offseth);
        JitterVec[26] = vec2( (0.5 - 0.84375) * offsetw, (0.5 -  0) * offseth);
        JitterVec[27] = vec2( (0.5 - 0.21875) * offsetw, (0.5 -  0.33333333333333) * offseth);
        JitterVec[28] = vec2( (0.5 - 0.71875) * offsetw, (0.5 -  0.66666666666667) * offseth);
        JitterVec[29] = vec2( (0.5 - 0.46875) * offsetw, (0.5 -  0.11111111111111) * offseth);
        JitterVec[30] = vec2( (0.5 - 0.96875) * offsetw, (0.5 -  0.44444444444444) * offseth);
        JitterVec[31] = vec2( (0.5 - 0) * offsetw, (0.5 -  0.77777777777778) * offseth);
        JitterVec[32] = vec2( (0.5 - 0.5) * offsetw, (0.5 -  0.22222222222222) * offseth);
        JitterVec[33] = vec2( (0.5 - 0.25) * offsetw, (0.5 -  0.55555555555556) * offseth);
        JitterVec[34] = vec2( (0.5 - 0.75) * offsetw, (0.5 -  0.88888888888889) * offseth);
        JitterVec[35] = vec2( (0.5 - 0.125) * offsetw, (0.5 -  0.049382716049383) * offseth);
        JitterVec[36] = vec2( (0.5 - 0.625) * offsetw, (0.5 -  0.38271604938272) * offseth);
        JitterVec[37] = vec2( (0.5 - 0.375) * offsetw, (0.5 -  0.71604938271605) * offseth);
        JitterVec[38] = vec2( (0.5 - 0.875) * offsetw, (0.5 -  0.16049382716049) * offseth);
        JitterVec[39] = vec2( (0.5 - 0.0625) * offsetw, (0.5 -  0.49382716049383) * offseth);
        JitterVec[40] = vec2( (0.5 - 0.5625) * offsetw, (0.5 -  0.82716049382716) * offseth);
        JitterVec[41] = vec2( (0.5 - 0.3125) * offsetw, (0.5 -  0.2716049382716) * offseth);
        JitterVec[42] = vec2( (0.5 - 0.8125) * offsetw, (0.5 -  0.60493827160494) * offseth);
        JitterVec[43] = vec2( (0.5 - 0.1875) * offsetw, (0.5 -  0.93827160493827) * offseth);
        JitterVec[44] = vec2( (0.5 - 0.6875) * offsetw, (0.5 -  0.08641975308642) * offseth);
        JitterVec[45] = vec2( (0.5 - 0.4375) * offsetw, (0.5 -  0.41975308641975) * offseth);
        JitterVec[46] = vec2( (0.5 - 0.9375) * offsetw, (0.5 -  0.75308641975309) * offseth);
        JitterVec[47] = vec2( (0.5 - 0.046875) * offsetw, (0.5 -  0.19753086419753) * offseth);
        JitterVec[48] = vec2( (0.5 - 0.546875) * offsetw, (0.5 -  0.53086419753086) * offseth);
        JitterVec[49] = vec2( (0.5 - 0.296875) * offsetw, (0.5 -  0.8641975308642) * offseth);
        JitterVec[50] = vec2( (0.5 - 0.796875) * offsetw, (0.5 -  0.30864197530864) * offseth);
        JitterVec[51] = vec2( (0.5 - 0.171875) * offsetw, (0.5 -  0.64197530864198) * offseth);
        JitterVec[52] = vec2( (0.5 - 0.671875) * offsetw, (0.5 -  0.97530864197531) * offseth);
        JitterVec[53] = vec2( (0.5 - 0.421875) * offsetw, (0.5 -  0.024691358024691) * offseth);
        JitterVec[54] = vec2( (0.5 - 0.921875) * offsetw, (0.5 -  0.35802469135802) * offseth);
        JitterVec[55] = vec2( (0.5 - 0.109375) * offsetw, (0.5 -  0.69135802469136) * offseth);
        JitterVec[56] = vec2( (0.5 - 0.609375) * offsetw, (0.5 -  0.1358024691358) * offseth);
        JitterVec[57] = vec2( (0.5 - 0.359375) * offsetw, (0.5 -  0.46913580246914) * offseth);
        JitterVec[58] = vec2( (0.5 - 0.859375) * offsetw, (0.5 -  0.80246913580247) * offseth);
        JitterVec[59] = vec2( (0.5 - 0.234375) * offsetw, (0.5 -  0.24691358024691) * offseth);
        JitterVec[60] = vec2( (0.5 - 0.734375) * offsetw, (0.5 -  0.58024691358025) * offseth);
        JitterVec[61] = vec2( (0.5 - 0.484375) * offsetw, (0.5 -  0.91358024691358) * offseth);
        JitterVec[62] = vec2( (0.5 - 0.984375) * offsetw, (0.5 -  0.061728395061728) * offseth);
        JitterVec[63] = vec2( (0.5 - 0) * offsetw, (0.5 -  0.39506172839506) * offseth);
        

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
        return vec4(mix(PreColor.xyz, CurColor.xyz, ThresholdTAA), CurColor.w);

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

       -- log('bbbb', math.fmod(RenderSet.frameToken, 64))
        obj:sendValue('JitterIndex', math.fmod(RenderSet.frameToken, 64) )

        obj:sendValue("ThresholdTAA", TAANode.Threshold)
    end

    Shader["taa"] = shader;
    return shader
end