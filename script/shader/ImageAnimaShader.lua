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

function ImageAnimaShader.GetImageAnimaPSCodeShader_IncludeFlowMap()
    local pixelcode = [[
    uniform float StartU;
    uniform float StartV;
    uniform float ScaleU;
    uniform float ScaleV;

    uniform float NextU;
    uniform float NextV;
    uniform sampler2D FlowMap;
    uniform float FlowTime;
    vec4 effect( vec4 color, sampler2D tex, vec2 texture_coords, vec2 screen_coords )
    {
        vec2 uv = vec2(StartU, StartV) + texture_coords * vec2(ScaleU, ScaleV);

        vec2 flowvalue1 = texture2D(FlowMap, uv).rg;
        
        vec2 nextuv = vec2(NextU, NextV) + texture_coords * vec2(ScaleU, ScaleV);
        vec2 flowvalue2 = texture2D(FlowMap, nextuv).rg;

        vec2 Temp = vec2(127.0 / 255.0, 128.0 / 255.0);
       
        vec4 texcolor;
        float power = 0.2;
        if(FlowTime < 1)
        {
            flowvalue1 -= Temp;

            if(abs(flowvalue1.x) > 0.01)
            {
                uv.x -= flowvalue1.x * FlowTime * power;
            }
    
            if(abs(flowvalue1.y) > 0.01)
            {
                uv.y -= flowvalue1.y * FlowTime * power;
            }
            
            texcolor = texture2D(tex, uv);
        }
        else
        {
            flowvalue2 -= Temp;
            if(abs(flowvalue2.x) > 0.01)
            {
                nextuv.x += flowvalue2.x * (1.0 - FlowTime) * power;
            }
    
            if(abs(flowvalue2.y) > 0.01)
            {
                nextuv.y += flowvalue2.y * (1.0 - FlowTime) * power;
            }
            
            texcolor = texture2D(tex, nextuv);
        }
        
        return (texcolor ) * color;
    }
]]

    return pixelcode
end

function ImageAnimaShader.GetImageAnimaShader(StartU, StartV, ScaleU, ScaleV, FlowMap, FlowMapTime, NextU, NextV)
    local shaderindex = 'ImageAnima_Shader' .. tostring(FlowMap and "FlowMap" .. 'None')
    if ImageAnimaShader[shaderindex] then
        ImageAnimaShader[shaderindex]:SetImageAnimaValue(StartU, StartV, ScaleU, ScaleV, FlowMap, FlowMapTime, NextU, NextV)
       return  ImageAnimaShader[shaderindex]
    end

    local shader =  Shader.new(ImageAnimaShader.GetImageAnimaVSCodeShader(), FlowMap and ImageAnimaShader.GetImageAnimaPSCodeShader_IncludeFlowMap() or ImageAnimaShader.GetImageAnimaPSCodeShader())
    shader.SetImageAnimaValue = function(obj, StartU, StartV, ScaleU, ScaleV, FlowMap, FlowMapTime, NextU, NextV)
        obj:sendValue("StartU", StartU)
        obj:sendValue("StartV", StartV)
        obj:sendValue("ScaleU", ScaleU)
        obj:sendValue("ScaleV", ScaleV)

        obj:sendValue("FlowMap", FlowMap)
        obj:sendValue("FlowTime", FlowMapTime)

        obj:sendValue("NextU", NextU)
        obj:sendValue("NextV", NextV)
    end
    shader:SetImageAnimaValue(StartU, StartV, ScaleU, ScaleV)
    ImageAnimaShader[shaderindex] = shader
    return  shader
end
 