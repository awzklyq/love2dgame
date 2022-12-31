_G.ImageAnimaShader = {}
function ImageAnimaShader.GetImageAnimaVSCodeShader()
    local vertexcode = [[
    vec4 position( mat4 transform_projection, vec4 vertex_position )
    {
        return transform_projection * vertex_position;
    }
]]

    return  vertexcode
end

function ImageAnimaShader.GetImageAnimaPSCodeShader()
    local pixelcode = [[
    uniform float StartU;
    uniform float StartV;
    uniform float ScaleU;
    uniform float ScaleV;
    vec4 effect( vec4 color, sampler2D tex, vec2 texture_coords, vec2 screen_coords )
    {
        vec2 uv = vec2(StartU, StartV) + texture_coords * vec2(ScaleU, ScaleV);
        vec4 texcolor = Texel(tex, uv);
        return texcolor * color;
    }
]]

    return pixelcode
end

function ImageAnimaShader.GetImageAnimaShader(StartU, StartV, ScaleU, ScaleV)
    if ImageAnimaShader['ImageAnima_Shader'] then
        ImageAnimaShader['ImageAnima_Shader']:SetImageAnimaValue(StartU, StartV, ScaleU, ScaleV)
       return  ImageAnimaShader['ImageAnima_Shader']
    end


    local shader =  Shader.new(ImageAnimaShader.GetImageAnimaVSCodeShader(), ImageAnimaShader.GetImageAnimaPSCodeShader())

    shader.SetImageAnimaValue = function(obj, StartU, StartV, ScaleU, ScaleV)
        obj:sendValue("StartU", StartU)
        obj:sendValue("StartV", StartV)
        obj:sendValue("ScaleU", ScaleU)
        obj:sendValue("ScaleV", ScaleV)
    end
    shader:SetImageAnimaValue(StartU, StartV, ScaleU, ScaleV)
    ImageAnimaShader['ImageAnima_Shader'] = shader
    return  shader
end
 