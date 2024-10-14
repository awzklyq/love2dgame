
_G.BlurFilterNode = {}
BlurFilterNode.Canvae = Canvas.new(1, 1, {format = "rgba8", readable = true, msaa = 0, mipmaps="none"})
BlurFilterNode.Canvae.renderWidth = 1
BlurFilterNode.Canvae.renderHeight = 1
BlurFilterNode.meshquad = _G.MeshQuad.new(1,1, LColor.new(255, 255, 255, 255))

BlurFilterNode.Color = LColor.new(255,0,0,255);

BlurFilterNode.Execute = function(Canva1)
   
    if BlurFilterNode.Canvae.renderWidth ~= Canva1.renderWidth  or BlurFilterNode.Canvae.renderHeight ~= Canva1.renderHeight then
        BlurFilterNode.Canvae = Canvas.new(Canva1.renderWidth , Canva1.renderHeight , {format = "rgba8", readable = true, msaa = 0, mipmaps="none"})
        BlurFilterNode.Canvae.renderWidth = Canva1.renderWidth
        BlurFilterNode.Canvae.renderHeight = Canva1.renderHeight

        BlurFilterNode.meshquad = _G.MeshQuad.new(BlurFilterNode.Canvae.renderWidth, BlurFilterNode.Canvae.renderHeight , LColor.new(255, 255, 255, 255))
    end
    
    love.graphics.setCanvas(BlurFilterNode.Canvae.obj)
    love.graphics.clear()
    BlurFilterNode.meshquad:setCanvas(Canva1)
    BlurFilterNode.meshquad.shader = Shader.GetBlurFilter5Shader( BlurFilterNode.Canvae.renderWidth , BlurFilterNode.Canvae.renderHeight )
    BlurFilterNode.meshquad:draw()
    love.graphics.setCanvas()
    return BlurFilterNode.Canvae
end

function Shader.GetBlurFilter5Shader(sw, sh)
    if Shader["shader_BlurFilter"] then
        Shader["shader_BlurFilter"].setBlurFilterValue(Shader["shader_BlurFilter"],  sw, sh)
        return Shader["shader_BlurFilter"]
    end
    local pixelcode = [[
    uniform float viewsizew;
    uniform float viewsizeh;

    vec4 effect( vec4 color, sampler2D tex, vec2 texture_coords, vec2 screen_coords )
    {
        float offsetw = 1 / viewsizew;
        float offseth = 1 / viewsizeh;

        vec4 BaseColor;
        int SunIndex = 0;
        for(int i = -7; i <= 7; i ++)
        {
            for(int j = -7; j <= 7; j ++)
            {
               vec2 NewUV = vec2(offsetw * i + texture_coords.x, offseth * j + texture_coords.y);
               vec4 BlurColor = texture2D(tex, NewUV);
               BaseColor += BlurColor;
               SunIndex ++;
            }
        }


        BaseColor.xyz /= SunIndex;

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
    Shader["shader_BlurFilter"] = shader;
    shader.setBlurFilterValue = function (shader, sw, sh)
        shader:sendValue("viewsizew", sw)

        shader:sendValue("viewsizeh", sh)
    end
    
    shader.setBlurFilterValue(shader, sw, sh)
    return shader
end