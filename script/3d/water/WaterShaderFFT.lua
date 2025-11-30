
function Shader.GetWaterFFTVSShaderCode()
    local vertexcode = ""
    
    vertexcode = vertexcode..[[
        uniform mat4 projectionMatrix;
        uniform mat4 modelMatrix;
        uniform mat4 viewMatrix; 
        ]];
    
    local normalmap = RenderSet.getNormalMap()
    if not normalmap and Shader.neednormal > 0 then
        vertexcode = vertexcode .. "varying vec4 vnormal;\n"
    end
    vertexcode = vertexcode .. "varying vec4 modelpos; \n"
    vertexcode = vertexcode .. "varying vec2 vTexCoord2; \n"
    vertexcode = vertexcode .. "varying float waterheight; \n"

    vertexcode = vertexcode .. _G.ShaderFunction.GetNoise

    vertexcode = vertexcode .. _G.ShaderFunction.GetTTF

    vertexcode = vertexcode..[[    
        vec4 position(mat4 transform_projection, vec4 vertex_position)
        {
            ]];

    if not normalmap and Shader.neednormal > 0 then
        vertexcode = vertexcode.."   vnormal = VertexColor;\n "
    end

    vertexcode = vertexcode.." vec4 vpos = VertexPosition; \n"
    --vertexcode = vertexcode.." vec2 twiddlev = twiddle(VertexColor.x, VertexColor.y, ConstantColor.xy, ConstantColor.zw, tvalue, 0.98); \n"
    --vertexcode = vertexcode.." vpos.z = 2 * pow(clamp((sin((VertexColor.x + VertexColor.y) * invWaveLength + tvalue) + 1) * 0.5, 0, 1), kvalue) * amplitude; \n"
   -- vertexcode = vertexcode.." vpos.z = twiddlev.x; \n"
    vertexcode = vertexcode.." waterheight = vpos.z; \n"
    vertexcode = vertexcode.." vec4 wpos = projectionMatrix * viewMatrix * modelMatrix * vpos; \n"
    vertexcode = vertexcode.." modelpos =  modelMatrix * vpos; \n"
    vertexcode = vertexcode.." vTexCoord2 =  VertexTexCoord.xy; \n"
  
    vertexcode = vertexcode..[[
        
        return wpos;
    }


]];

    return vertexcode
end

function Shader.GetWaterFFTPSShaderCode()
    local pixelcode = "uniform vec4 bcolor;\n"
    pixelcode = pixelcode .. " uniform vec3 camerapos;  \n";

    --collect direction lights
    local directionlights = Lights.getDirectionLights()

    local needshadow = false
    local IsHasShadow = false
    for i = 1, #directionlights do
        local light = directionlights[i]
        pixelcode = pixelcode .. " uniform vec4 directionlight"..i..";  \n";
        pixelcode = pixelcode .. " uniform vec4 directionlightcolor"..i..";  \n";
    end

    local normalmap = RenderSet.getNormalMap()
    if normalmap then
        pixelcode = pixelcode .. " uniform sampler2D normalmap;  \n";
    elseif Shader.neednormal > 0 then
        pixelcode = pixelcode.."varying vec4 vnormal; \n"
    end

    pixelcode = pixelcode .. "uniform sampler2D watermap;\n";
    -- pixelcode = pixelcode .. "uniform sampler2D waternoisemap;\n";
    -- pixelcode = pixelcode .. "uniform float amplitude;\n"
    -- pixelcode = pixelcode .. " uniform float tvalue;\n"
    pixelcode = pixelcode .. "varying  vec4 modelpos; \n"
    pixelcode = pixelcode .. "varying vec2 vTexCoord2; \n"
    pixelcode = pixelcode .. "varying float waterheight; \n"
    
    -- if RenderSet.GetPBR() then
    --     pixelcode = pixelcode .. _G.ShaderFunction.GetPBRCode
    -- end

    pixelcode = pixelcode ..[[
        vec4 effect( vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords )
        {
            float Gloss = 1;
            vec4 texcolor = Texel(watermap, vTexCoord2) * bcolor;
            vec3 viewdir = normalize( camerapos.xyz - modelpos.xyz);
            ]];

            if normalmap then
                pixelcode = pixelcode .. "vec4 normal = (texture2D(normalmap, texture_coords) - vec4(0.5, 0.5, 0.5, 0.5)) * 2;\n";
            elseif Shader.neednormal > 0 then
                pixelcode = pixelcode.."vec4 normal = normalize(vnormal);\n";
            end

            -- pixelcode = pixelcode ..[[
            --     if(amplitude * 1.95 <= waterheight)
            --     {
            --         vec4 waternoise = texture2D(waternoisemap, vTexCoord2.xy);
            --         normal.z = waternoise.z;
            --        // texcolor.x += waternoise.x;
            --     }
                
            --     ]]
        if #directionlights > 0 then
            pixelcode = pixelcode .. " float dotn = 0; \n";
            pixelcode = pixelcode .. " vec3 lightDir;\n ";
        end
        for i = 1, #directionlights do
            local light = directionlights[i]
            pixelcode = pixelcode .. " lightDir = directionlight"..i..".xyz;\n ";
            pixelcode = pixelcode ..[[
                dotn = clamp(dot(normalize(lightDir + viewdir.xyz), normal.xyz), 0.1, 1);
                vec3 reflectDir = normalize(reflect(-lightDir.xyz, normal.xyz)); 
                ]]

            -- pixelcode = pixelcode .. " texcolor.xyz = texcolor.xyz * directionlightcolor"..i..".xyz * dotn; ";
            if RenderSet.GetPBR() then

                pixelcode = pixelcode .. " vec3 pbr = ".._G.ShaderFunction.PBRFunctionName.."(1, 1, texcolor.xyz, viewdir.xyz, normalize(directionlight"..i..".xyz), normal.xyz);\n";
            else
                pixelcode = pixelcode .. " vec3 pbr = vec3(1);\n";
            end
            
            pixelcode = pixelcode .. " texcolor.xyz = texcolor.xyz + pbr * directionlightcolor"..i..".xyz *  pow(max(dot(reflectDir.xyz, viewdir.xyz), 0),Gloss);\n ";
        end    

    pixelcode = pixelcode ..[[
            return texcolor;
        }
    ]];

    return pixelcode
end

function Shader.GetWaterFFTShader(color, projectionMatrix, modelMatrix, viewMatrix)
    local directionlights = Lights.getDirectionLights()
    
    local normalmap = RenderSet.getNormalMap()
    local shader = ShaderObjects["waterFFTshader".."directionlights"..#directionlights.. (normalmap and "normalmap" or "") ..  (RenderSet.GetPBR() and "PBR" or "")]
    if shader then
        if shader:hasUniform("normalmap") then
            shader:send("normalmap", normalmap.obj)
        end
        return shader
    end

    -- log(Shader.GetWaterFFTVSShaderCode())
    -- log()
    -- log(Shader.GetWaterFFTPSShaderCode())
    shader = Shader.new(Shader.GetWaterFFTPSShaderCode(), Shader.GetWaterFFTVSShaderCode())
    assert(shader:hasUniform( "projectionMatrix") and shader:hasUniform( "modelMatrix") and shader:hasUniform( "viewMatrix"))
    if projectionMatrix then
        shader:send('projectionMatrix', projectionMatrix)
    end

    if modelMatrix then
        shader:send('modelMatrix', modelMatrix)
    end

    if viewMatrix then
        shader:send('viewMatrix', viewMatrix)
    end

    if not color then
        shader:send('bcolor', {1,1,1,1})
    else
        shader:send('bcolor', {color._r,color._g, color._b, color._a})
    end
    
    shader.setCameraAndMatrix3D = function(obj, modelMatrix, projectionMatrix, viewMatrix, camerapos)
        if projectionMatrix then
            obj:send('projectionMatrix', projectionMatrix)
        end
    
        if modelMatrix then
            obj:send('modelMatrix', modelMatrix)
        end
    
        if viewMatrix then
            obj:send('viewMatrix', viewMatrix)
        end

        if camerapos and obj:hasUniform( "camerapos")  then
            obj:send('camerapos', {camerapos.x, camerapos.y, camerapos.z})
        end
    end


    shader.setWaterValue = function(obj, watermap) -- amplitude, kvalue, tvalue, invWaveLength, waternoisemap
        if watermap and obj:hasUniform("watermap") then
            obj:send('watermap', watermap)
        end

        -- if kvalue and obj:hasUniform("kvalue") then
        --     obj:send('kvalue', kvalue)
        -- end
    
        -- if tvalue and obj:hasUniform("tvalue") then
        --     obj:send('tvalue', tvalue)
        -- end

        -- if amplitude and obj:hasUniform("amplitude") then
        --     obj:send('amplitude', amplitude)
        -- end

        -- if invWaveLength and obj:hasUniform("invWaveLength") then
        --     obj:send('invWaveLength', invWaveLength)
        -- end

        -- if waternoisemap and obj:hasUniform("waternoisemap") then
        --     obj:send('waternoisemap', waternoisemap)
        -- end
    end

    ShaderObjects["waterFFTshader".."directionlights"..#directionlights.. (normalmap and "normalmap" or "") ..  (RenderSet.GetPBR() and "PBR" or "")] = shader
    return  shader
end
