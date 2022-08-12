
function Shader.GetOctahedralMapShader(projectionMatrix, modelMatrix, viewMatrix)
    local shader = ShaderObjects["OctahedralMapShader"]
    if shader then
        shader:setCameraAndMatrix3D(projectionMatrix, modelMatrix, viewMatrix)
         return shader
    end
    local pixelcode = [[
        varying vec4 vnormal;

        vec2 OctWrap(vec2 v)
        {
            vec2 result;
            result.x = (1.0 - abs(v.x)) * (v.x >= 0.0 ? 1.0 : -1.0);
            result.y = (1.0 - abs(v.y)) * (v.y >= 0.0 ? 1.0 : -1.0);
            return result;
        }

        vec2 Encode(vec3 n)
        {
            n /= (abs(n.x) + abs(n.y) + abs(n.z));
            if(n.z  < 0)
            {
                n.xy = OctWrap(n.xy);
            }
           
            n.xy = n.xy * 0.5 + 0.5;
            return n.xy;
        }

        vec3 Decode(vec2 encN)
        {
            encN = encN * 2.0 -1.0;
            vec3 n;
            n.z = 1.0 - abs(encN.x) - abs(encN.y);
            if(n.z  < 0)
            {
                n.xy = OctWrap(encN.xy);
            }
            else
            {
                n.xy = encN.xy;
            }
            return n;
        }
        vec3 squareToOct(vec2 n)
        {
            vec2 _sample = 2.0 * n - vec2(1, 1);
            vec3 p = vec3(_sample.x, _sample.y, 1.0 - abs(_sample.x) - abs(_sample.y));
            if(p.z < 0.0)
            {
                float x = p.x;
                float y = p.y;
                p.x = (1.0 - abs(y)) * sin(p.x);
                p.y = (1.0 - abs(x)) * sin(p.y);
            }
            return normalize(p);
        }
        vec4 effect( vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords )
        {
            vec2 uv = Encode(vnormal.xyz);
            vec4 BaseColor = texture2D(tex, uv.xy);
            return BaseColor;
        }
    ]]
     
    local vertexcode = [[
        varying vec4 vnormal;
        uniform mat4 projectionMatrix;
        uniform mat4 modelMatrix;
        uniform mat4 viewMatrix;
        
        vec4 position(mat4 transform_projection, vec4 vertex_position)
        {
            vnormal =  VertexColor;
            vec4 basepos = projectionMatrix * viewMatrix * modelMatrix * VertexPosition;
            return basepos;
        }
     ]]
 
     log(pixelcode)
    shader = Shader.new(pixelcode, vertexcode)
 
    shader.setCameraAndMatrix3D = function(obj, modelMatrix, projectionMatrix, viewMatrix)
        if projectionMatrix then
            obj:sendValue('projectionMatrix', projectionMatrix)
        end
    
        if modelMatrix then
            obj:sendValue('modelMatrix', modelMatrix)
        end
    
        if viewMatrix then
            obj:sendValue('viewMatrix', viewMatrix)
        end

    end

    ShaderObjects["OctahedralMapShader"] = shader
     
     assert(shader:hasUniform( "projectionMatrix") and shader:hasUniform( "modelMatrix") and shader:hasUniform( "viewMatrix"))
     if projectionMatrix then
         shader:sendValue('projectionMatrix', projectionMatrix)
     end
 
     if modelMatrix then
         shader:sendValue('modelMatrix', modelMatrix)
     end
 
     if viewMatrix then
         shader:sendValue('viewMatrix', viewMatrix)
     end
    
     return  shader
 end
 