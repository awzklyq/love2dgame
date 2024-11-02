

BillBoard.GetDefaultSunPlane = function(w, h, radius)
    local b = BillBoard.new(w, h)
    b.Radius = radius
    b.shader = Shader.GetBillBoardSunShader()
    b.LightPower = 1.0
    b.ShaderFunc = function(BillBoardObj)
        BillBoardObj.shader:SetShaderValue(BillBoardObj)
    end

    return b
end

function Shader.GetBillBoardSunShader(projectionMatrix, modelMatrix, viewMatrix)
    local shader = ShaderObjects["shader_BillBoardSun"]
    if shader then
         return shader
    end
    if not shader then
         local pixelcode = [[
            uniform float TestRadius;
            uniform float LightPower;
            uniform vec3 TestPosition;
            varying vec4 TestVertexPostion;

            vec4 effect( vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords )
            {
                float dis = distance(TestPosition, TestVertexPostion.xyz);
                float alpha = clamp((dis / TestRadius) * (1/ LightPower), 0.0, 1.0);
                //float alpha = sin(radians(clamp((dis / TestRadius) * (1/ LightPower), 0.0, 1.0)) * 90);
                vec3 LightColor = vec3(1, 1, 1);
                return vec4(LightColor, 1 - alpha);
            }
         ]]
     
         local vertexcode = [[
             uniform mat4 projectionMatrix;
             uniform mat4 modelMatrix;
             uniform mat4 viewMatrix;

             varying vec4 TestVertexPostion;
             vec4 position(mat4 transform_projection, vec4 vertex_position)
             {
                 vec4 basepos = projectionMatrix * viewMatrix * modelMatrix * VertexPosition;

                 TestVertexPostion =  modelMatrix * VertexPosition;
                 return basepos;
             }
     ]]
 
         shader = Shader.new(pixelcode, vertexcode)
 
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

        shader.SetShaderValue = function(obj, InBillbord)
            obj:sendValue('TestRadius', InBillbord.Radius)
            obj:sendValue('TestPosition', InBillbord.Position:getShaderValue())

            local cameradir = -currentCamera3D:GetDirction()
            obj:sendValue('TestInvViewDir', cameradir:getShaderValue())

            obj:sendValue('LightPower', InBillbord.LightPower)
        end
 
         ShaderObjects["shader_BillBoardSun"] = shader
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

 
function Shader.GetBillBoardSunInScatterShader(projectionMatrix, modelMatrix, viewMatrix)
    local shader = ShaderObjects["shader_BillBoardSunInScatter"]
    if shader then
         return shader
    end
    if not shader then
        --https://blog.mmacklin.com/2010/05/29/in-scattering-demo/
         local pixelcode = [[
            uniform float TestRadius;
            uniform vec3 TestPosition;
            uniform vec3 TestInvViewDir;
            uniform vec3 TestCameraEye;
            uniform float TestLerp;
            uniform float TestPower;
            varying vec4 TestVertexPostion;

            float InScatter(float InDistance)
            {
                InDistance = clamp(InDistance, 0, TestRadius);

                float sd = sqrt(TestRadius * TestRadius - InDistance * InDistance);

                vec3 start = TestVertexPostion.xyz + TestInvViewDir * sd;//TestCameraEye;//
                vec3 lightPos = TestPosition;
                //float d = sd * 2;
                

                // light to ray origin
                vec3 q = start - lightPos;

                vec3 InvViewDir = TestInvViewDir;
                vec3 ExitPos =  TestVertexPostion.xyz - InvViewDir * sd * 2;
                //vec3 dir = normalize(TestVertexPostion.xyz - InvViewDir * sd - lightPos);
                vec3 dir = normalize(ExitPos - lightPos);

                float d = distance(ExitPos ,TestCameraEye);
                // coefficients
                float b = dot(dir, q);
                float c = dot(q, q);

                // evaluate integral
                float s = 1.0f / sqrt(c - b*b);
                float l = s * (atan( (d + b) * s) - atan( b*s ));

                return l;
            }

            vec4 effect( vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords )
            {
                float dis = distance(TestPosition, TestVertexPostion.xyz);
                float AlphaSelect = step(dis, TestRadius * TestLerp);
                vec3 LightColor = vec3(1, 1, 1);

                float alpha = 0;
                
                if(AlphaSelect > 0)
                {
                    float L = InScatter(dis);
                    float power = L * TestPower;
                    alpha = power;
                }
                else
                {
                    float StartPos = TestRadius * (1 - TestLerp);
                    float L = InScatter(StartPos);
                    float power = L * TestPower;

                    alpha = power * cos(radians(clamp((dis - StartPos) / (TestRadius - StartPos), 0.0, 1.0) * 90));
                }
                return vec4(LightColor, alpha);
            }
         ]]
     
         local vertexcode = [[
             uniform mat4 projectionMatrix;
             uniform mat4 modelMatrix;
             uniform mat4 viewMatrix;

             varying vec4 TestVertexPostion;
             vec4 position(mat4 transform_projection, vec4 vertex_position)
             {
                 vec4 basepos = projectionMatrix * viewMatrix * modelMatrix * VertexPosition;

                 TestVertexPostion =  modelMatrix * VertexPosition;
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

        shader.SetShaderValue = function(obj, InBillbord)
            obj:sendValue('TestRadius', InBillbord.Radius)
            obj:sendValue('TestPosition', InBillbord.Position:getShaderValue())
            obj:sendValue('TestPower', InBillbord.LightPower)
            obj:sendValue('TestLerp', InBillbord.TestLerp)
            
            local cameradir = -currentCamera3D:GetDirction()
            obj:sendValue('TestInvViewDir', cameradir:getShaderValue())

            local CameraEye = currentCamera3D.eye
            obj:sendValue('TestCameraEye', CameraEye:getShaderValue())
        end
 
         ShaderObjects["shader_BillBoardSunInScatter"] = shader
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