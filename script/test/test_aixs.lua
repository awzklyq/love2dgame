FileManager.addAllPath("assert")

local aixs = Aixs.new(0,0,0, 150)

local mesh = Mesh3D.new("SM_TrimWall_U_Internal.obj")

app.render(function(dt)

    mesh:draw()
    aixs:draw()

    -- meshline:draw()
end)


app.keypressed(function(key, scancode, isrepeat)
    if key == "w" then
        mesh.transform3d:mulScalingLeft(1,5,1)
    end
end)

currentCamera3D.eye = Vector3.new( 150, 0, 0)
currentCamera3D.look = Vector3.new( 0, 0, 0)