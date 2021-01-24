currentCamera3D.eye = Vector3.new( 33.386304308313, 363.36230638215, 232.64515424476)
currentCamera3D.look = Vector3.new( 22.558604721495, -61.107337559643, 5.2498110475302)

local meshline = MeshLine.new(Vector3.new(0 ,0 ,0), Vector3.new(500 ,500 ,500))
app.resizeWindow(function(w, h)

end)

app.render(function(dt)

    meshline:draw()
    -- love.graphics.print( "Image name: ".. imagenames[index] .. " SSAO: ".. tostring(scene.needSSAO) .. " SSAOValue: ".. tostring(RenderSet.getSSAOValue()), 10, 10)
end)

app.keypressed(function(key, scancode, isrepeat)
    if key == "space" then
        currentCamera3D.eye = Vector3.sub(currentCamera3D.eye, currentCamera3D.look)
        currentCamera3D.look = Vector3.new(0,0,0)
    end

end)
