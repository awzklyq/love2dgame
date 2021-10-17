
function Shader.GetBase3DVSShaderCode(AlphaTest)
    local vertexcode = ""
    
    vertexcode = vertexcode..[[
        uniform mat4 projectionMatrix;
        uniform mat4 modelMatrix;
        uniform mat4 viewMatrix; ]];
    
    local normalmap = RenderSet.getNormalMap()
    if not normalmap and Shader.neednormal > 0 then
        vertexcode = vertexcode .. "varying vec4 vnormal;\n"
    end
    vertexcode = vertexcode .. "varying vec4 modelpos; \n"
    local directionlights = Lights.getDirectionLights()

    local needshadow = false
    if RenderSet.getshadowReceiver() then
        for i = 1, #directionlights do
            local light = directionlights[i]
            if light.node and light.node.needshadow then
                if  GConfig.CSMNumber > 1 then
                    vertexcode = vertexcode .. "varying float CameraDistance; \n"
                end
                needshadow = true
                break
            end
        end
    end

    if AlphaTest then
        if RenderSet.AlphaTestMode == 1 then
            vertexcode = vertexcode .. " varying float VDepth;  \n";
        end
        -- pixelcode = pixelcode .. " const float Bias = 0.000001; \n"--1e-4
    end
     vertexcode = vertexcode..[[    
        vec4 position(mat4 transform_projection, vec4 vertex_position)
        {
            ]];

    if not normalmap and Shader.neednormal > 0 then
        vertexcode = vertexcode.."   vnormal = VertexColor;\n "
    end

    vertexcode = vertexcode.." vec4 wpos = projectionMatrix * viewMatrix * modelMatrix * VertexPosition; \n"
    vertexcode = vertexcode.." modelpos =  modelMatrix * VertexPosition; \n"
    -- vertexcode = vertexcode.." modelpos.z =  modelpos.z / modelpos.w; \n"
    if needshadow and RenderSet.getshadowReceiver() then
        if  GConfig.CSMNumber >= 2 then
            vertexcode = vertexcode.." CameraDistance = wpos.z; \n"
        end
    
    end

    if AlphaTest then
        if RenderSet.AlphaTestMode == 1 then
            vertexcode = vertexcode .. " VDepth = wpos.z / wpos.w * 0.5 + 0.5; \n";
        end
        -- pixelcode = pixelcode .. " const float Bias = 0.000001; \n"--1e-4
    end
    vertexcode = vertexcode..[[
        
        return wpos;
    }


]];

    return vertexcode
end

function Shader.GetBase3DPSShaderCode(AlphaTest)
    local pixelcode = "uniform vec4 bcolor;\n"
    pixelcode = pixelcode .. " uniform vec3 camerapos;  \n";

    if AlphaTest then
        if RenderSet.AlphaTestMode == 1 then
            pixelcode = pixelcode .. " uniform sampler2D DepthTexture;  \n"
        end

        pixelcode = pixelcode .. " uniform sampler2D AlphaColorTexture;  \n"
        pixelcode = pixelcode .. " uniform float BlendCoef; \n"
        -- pixelcode = pixelcode .. " const float Bias = 0.000001; \n"--1e-4
    end
    --collect direction lights
    local directionlights = Lights.getDirectionLights()

    local needshadow = false
    local IsHasShadow = false
    for i = 1, #directionlights do
        local light = directionlights[i]
        pixelcode = pixelcode .. " uniform vec4 directionlight"..i..";  \n";
        pixelcode = pixelcode .. " uniform vec4 directionlightcolor"..i..";  \n";
        if RenderSet.getshadowReceiver() and needshadow == false and light.node and light.node.needshadow then
            -- pixelcode = pixelcode .. " uniform mat4 directionlightMatrix; ";
            pixelcode = pixelcode .. " uniform sampler2D directionlightShadowMap;  \n";
            pixelcode = pixelcode .. " uniform float shadowmapsize;  \n";
            needshadow = true
        end

        if needshadow and IsHasShadow == false then
            if GConfig.CSMNumber <= 1 then
                pixelcode = pixelcode .. " uniform mat4 directionlightMatrix;\n";
            elseif  GConfig.CSMNumber == 2 then
                pixelcode = pixelcode .. " uniform mat4 CSMMatrix1;\n";
                pixelcode = pixelcode .. " uniform mat4 CSMMatrix2;\n";

                pixelcode = pixelcode .. " uniform float CSMDistance1;\n";
                pixelcode = pixelcode .. " uniform float CSMDistance2;\n";
            elseif  GConfig.CSMNumber == 3 then
                pixelcode = pixelcode .. " uniform mat4 CSMMatrix1;\n";
                pixelcode = pixelcode .. " uniform mat4 CSMMatrix2;\n";
                pixelcode = pixelcode .. " uniform mat4 CSMMatrix3;\n";

                pixelcode = pixelcode .. " uniform float CSMDistance1;\n";
                pixelcode = pixelcode .. " uniform float CSMDistance2;\n";
                pixelcode = pixelcode .. " uniform float CSMDistance3;\n";
            elseif  GConfig.CSMNumber == 4 then
                pixelcode = pixelcode .. " uniform mat4 CSMMatrix1;\n";
                pixelcode = pixelcode .. " uniform mat4 CSMMatrix2;\n";
                pixelcode = pixelcode .. " uniform mat4 CSMMatrix3;\n";
                pixelcode = pixelcode .. " uniform mat4 CSMMatrix4;\n";

                pixelcode = pixelcode .. " uniform float CSMDistance1;\n";
                pixelcode = pixelcode .. " uniform float CSMDistance2;\n";
                pixelcode = pixelcode .. " uniform float CSMDistance3;\n";
                pixelcode = pixelcode .. " uniform float CSMDistance4;\n";
            end

            if  GConfig.CSMNumber > 1 then 
                pixelcode = pixelcode .. "varying float CameraDistance; \n"
            end
            IsHasShadow = true
        end
    end

    local normalmap = RenderSet.getNormalMap()
    if normalmap then
        pixelcode = pixelcode .. " uniform sampler2D normalmap;  \n";
    elseif Shader.neednormal > 0 then
        pixelcode = pixelcode.."varying vec4 vnormal; \n"
    end

    pixelcode = pixelcode .. "varying  vec4 modelpos; \n"

    if needshadow  and RenderSet.getshadowReceiver() then
        pixelcode = pixelcode .. "varying  vec4 lightpos;\n"
    end

    if AlphaTest then
        if RenderSet.AlphaTestMode == 1 then
            pixelcode = pixelcode .. " varying float VDepth;  \n";
            -- pixelcode = pixelcode .. " const float Bias = 0.000001; \n"--1e-4
        end
    end

    if needshadow  and RenderSet.getshadowReceiver() then
        pixelcode = pixelcode .. _G.ShaderFunction.getShadowPCFCode
    end

    if RenderSet.GetPBR() then
        pixelcode = pixelcode .. _G.ShaderFunction.GetPBRCode
    end

    pixelcode = pixelcode ..[[
        vec4 effect( vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords )
        {
            vec4 texcolor = Texel(tex, texture_coords) * bcolor;
            vec3 viewdir = normalize( camerapos.xyz - modelpos.xyz);
            ]];

            if AlphaTest then
                if RenderSet.AlphaTestMode == 1 then
                    pixelcode = pixelcode ..[[
                        float Bias = 0.00000001;//1e-4
                        vec2 scoords = vec2(gl_FragCoord.x / love_ScreenSize.x, gl_FragCoord.y / love_ScreenSize.y );
                        if(VDepth <=Texel(DepthTexture,scoords).r+Bias)
                        {
                            discard;
                            //texcolor.xyzw = vec4(1,1,1,1); 
                        }
                            
                    ]]
                end
            end
            if normalmap then
                pixelcode = pixelcode .. "vec4 normal = (texture2D(normalmap, texture_coords) - vec4(0.5, 0.5, 0.5, 0.5)) * 2;\n";
            elseif Shader.neednormal > 0 then
                pixelcode = pixelcode.."vec4 normal = normalize(vnormal);\n";
            end

        if #directionlights > 0 then
            pixelcode = pixelcode .. " float dotn = 0; \n";
        end
        for i = 1, #directionlights do
            local light = directionlights[i]
            pixelcode = pixelcode .. " dotn = clamp(dot(normalize(directionlight"..i..".xyz), normal.xyz), 0.1, 1);\n ";
            -- pixelcode = pixelcode .. " texcolor.xyz = texcolor.xyz * directionlightcolor"..i..".xyz * dotn; ";
            if RenderSet.GetPBR() then

                pixelcode = pixelcode .. " vec3 pbr = ".._G.ShaderFunction.PBRFunctionName.."(1, 1, texcolor.xyz, viewdir.xyz, normalize(directionlight"..i..".xyz), normal.xyz);\n";
            else
                pixelcode = pixelcode .. " vec3 pbr = vec3(1);\n";
            end
            
            pixelcode = pixelcode .. " texcolor.xyz = texcolor.xyz + pbr * directionlightcolor"..i..".xyz * dotn;\n ";
        end

        if needshadow and RenderSet.getshadowReceiver() then
            pixelcode = pixelcode .. "vec4 lightpos;\n"
            
            if  GConfig.CSMNumber <= 1 then
                pixelcode = pixelcode..[[    
                    lightpos = directionlightMatrix * modelpos; 
                        ]];
            elseif  GConfig.CSMNumber == 2 then
                pixelcode = pixelcode..[[    
                    if(CameraDistance <= CSMDistance1)
                    {
                        lightpos = CSMMatrix1 * modelpos; 
                    }
                    else
                    {
                        lightpos = CSMMatrix2 * modelpos; 
                    }
                        ]];
            elseif  GConfig.CSMNumber == 3 then
                pixelcode = pixelcode..[[    
                    if(CameraDistance <= CSMDistance1 )
                    {
                        lightpos = CSMMatrix1 * modelpos; 
                    }
                    else if(CameraDistance <= CSMDistance2)
                    {
                        lightpos = CSMMatrix2 * modelpos; 
                    }
                    else
                    {
                        lightpos = CSMMatrix3 * modelpos; 
                    }
                
                        ]];
            elseif  GConfig.CSMNumber == 4 then
                pixelcode = pixelcode..[[    
                    if(CameraDistance <= CSMDistance1 )
                    {
                        lightpos = CSMMatrix1 * modelpos; 
                    }
                    else if(CameraDistance <= CSMDistance2)
                    {
                        lightpos = CSMMatrix2 * modelpos; 
                    }
                    else if(CameraDistance <= CSMDistance3)
                    {
                        lightpos = CSMMatrix3 * modelpos; 
                    }
                    else
                    {
                        lightpos = CSMMatrix4 * modelpos; 
                    }
                        ]];
            end
            pixelcode = pixelcode..[[
                float offset = 1/shadowmapsize;
                vec2 suv = lightpos.xy;// * 0.5 + vec2(0.5, 0.5);
                float shadowdepth = lightpos.z;// * 0.5 + 0.5;
                float shadow = getShadowPCF(suv, directionlightShadowMap, shadowdepth, shadowmapsize);
               
                texcolor.xyz *= shadow;
            ]]

            
        end
        if AlphaTest then
            if RenderSet.AlphaTestMode == 1 then
                pixelcode = pixelcode .. [[
                    //texcolor = vec4(texcolor.xyz*BlendCoef+Texel(AlphaColorTexture, texture_coords).rgb*( 1.0 - BlendCoef), BlendCoef);
                    texcolor = vec4(texcolor.xyz*(texcolor.w)+Texel(AlphaColorTexture, texture_coords).rgb*(1.0 - texcolor.w), texcolor.w);
                ]]
            elseif RenderSet.AlphaTestMode == 2 then
                pixelcode = pixelcode .. [[
                    //texcolor = vec4(texcolor.xyz*(1.0-BlendCoef)+Texel(AlphaColorTexture, texture_coords).rgb*BlendCoef, BlendCoef);
                    texcolor = vec4(texcolor.xyz*(texcolor.w)+Texel(AlphaColorTexture, texture_coords).rgb*(1.0 - texcolor.w), texcolor.w);
                ]]
            end
        end

    pixelcode = pixelcode ..[[
            return texcolor;
        }
    ]];

    return pixelcode
end

function Shader.GetBase3DShader(color, projectionMatrix, modelMatrix, viewMatrix, AlphaTest)
    local directionlights = Lights.getDirectionLights()
    local needshadow = false
    if RenderSet.getshadowReceiver() then

        for i = 1, #directionlights do
            local light = directionlights[i]
            if light.node and light.node.needshadow then
                needshadow = true
                
                break
            end
        end 
    end

    local normalmap = RenderSet.getNormalMap()

    local shader = ShaderObjects["base3dshader".."directionlights"..#directionlights..tostring(needshadow).. (normalmap and "normalmap" or "") ..  (RenderSet.GetPBR() and "PBR" or "") .. (AlphaTest and "AlphaTest" or "nil") .. tostring(RenderSet.AlphaTestMode)]
    if shader then
        if shader:hasUniform("normalmap") then
            shader:send("normalmap", normalmap.obj)
        end
        return shader
    end

    -- log(Shader.GetBase3DPSShaderCode())
    shader = Shader.new(Shader.GetBase3DPSShaderCode(AlphaTest), Shader.GetBase3DVSShaderCode(AlphaTest))
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

    shader.setShadowParam = function(obj)
        if not RenderSet.getshadowReceiver() then return end
        local needshadow = false
        local node
        for i = 1, #directionlights do
            local light = directionlights[i]
            if light.node and light.node.needshadow then
                needshadow = true
                node = light.node
                break
            end
        end

        if needshadow and (node.directionlightMatrix or #node.CSMMatrix > 0)then
            if shader:hasUniform( "shadowmapsize") then
                obj:send('shadowmapsize', RenderSet.getShadowMapSize())
            end

            if shader:hasUniform( "directionlightShadowMap") then
                obj:send('directionlightShadowMap',  node.shadowmap.obj)
            end

            if _G.GConfig.CSMNumber <= 1 then
                if shader:hasUniform( "directionlightMatrix") then
                    obj:send('directionlightMatrix', node.directionlightMatrix)
                end
            elseif   _G.GConfig.CSMNumber == 2 then
                if shader:hasUniform( "CSMMatrix1") then
                   
                    obj:send('CSMMatrix1', node.CSMMatrix[1])
                end

                if shader:hasUniform( "CSMMatrix2") then
                    obj:send('CSMMatrix2', node.CSMMatrix[2])
                end

                if shader:hasUniform( "CSMDistance1") then
                    obj:send('CSMDistance1', node.CSMDistance[1])
                end

                if shader:hasUniform( "CSMDistance2") then
                    obj:send('CSMDistance2', node.CSMDistance[2])
                end
            elseif   _G.GConfig.CSMNumber == 3 then
                if shader:hasUniform( "CSMMatrix1") then
                    obj:send('CSMMatrix1', node.CSMMatrix[1])
                end

                if shader:hasUniform( "CSMMatrix2") then
                    obj:send('CSMMatrix2', node.CSMMatrix[2])
                end

                if shader:hasUniform( "CSMMatrix3") then
                    obj:send('CSMMatrix3', node.CSMMatrix[3])
                end

                if shader:hasUniform( "CSMDistance1") then
                    obj:send('CSMDistance1', node.CSMDistance[1])
                end

                if shader:hasUniform( "CSMDistance2") then
                    obj:send('CSMDistance2', node.CSMDistance[2])
                end

                if shader:hasUniform( "CSMDistance3") then
                    obj:send('CSMDistance3', node.CSMDistance[3])
                end
            elseif   _G.GConfig.CSMNumber == 4 then
                if shader:hasUniform( "CSMMatrix1") then
                    obj:send('CSMMatrix1', node.CSMMatrix[1])
                end

                if shader:hasUniform( "CSMMatrix2") then
                    obj:send('CSMMatrix2', node.CSMMatrix[2])
                end

                if shader:hasUniform( "CSMMatrix3") then
                    obj:send('CSMMatrix3', node.CSMMatrix[3])
                end

                if shader:hasUniform( "CSMMatrix4") then
                    obj:send('CSMMatrix4', node.CSMMatrix[4])
                end

                if shader:hasUniform( "CSMDistance1") then
                    obj:send('CSMDistance1', node.CSMDistance[1])
                end

                if shader:hasUniform( "CSMDistance2") then
                    obj:send('CSMDistance2', node.CSMDistance[2])
                end

                if shader:hasUniform( "CSMDistance3") then
                    obj:send('CSMDistance3', node.CSMDistance[3])
                end

                if shader:hasUniform( "CSMDistance4") then
                    obj:send('CSMDistance4', node.CSMDistance[4])
                end
            end
            
            
        end
    end

    shader.SetAlpahTestValue = function(obj, DepthTexture, ColorTexture, BlendCoef)
        if DepthTexture and DepthTexture.obj and obj:hasUniform( "DepthTexture") then
            obj:send('DepthTexture', DepthTexture.obj)
        end

        if ColorTexture and ColorTexture.obj and obj:hasUniform("AlphaColorTexture") then
            obj:send('AlphaColorTexture', ColorTexture.obj)
        end

        if BlendCoef and obj:hasUniform("BlendCoef") then
            obj:send("BlendCoef", BlendCoef)
        end
    end

    ShaderObjects["base3dshader".."directionlights"..#directionlights..tostring(needshadow).. (normalmap and "normalmap" or "") ..  (RenderSet.GetPBR() and "PBR" or "").. (AlphaTest and "AlphaTest" or "nil").. tostring(RenderSet.AlphaTestMode)] = shader
    return  shader
end
