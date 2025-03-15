
math.randomseed(os.time()%10000)
local TestCube = Mesh3D.CreateCube()
TestCube.transform3d:Scale(2, 5, 2)

TestCube:SetBaseColor(LColor.new(0, 0, 180,255))
app.render(function(dt)
    TestCube:draw()
end)

app.mousepressed(function(x, y, button, istouch)
   
    local ray = Ray.BuildFromScreen(x, y)
    local dis = TestCube:PickByRay(ray)
    if dis > 0 then
        log('Pick Mesh!')
    end
end)
