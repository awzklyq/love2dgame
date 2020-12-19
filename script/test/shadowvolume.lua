
local mesh3d = Mesh3D.new("assert/obj/sphere.obj")
mesh3d:setTexture(love.graphics.newImage("assert/obj/earth.png"))
-- mesh3d.transform3d = Matrix3D.getTransformationMatrix(Vector3.new(0,0,-20), Vector3.new(), Vector3.new(1,1,1))
mesh3d.transform3d:mulTranslationRight(0,0,-20)
app.render(function(dt)
    
    love.graphics.setDepthMode("lequal", true)
    mesh3d:draw()
end)

local shaderindex = 0
app.keypressed(function(key, scancode, isrepeat)
    if key == "space" then
        
    end
end)
