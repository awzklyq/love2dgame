
function Shader.GetLines3DShader(projectionMatrix, viewMatrix, modelMatrix)
    local shader = Shader['lines3d']
    if shader then
        shader.setCameraAndMatrix3D(shader, modelMatrix, projectionMatrix, viewMatrix)
        return shader
    end
    local pixelcode = [[
        uniform vec4 bcolor;
        vec4 effect( vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords )
        {
            
           return color * bcolor;
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

    shader = Shader.new(pixelcode, vertexcode)
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

    Shader['lines3d'] = shader
    return shader
end