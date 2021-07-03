_G.__createClassFromLoveObj("Shader")
_G.ShaderObjects = {}
_G.ShaderFunction = {}

dofile('script/shader/pcf.lua')
dofile('script/shader/ssao.lua')
dofile('script/shader/blur.lua')
dofile('script/shader/fxaa.lua')
dofile('script/shader/hdr.lua')
dofile('script/shader/shadowvolume.lua')
dofile('script/shader/line3d.lua')
dofile('script/shader/pbr.lua')
dofile('script/shader/mesh3d.lua')

Shader.neednormal = 1
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

function Shader.GeDepth3DShader(projectionMatrix, modelMatrix, viewMatrix)
   local shader = ShaderObjects["base3dshader_depth"]
   if shader then
        return shader
   end
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
                depth = basepos.z / basepos.w * 0.5 + 0.5;
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

function Shader.GeNormal3DShader(projectionMatrix, viewMatrix, modelMatrix)
    local normalmap = RenderSet.getNormalMap()

    local shader = ShaderObjects["normalshader" .. (normalmap and "map" or "")]
    if shader then
        
        if normalmap and shader:hasUniform("normalmap") then
            shader:send("normalmap", normalmap.obj)
        end
        return shader
    end

    local pixelcode = ""
    if normalmap then
        pixelcode = pixelcode .. " uniform sampler2D normalmap;  \n";
    elseif Shader.neednormal > 0 then
        pixelcode = pixelcode.."varying vec4 vnormal; \n"
    end
    
    pixelcode = pixelcode .. [[
        vec4 effect( vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords )
        {
            ]]

        if normalmap then
            --pixelcode = pixelcode .. "vec4 normal = (texture2D(normalmap, texture_coords) - vec4(0.5, 0.5, 0.5, 0.5)) * 2;\n";
            pixelcode = pixelcode .. "vec4 normal = texture2D(normalmap, texture_coords);\n";
        elseif Shader.neednormal > 0 then
            pixelcode = pixelcode.."vec4 normal = normalize(vnormal);\n";
            
        else
            pixelcode = pixelcode.."vec4 normal = vec4(0 ,0, 0, 0); \n"
        end
    pixelcode = pixelcode .. [[
        return vec4(normal.x, normal.y, normal.z,1);
        }
    ]]

    local vertexcode = [[
        uniform mat4 projectionMatrix;
        uniform mat4 modelMatrix;
        uniform mat4 viewMatrix; ]]

    if not normalmap and Shader.neednormal > 0 then
        vertexcode = vertexcode .. "varying vec4 vnormal; \n"
    end
    vertexcode = vertexcode .. "\n"
    vertexcode = vertexcode..[[
        vec4 position(mat4 transform_projection, vec4 vertex_position)
        {
            ]]
    if not normalmap and Shader.neednormal > 0 then
        vertexcode = vertexcode.."   vnormal = VertexColor;\n"
    end

    vertexcode = vertexcode..[[
            vec4 basepos = projectionMatrix * viewMatrix * modelMatrix * VertexPosition;
            return basepos;
        }
    ]]

    -- log(vertexcode)
    -- log(pixelcode)
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

    ShaderObjects["normalshader" .. (normalmap and "map" or "")] = shader
    
     
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
