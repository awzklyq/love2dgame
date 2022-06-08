local width = love.graphics.getPixelWidth() * 1.5 -- love.graphics.getWidth() * 2
local height = love.graphics.getPixelHeight()  * 1.5--love.graphics.getHeight() * 2

local plane = Mesh3D.new("assert/obj/plane.obj")
plane:setBaseColor(LColor.new(125,125,125, 255))

local mesh3d = Mesh3D.new("assert/obj/bbb.obj")
mesh3d.transform3d:mulTranslationRight(math.random(-400, 400), math.random(-200, 200), math.random(-200, 200))
mesh3d.transform3d:mulScalingLeft(0.5, 0.5, 0.5)
mesh3d:setBaseColor(LColor.new(math.random(1, 255), math.random(1, 255), math.random(1, 255), 255))

mesh3d:setCanvas(ImageEx.new('shenzhenditu.jpg'))

currentCamera3D.eye = Vector3.new( 33.386304308313, 363.36230638215, 232.64515424476)
currentCamera3D.look = Vector3.new( 22.558604721495, -61.107337559643, 5.2498110475302)

app.update(function(dt)

    -- mesh3d.transform3d:mulRotationRight(0,0,1,0.2 *dt )
    mesh3d.transform3d:mulTranslationRight(0,0,10 * dt)
end)

app.render(function(dt)
    love.graphics.clear(0.5,0.5,0.5)
    love.graphics.setMeshCullMode("back")
    love.graphics.setDepthMode("less", false)

    mesh3d:draw()

end)

app.keypressed(function(key, scancode, isrepeat)
    if key == "space" then
       
    end
end)