local p1 = Vector3.new(1, -5, -1)
local p2 = Vector3.new(1, 5, 1)
local p3 = Vector3.new(1, 5, -1)

local t1 = Triangle3D.new(p1, p2, p3)
local t2 = Triangle3D.new(p3, p2, p1)
t2:SetBaseColor(LColor.new(255,0,0,255))
app.render(function(dt)
    t1:draw()
    t2:draw()
end)

app.mousepressed(function(x, y, button, istouch)
   
    local ray = Ray.BuildFromScreen(x, y)
    local dis = ray:IntersectTriangle(t1, false)

    if dis > 0 then
        log('Pick T1 Mesh!')
    end

    -- dis = ray:IntersectTriangle(t2, false)

    -- if dis > 0 then
    --     log('Pick T2 Mesh!')
    -- end
end)

currentCamera3D.eye = Vector3.new( 50, 50, -50)
currentCamera3D.look = Vector3.new( 0 , 0, 0)