

FileManager.addAllPath("assert")
local TempIndicator = Indicator.new()

app.render(function(dt)
    TempIndicator:draw()

    -- mesh:draw()
end)

app.mousepressed(function(x, y, button, istouch)
   
    -- local ray = Ray.BuildFromScreen(x, y)
    -- local dis = TempIndicator:PickByRay(ray)
    -- if dis > 0 then
    --     log('Pick Mesh!')
    -- end
end)


currentCamera3D.eye = Vector3.new( 50, 50, -50)
currentCamera3D.look = Vector3.new( 0 , 0, 0)