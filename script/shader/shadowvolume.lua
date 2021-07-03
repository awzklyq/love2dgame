
function Shader.GetShadowVolumeShader(projectionMatrix, viewMatrix, modelMatrix)

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
