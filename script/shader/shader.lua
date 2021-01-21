dofile('script/shader/shaderfunction.lua')
_G.__createClassFromLoveObj("Shader")
local ShaderObjects = {}
Shader.neednormal = 0
function Shader.new(pixelcode, vertexcode)
    local shader = setmetatable({}, Shader);

    shader.renderid = Render.ShaderId;
    shader.obj = love.graphics.newShader(pixelcode, vertexcode)

    return shader;
end

function Shader.GetBaseVSCodeShader()
    local vertexcode = [[
    vec4 position( mat4 transform_projection, vec4 vertex_position )
    {
        return transform_projection * vertex_position;
    }
]]

    return  vertexcode
end

function Shader.GetBasePSCodeShader()
    local pixelcode = [[
    vec4 effect( vec4 color, sampler2D tex, vec2 texture_coords, vec2 screen_coords )
    {
        vec4 texcolor = Texel(tex, texture_coords);
        return texcolor * color;
    }
]]
 

    return  pixelcode
end

function Shader.GetBaseShader()
    return  Shader.new(Shader.GetBasePSCodeShader(), Shader.GetBaseVSCodeShader())
end

function Shader.GetBaseImageShader()
    local pixelcode = [[
    uniform sampler2D baseimg;
    vec4 effect( vec4 color, sampler2D tex, vec2 texture_coords, vec2 screen_coords )
    {
        vec4 texcolor = Texel(tex, texture_coords);
        vec4 imgcolor = Texel(baseimg, texture_coords);
        return imgcolor * texcolor;
    }
]]
 
    local vertexcode = [[
    vec4 position( mat4 transform_projection, vec4 vertex_position )
    {
        return transform_projection * vertex_position;
    }
]]

   local shader = Shader.new(pixelcode, vertexcode)
   shader.setBaseImage = function(obj,img)
    obj:send('baseimg', img);
    end
   return shader
end

function Shader.GetWBlurShader(w, offset, blurnum, power)
    if not offset then offset = 1 end
    if not blurnum then offset = 5 end
    if not power then power = 1 end
    local pixelcode = [[
    uniform float w;
    uniform float offset;
    uniform int blurnum;
    uniform float power;
    vec4 effect( vec4 color, sampler2D tex, vec2 texture_coords, vec2 screen_coords )
    {
        float step = offset / w;
        vec2 coords = texture_coords;
        vec4 texcolor = Texel(tex, texture_coords);
        for(int i = -blurnum; i <= blurnum; i ++ )
        {
            coords.x = texture_coords.x + i * step;
            texcolor += Texel(tex, coords);

        }
         texcolor /= blurnum ;

        return texcolor * color * power;
    }
]]
 
    local vertexcode = [[
    vec4 position( mat4 transform_projection, vec4 vertex_position )
    {
        return transform_projection * vertex_position;
    }
]]
    local shader = Shader.new(pixelcode, vertexcode);
    assert(shader:hasUniform( "w") and shader:hasUniform( "offset") and shader:hasUniform( "blurnum") and shader:hasUniform( "power"))
    shader:send('w', w);
    shader:send('offset', offset);
    shader:send('blurnum', blurnum);
    shader:send('power', power);
    return shader;
end


function Shader.GetHBlurShader(h, offset, blurnum, power)
    if not offset then offset = 1 end
    if not blurnum then offset = 5 end
    if not power then power = 1 end
    local pixelcode = [[
    uniform float h;
    uniform float offset;
    uniform int blurnum;
    uniform float power;
    vec4 effect( vec4 color, sampler2D tex, vec2 texture_coords, vec2 screen_coords )
    {
        float step = offset / h;
        vec2 coords = texture_coords;
        vec4 texcolor = Texel(tex, texture_coords);
        for(int i = -blurnum; i <= blurnum; i ++ )
        {
            coords.y = texture_coords.y + i * step;
            texcolor += Texel(tex, coords);

        }
         texcolor /= blurnum ;

        return texcolor * color * power;
    }
]]
 
    local vertexcode = [[
    vec4 position( mat4 transform_projection, vec4 vertex_position )
    {
        return transform_projection * vertex_position;
    }
]]
    local shader = Shader.new(pixelcode, vertexcode);
    assert(shader:hasUniform( "h") and shader:hasUniform( "offset") and shader:hasUniform( "blurnum") and shader:hasUniform( "power"))
    shader:send('h', h);
    shader:send('offset', offset);
    shader:send('blurnum', blurnum);
    shader:send('power', power);
    return shader;
end

function Shader.GetBrightnessShader(l)
    if not l then
        l = 0
    end
    local pixelcode = [[
    uniform float l;
    vec4 effect( vec4 color, sampler2D tex, vec2 texture_coords, vec2 screen_coords )
    {
        vec4 texcolor = Texel(tex, texture_coords);
        vec4 basecolor = texcolor * color;
        float bl = 0.2126 * basecolor.x + 0.7152 * basecolor.y + 0.0722 * basecolor.z;
        if (bl <=l)
            discard;

        return basecolor;

    }
]]
 
    local vertexcode = [[
    vec4 position( mat4 transform_projection, vec4 vertex_position )
    {
        return transform_projection * vertex_position;
    }
]]


    local shader =   Shader.new(pixelcode, vertexcode)
    assert(shader:hasUniform( "l"))
    shader:send('l', l);
    return shader
end

function Shader.GetAddTextureHDRShader(tex1, tex2)

    local pixelcode = [[
    uniform sampler2D texture1;
    uniform sampler2D texture2;
    vec3 uncharted2_tonemap_partial(vec3 x)
    {
        float A = 0.15;
        float B = 0.50;
        float C = 0.10;
        float D = 0.20;
        float E = 0.02;
        float F = 0.30;
        return ((x*(A*x+C*B)+D*E)/(x*(A*x+B)+D*F))-E/F;
    }

    vec3 uncharted2_filmic(vec3 v)
    {
        float exposure_bias = 2.0;
        vec3 curr = uncharted2_tonemap_partial(v * exposure_bias);

        vec3 W = vec3(11.2);
        vec3 white_scale = vec3(1.0) / uncharted2_tonemap_partial(W);
        return curr * white_scale;
    }

    vec3 reinhard_extended(vec3 v, float max_white)
    {
        vec3 numerator = v * (1.0 + (v / vec3(max_white * max_white)));
        return numerator / (1.0 + v);
    }

    vec4 effect( vec4 color, sampler2D tex, vec2 texture_coords, vec2 screen_coords )
    {
        vec4 texcolor = Texel(tex, texture_coords);
        vec4 texcolor1 = Texel(texture1, texture_coords);
        vec4 texcolor2 = Texel(texture2, texture_coords);

        vec4 basecolor = texcolor * color + texcolor1 + texcolor2;

        float gamma = 2.2;
        basecolor.rgb = pow(basecolor.rgb, vec3(1.0/gamma));
        float bl = 0.2126 * basecolor.x + 0.7152 * basecolor.y + 0.0722 * basecolor.z;
        if(bl > 1)
        {
            basecolor.rgb = reinhard_extended(basecolor.rgb, 1);
        }
        
        //return texcolor1 + texcolor2;

  
        return basecolor;

    }
]]
 
    local vertexcode = [[
    vec4 position( mat4 transform_projection, vec4 vertex_position )
    {
        return transform_projection * vertex_position;
    }
]]


    local shader =   Shader.new(pixelcode, vertexcode)
    -- assert(shader:hasUniform( "texture1") and shader:hasUniform( "texture2"))
    if shader:hasUniform( "texture1") and tex1 then
        if tex1.renderid == Render.CanvasId then
            shader:send('texture1', tex1.obj);
        else
            shader:send('texture1', tex1);
        end
    end

    if shader:hasUniform( "texture2") and tex2 then
        if tex2.renderid == Render.CanvasId then
            shader:send('texture2', tex2.obj);
        else
            shader:send('texture2', tex2);
        end
    end

    return shader
end

function Shader.GetFXAAShader(w, h)
    if Shader["taa"] then
        Shader["taa"]:send('w', w)
        Shader["taa"]:send('h', h)
        return Shader["taa"]
    end
    local pixelcode = [[
    uniform float w;
    uniform float h;

    float luma(vec4 color)
    {
        return dot(color.rgb, vec3(0.299, 0.587, 0.114));
    }

    vec4 effect( vec4 color, sampler2D tex, vec2 texture_coords, vec2 screen_coords )
    {
        float offsetw = 1 / w;
        float offseth = 1 / h;
        vec4 nwolor = Texel(tex, vec2(texture_coords.x - offsetw, texture_coords.y - offseth));
        vec4 neolor = Texel(tex, vec2(texture_coords.x + offsetw, texture_coords.y - offseth));

        vec4 swolor = Texel(tex, vec2(texture_coords.x - offsetw, texture_coords.y + offseth));
        vec4 seolor = Texel(tex, vec2(texture_coords.x + offsetw, texture_coords.y + offseth));

        float nwluma = luma(nwolor);
        float neluma = luma(neolor);

        float swluma = luma(swolor);
        float seluma = luma(seolor);

        vec4 texcolor = Texel(tex, texture_coords);

        float M = luma(texcolor);
        
        float MaxLuma = max(max(nwluma, neluma), max(swluma, seluma));
        float Contrast = max(MaxLuma, M) - min(min(min(nwluma, neluma), min(swluma, seluma)), M);
        float MinThreshold = 0.05;
        float Threshold = 0.25;
       // float fxaaConsoleEdgeThreshold = 0.166f;
       // float fxaaConsoleEdgeThresholdMin = 0.0833;

        if(Contrast < max(MinThreshold, MaxLuma * Threshold))
            return texcolor * color;

        vec2 Dir = vec2((swluma + seluma) - (nwluma + neluma), (nwluma + swluma) - (neluma + seluma));
        Dir.xy = normalize(Dir.xy);

        vec4 P0 = Texel(tex, texture_coords + Dir * (0.5/w, 0.5/h));
        vec4 P1 = Texel(tex, texture_coords - Dir * (0.5/w, 0.5/h));

        float Sharpness = 8;
        float MinDir = min(abs(Dir.x), abs(Dir.y)) * Sharpness;
        vec2 NewDir = vec2(clamp(Dir.x / MinDir, -2, 2), clamp(Dir.y / MinDir, -2, 2));
        vec4 Q0 = Texel(tex, texture_coords + NewDir * (2/w, 2/h));
        vec4 Q1 = Texel(tex, texture_coords - NewDir * (2/w, 2/h));

        vec4 R0 = (P0 + P1 + Q0 + Q1) * 0.25;
        vec4 R1 = (P0 + P1) * 0.5;
        if(luma(R0) < min(min(nwluma, neluma), min(swluma, seluma)) || luma(R0) > max(max(nwluma, neluma), max(swluma, seluma)))
            return R1;
        else
            return R0;
    }
]]
 
    local vertexcode = [[
    vec4 position( mat4 transform_projection, vec4 vertex_position )
    {
        return transform_projection * vertex_position;
    }
]]

    local shader =   Shader.new(pixelcode, vertexcode)
    assert(shader:hasUniform( "w") and shader:hasUniform( "h"))
    shader:send('w', w)
    shader:send('h', h)
    Shader["taa"] = shader;
    return shader
end

function Shader.GetBase3DVSShaderCode()
    local vertexcode = ""
    
    vertexcode = vertexcode..[[
        uniform mat4 projectionMatrix;
        uniform mat4 modelMatrix;
        uniform mat4 viewMatrix; ]];
    
    if Shader.neednormal > 0 then
        vertexcode = vertexcode .. "varying vec4 vnormal; "
    end

    local directionlights = Lights.getDirectionLights()

    local needshadow = false
    if RenderSet.getshadowReceiver() then
        for i = 1, #directionlights do
            local light = directionlights[i]
            if light.node and light.node.needshadow then
                vertexcode = vertexcode .. " uniform mat4 directionlightMatrix; ";
                vertexcode = vertexcode .. "varying vec4 lightpos; "
                needshadow = true
                break
            end
        end
    end

     vertexcode = vertexcode..[[    
        vec4 position(mat4 transform_projection, vec4 vertex_position)
        {
            ]];

    if Shader.neednormal > 0 then
        vertexcode = vertexcode.."   vnormal = VertexColor; "
    end

    if needshadow and RenderSet.getshadowReceiver() then
        vertexcode = vertexcode.."   lightpos = directionlightMatrix * modelMatrix * VertexPosition; "
    end

    vertexcode = vertexcode..[[
        return projectionMatrix * viewMatrix * modelMatrix * VertexPosition;
    }


]];

    return vertexcode
end

function Shader.GetBase3DPSShaderCode()
    local pixelcode = "uniform vec4 bcolor;\n"


    --collect direction lights
    local directionlights = Lights.getDirectionLights()

    local needshadow = false
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
    end

    if Shader.neednormal > 0 then
        pixelcode = pixelcode.."varying vec4 vnormal; \n"
    end

    if needshadow  and RenderSet.getshadowReceiver() then
        pixelcode = pixelcode .. "varying vec4 lightpos;\n"
    end

    if needshadow  and RenderSet.getshadowReceiver() then
        pixelcode = pixelcode .. _G.ShaderFunction.getShadowPCFCode
        
    end

    pixelcode = pixelcode ..[[
        vec4 effect( vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords )
        {
            vec4 texcolor = Texel(tex, texture_coords) * bcolor; ]];

        if Shader.neednormal > 0 then
            pixelcode = pixelcode.."vec4 normal = normalize(vnormal); ";
        end

        if #directionlights > 0 then
            pixelcode = pixelcode .. " float dotn = 0; ";
        end
        for i = 1, #directionlights do
            local light = directionlights[i]
            pixelcode = pixelcode .. " dotn = clamp(dot(normalize(directionlight"..i..".xyz), normal.xyz), 0.1, 1); ";
            -- pixelcode = pixelcode .. " texcolor.xyz = texcolor.xyz * directionlightcolor"..i..".xyz * dotn; ";
            pixelcode = pixelcode .. " texcolor.xyz = texcolor.xyz + directionlightcolor"..i..".xyz * dotn; ";
        end

        if needshadow and RenderSet.getshadowReceiver() then
            -- log('ssssssssssss')
            pixelcode = pixelcode..[[
                float offset = 1/shadowmapsize;
                vec2 suv = lightpos.xy;;
                float shadowdepth = lightpos.z * 0.5 + 0.5;
                float shadow = getShadowPCF(suv, directionlightShadowMap, shadowdepth, shadowmapsize);
               
                texcolor.xyz *= shadow;
            ]]
        end
    

    pixelcode = pixelcode ..[[
            return texcolor;
        }
    ]];

    return pixelcode
end

function Shader.GetBase3DShader(color, projectionMatrix, modelMatrix, viewMatrix)
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
    if ShaderObjects["base3dshader".."directionlights"..#directionlights .. tostring(needshadow)] then
        return ShaderObjects["base3dshader".."directionlights"..#directionlights..tostring(needshadow)]
    end

        log(Shader.GetBase3DPSShaderCode())
    log(Shader.GetBase3DVSShaderCode())
    local shader = Shader.new(Shader.GetBase3DPSShaderCode(), Shader.GetBase3DVSShaderCode())
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
    
    shader.setCameraAndMatrix3D = function(obj, modelMatrix, projectionMatrix, viewMatrix)
        if projectionMatrix then
            obj:send('projectionMatrix', projectionMatrix)
        end
    
        if modelMatrix then
            obj:send('modelMatrix', modelMatrix)
        end
    
        if viewMatrix then
            obj:send('viewMatrix', viewMatrix)
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

        if needshadow and node.directionlightMatrix then
            if shader:hasUniform( "shadowmapsize") then
                obj:send('shadowmapsize', RenderSet.getShadowMapSize())
            end

            if shader:hasUniform( "directionlightShadowMap") then
                obj:send('directionlightShadowMap',  node.shadowmap.obj)
            end

            if shader:hasUniform( "directionlightMatrix") then
                obj:send('directionlightMatrix', node.directionlightMatrix)
            end
            
        end
    end

    ShaderObjects["base3dshader".."directionlights"..#directionlights..tostring(needshadow)] = shader
    return  shader
end

function Shader.GeDepth3DShader(projectionMatrix, modelMatrix, viewMatrix)
   local shader = ShaderObjects["base3dshader_depth"]
   if not shader then
        local pixelcode = [[
            varying float depth;
            vec4 effect( vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords )
            {
                return vec4(depth, depth, depth, 1);
            }
        ]]
    
        local vertexcode = [[
            uniform mat4 projectionMatrix;
            uniform mat4 modelMatrix;
            uniform mat4 viewMatrix;
            varying float depth;

            vec4 position(mat4 transform_projection, vec4 vertex_position)
            {
                vec4 basepos = projectionMatrix * viewMatrix * modelMatrix * VertexPosition;
                depth = basepos.z *0.5 + 0.5;
                return basepos;
            }
    ]]

        shader = Shader.new(pixelcode, vertexcode)

        shader.setCameraAndMatrix3D = function(obj, modelMatrix, projectionMatrix, viewMatrix)
            if projectionMatrix then
                obj:send('projectionMatrix', projectionMatrix)
            end
        
            if modelMatrix then
                obj:send('modelMatrix', modelMatrix)
            end
        
            if viewMatrix then
                obj:send('viewMatrix', viewMatrix)
            end
        end

        ShaderObjects["base3dshader_depth"] = shader
   end
    
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
   
    return  shader
end


function Shader.GetShadowVolumeShader(projectionMatrix, modelMatrix, viewMatrix)

    local pixelcode = [[
        vec4 effect( vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords )
        {
            
           return vec4(0,0,0,1);
        }
    ]]
 
    local vertexcode = [[
        uniform mat4 projectionMatrix;
        uniform mat4 modelMatrix;
        uniform mat4 viewMatrix;
        vec4 position(mat4 transform_projection, vec4 vertex_position)
        {
            vec4 basepos = projectionMatrix * viewMatrix * modelMatrix * VertexPosition;
            return basepos;
        }
]]

    local shader = Shader.new(pixelcode, vertexcode)
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
    
    shader.setCameraAndMatrix3D = function(obj, modelMatrix, projectionMatrix, viewMatrix)
        if projectionMatrix then
            obj:send('projectionMatrix', projectionMatrix)
        end
    
        if modelMatrix then
            obj:send('modelMatrix', modelMatrix)
        end
    
        if viewMatrix then
            obj:send('viewMatrix', viewMatrix)
        end
    end

  
    return  shader
end
