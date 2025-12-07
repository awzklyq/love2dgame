
function Shader.GetWaterFFTVSShaderCode()
    local vertexcode = ""
    
    vertexcode = vertexcode..[[
        uniform mat4 projectionMatrix;
        uniform mat4 modelMatrix;
        uniform mat4 viewMatrix; 
        uniform vec3 camerapos;
        ]];
    
    local normalmap = RenderSet.getNormalMap()
    if not normalmap and Shader.neednormal > 0 then
        vertexcode = vertexcode .. "varying vec4 vnormal;\n"
    end

    vertexcode = vertexcode..[[
        varying vec3 vViewdir;
        varying vec2 vTexCoord2;
        varying float waterheight;
    ]]
    vertexcode = vertexcode .. _G.ShaderFunction.GetNoise

    vertexcode = vertexcode .. _G.ShaderFunction.GetTTF

    vertexcode = vertexcode..[[    
        vec4 position(mat4 transform_projection, vec4 vertex_position)
        {
            ]];

    if not normalmap and Shader.neednormal > 0 then
        vertexcode = vertexcode.."   vnormal = VertexColor;\n "
    end
  
    vertexcode = vertexcode..[[
        vec4 vpos = VertexPosition;
        waterheight = vpos.z;
        vec4 wpos = projectionMatrix * viewMatrix * modelMatrix * vpos;
        vec4 modelpos =  modelMatrix * vpos;
        vViewdir = normalize(camerapos.xyz);
        vTexCoord2 =  VertexTexCoord.xy; 
        return wpos;
    }


]];

    return vertexcode
end

function Shader.GetWaterFFTPSShaderCode()
    local pixelcode = "uniform vec4 bcolor;\n"

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
    pixelcode = pixelcode .. "varying  vec3 vViewdir; \n"
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
            vec3 viewdir =  vViewdir.xyz;
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
            pixelcode = pixelcode .. " vec3 lightDir;\n ";
            pixelcode = pixelcode .. " vec3 lightcolor;\n "
            pixelcode = pixelcode .. " float dotn = 0.0;\n "
        end
        for i = 1, #directionlights do
            local light = directionlights[i]
            pixelcode = pixelcode .. " lightDir = directionlight"..i..".xyz;\n ";
            pixelcode = pixelcode .. " lightcolor = directionlightcolor"..i..".xyz;\n ";
            pixelcode = pixelcode ..[[
                dotn = clamp(dot(-lightDir, normal.xyz), 0.1, 2.0);
                vec3 specular = lightcolor * pow(clamp(dot(normalize(lightDir + viewdir.xyz), normal.xyz), 0.1, 5.0), 0.7);
                ]]

            pixelcode = pixelcode .. " texcolor.xyz = texcolor.xyz * lightcolor * dotn + specular;\n ";
        end    

    pixelcode = pixelcode ..[[
            return texcolor;
        }
    ]];

    -- log(pixelcode)
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
