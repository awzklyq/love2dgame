--https://www.kodeco.com/100-unreal-engine-4-paint-filter-tutorial/page/2
_G.KuwaharaFilterNode = {}
KuwaharaFilterNode.Canvae = Canvas.new(1, 1, {format = "rgba8", readable = true, msaa = 0, mipmaps="none"})
KuwaharaFilterNode.Canvae.renderWidth = 1
KuwaharaFilterNode.Canvae.renderHeight = 1
KuwaharaFilterNode.meshquad = _G.MeshQuad.new(1,1, LColor.new(255, 255, 255, 255))

KuwaharaFilterNode.LineWidth = 4;
KuwaharaFilterNode.Color = LColor.new(255,0,0,255);
KuwaharaFilterNode.Threshold = 1
KuwaharaFilterNode.Execute = function(Canva1)
   
    if KuwaharaFilterNode.Canvae.renderWidth ~= Canva1.renderWidth  or KuwaharaFilterNode.Canvae.renderHeight ~= Canva1.renderHeight then
        KuwaharaFilterNode.Canvae = Canvas.new(Canva1.renderWidth , Canva1.renderHeight , {format = "rgba8", readable = true, msaa = 0, mipmaps="none"})
        KuwaharaFilterNode.Canvae.renderWidth = Canva1.renderWidth
        KuwaharaFilterNode.Canvae.renderHeight = Canva1.renderHeight

        KuwaharaFilterNode.meshquad = _G.MeshQuad.new(KuwaharaFilterNode.Canvae.renderWidth, KuwaharaFilterNode.Canvae.renderHeight , LColor.new(255, 255, 255, 255))
    end
    
    love.graphics.setCanvas(KuwaharaFilterNode.Canvae.obj)
    love.graphics.clear()
    KuwaharaFilterNode.meshquad:setCanvas(Canva1)
    KuwaharaFilterNode.meshquad.shader = Shader.GetKuwaharaFilterNodeShader( KuwaharaFilterNode.Canvae.renderWidth , KuwaharaFilterNode.Canvae.renderHeight )
    KuwaharaFilterNode.meshquad:draw()
    love.graphics.setCanvas()
    return KuwaharaFilterNode.Canvae
end

function Shader.GetKuwaharaFilterNodeShader(sw, sh)
    if Shader["shader_GetKuwaharaFilterNodeShader"] then
        Shader["shader_GetKuwaharaFilterNodeShader"].setKuwaharaFilterValue(Shader["shader_GetKuwaharaFilterNodeShader"],  sw, sh)
        return Shader["shader_GetKuwaharaFilterNodeShader"]
    end
    local pixelcode = [[
    uniform float viewsizew;
    uniform float viewsizeh;

    vec4 GetKernelMeanAndVariance(sampler2D tex, vec2 UV, vec4 Range)
    {
        float offsetw = 1.0 / viewsizew;
        float offseth = 1.0 / viewsizeh;

        vec3 Mean = vec3(0.0);
        vec3 Variance = vec3(0.0);
        float Samples = 0.0;
        for (float x = Range.x; x <= Range.y; x++)
        {
            for (float y = Range.z; y <= Range.w; y++)
            {
                vec2 Offset = vec2(x * offsetw, y * offseth);
                vec3 PixelColor = texture2D(tex, Offset + UV).xyz;

                Mean += PixelColor;
                Variance += PixelColor * PixelColor;
                Samples++;
            }
        } 

        Mean /= Samples;
        Variance = Variance / Samples - Mean * Mean;

        float TotalVariance = Variance.r + Variance.g + Variance.b;
        return vec4(Mean.r, Mean.g, Mean.b, TotalVariance);
        
    }

    vec4 effect( vec4 color, sampler2D tex, vec2 texture_coords, vec2 screen_coords )
    {
        vec4 MeanAndVariance[4];
        vec4 Range;

        float XRadius = 5;
        float YRadius = 5;
        Range = vec4(-XRadius, 0, -YRadius, 0);
        MeanAndVariance[0] = GetKernelMeanAndVariance(tex, texture_coords, Range);

        Range = vec4(0, XRadius, -YRadius, 0);
        MeanAndVariance[1] = GetKernelMeanAndVariance(tex, texture_coords, Range);

        Range = vec4(-XRadius, 0, 0, YRadius);
        MeanAndVariance[2] = GetKernelMeanAndVariance(tex, texture_coords, Range);

        Range = vec4(0, XRadius, 0, YRadius);
        MeanAndVariance[3] = GetKernelMeanAndVariance(tex, texture_coords, Range);


        vec3 FinalColor = MeanAndVariance[0].rgb;
        float MinimumVariance = MeanAndVariance[0].a;

        for (int i = 1; i < 4; i++)
        {
            if (MeanAndVariance[i].a < MinimumVariance)
            {
                FinalColor = MeanAndVariance[i].rgb;
                MinimumVariance = MeanAndVariance[i].a;
            }
        }

        vec4 BaseColor;
        BaseColor.xyz = FinalColor.xyz;
        BaseColor.a = 1;
        return BaseColor;
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
    local shader =   Shader.new(pixelcode, vertexcode, Sigma)
    Shader["shader_GetKuwaharaFilterNodeShader"] = shader;
    shader.setKuwaharaFilterValue = function (shader, sw, sh)
        shader:sendValue("viewsizew", sw)

        shader:sendValue("viewsizeh", sh)
    end
    
    shader.setKuwaharaFilterValue(shader, sw, sh)
    return shader
end
