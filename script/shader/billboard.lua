
function Shader.GetBillBoardBaseShader(projectionMatrix, modelMatrix, viewMatrix)
    local shader = ShaderObjects["shader_BillBoardBase"]
    if shader then
         return shader
    end
    if not shader then
         local pixelcode = [[
            uniform float AlphaValua;
             vec4 effect( vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords )
             {
                vec4 BaseColor = texture2D(tex, texture_coords);
                BaseColor.a *= AlphaValua;
                return BaseColor;
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
 
         shader.SetBillboardValue = function(obj, AlphaValua)
            obj:sendValue("AlphaValua", AlphaValua)
        end

         shader.setCameraAndMatrix3D = function(obj, modelMatrix, projectionMatrix, viewMatrix, mesh)
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
 
         ShaderObjects["shader_BillBoardBase"] = shader
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