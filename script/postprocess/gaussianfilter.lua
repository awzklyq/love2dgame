
_G.GaussianFilterNode = {}
GaussianFilterNode.Canvae = Canvas.new(1, 1, {format = "rgba8", readable = true, msaa = 0, mipmaps="none"})
GaussianFilterNode.Canvae.renderWidth = 1
GaussianFilterNode.Canvae.renderHeight = 1
GaussianFilterNode.meshquad = _G.MeshQuad.new(1,1, LColor.new(255, 255, 255, 255))

GaussianFilterNode.LineWidth = 4;
GaussianFilterNode.Color = LColor.new(255,0,0,255);
GaussianFilterNode.Threshold = 1
GaussianFilterNode.Sigma = 0.8
GaussianFilterNode.Execute = function(Canva1)
   
    if GaussianFilterNode.Canvae.renderWidth ~= Canva1.renderWidth  or GaussianFilterNode.Canvae.renderHeight ~= Canva1.renderHeight then
        GaussianFilterNode.Canvae = Canvas.new(Canva1.renderWidth , Canva1.renderHeight , {format = "rgba8", readable = true, msaa = 0, mipmaps="none"})
        GaussianFilterNode.Canvae.renderWidth = Canva1.renderWidth
        GaussianFilterNode.Canvae.renderHeight = Canva1.renderHeight

        GaussianFilterNode.meshquad = _G.MeshQuad.new(GaussianFilterNode.Canvae.renderWidth, GaussianFilterNode.Canvae.renderHeight , LColor.new(255, 255, 255, 255))
    end
    
    love.graphics.setCanvas(GaussianFilterNode.Canvae.obj)
    love.graphics.clear()
    GaussianFilterNode.meshquad:setCanvas(Canva1)
    GaussianFilterNode.meshquad.shader = Shader.GetGaussianFilterShader( GaussianFilterNode.Canvae.renderWidth , GaussianFilterNode.Canvae.renderHeight, GaussianFilterNode.Sigma )
    GaussianFilterNode.meshquad:draw()
    love.graphics.setCanvas()
    return GaussianFilterNode.Canvae
end

function Shader.GetGaussianFilterShader(sw, sh, Sigma)
    if Shader["shader_GaussianFilter"] then
        Shader["shader_GaussianFilter"].setGaussianFilterValue(Shader["shader_GaussianFilter"],  sw, sh, Sigma)
        return Shader["shader_GaussianFilter"]
    end
    local pixelcode = [[
    uniform float viewsizew;
    uniform float viewsizeh;
    uniform float sigma;
    vec4 effect( vec4 color, sampler2D tex, vec2 texture_coords, vec2 screen_coords )
    {
        float offsetw = 1 / viewsizew;
        float offseth = 1 / viewsizeh;

        float templates[25];
        float SumGaussian = 0;
        int SunIndex = 0;
        for(int i = -2; i <= 2; i ++)
        {
            float x2 = i * i;
            for(int j = -2; j <= 2; j ++)
            {
                float y2 = j * j;

                templates[SunIndex] = exp(-(x2 + y2) / (2 * sigma * sigma));
                SumGaussian += templates[SunIndex];
                SunIndex ++;
            }
        }

        vec4 BaseColor;
        SunIndex = 0;
        for(int i = -2; i <= 2; i ++)
        {
            for(int j = -2; j <= 2; j ++)
            {
                vec2 NewUV = vec2(offsetw * i + texture_coords.x, offseth * j + texture_coords.y);
                vec4 GaussianColor = texture2D(tex, NewUV);
                GaussianColor *= templates[SunIndex] / SumGaussian;
               // GaussianColor = clamp(GaussianColor, vec4(0), vec4(1));
                BaseColor += GaussianColor;
                SunIndex ++;
            }
        }

      //  BaseColor /= SunIndex;

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
    Shader["shader_GaussianFilter"] = shader;
    shader.setGaussianFilterValue = function (shader, sw, sh)
        shader:sendValue("viewsizew", sw)

        shader:sendValue("viewsizeh", sh)
        shader:sendValue("sigma", Sigma)
    end
    
    shader.setGaussianFilterValue(shader, sw, sh, Sigma)
    return shader
end