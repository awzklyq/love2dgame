local RayTest = Ray.new(Vector3.new(0,0,100), Vector3.new(math.random(), math.random(), math.random()))

local meshline = RayTest:GetMeshLine(5000, LColor.new(255,0,0,255))

local BoxTest = BoundBox.buildFromMinMax(Vector3.new(-100,-100,0), Vector3.new(100,100,100))
local boxlines = BoxTest:buildMeshLines()


local GenerateData = function()
    local p = Vector3.new(math.random(-700, 700),math.random(-700, 700), math.random(-300, 300))
    RayTest = Ray.new(p, Vector3.new(math.random(-1, 1), math.random(-1, 1), math.random(-1, 1)))
    
    local min = Vector3.new(math.random(-500, 0),math.random(-500, 0), math.random(-200, 0))

    local max = Vector3.new(math.random(0, 500),math.random(0, 500), math.random(0, 200))

    min.x = math.min(min.x, max.x)
    min.y = math.min(min.y, max.y)
    min.z = math.min(min.z, max.z)

    max.x = math.max(min.x, max.x)
    max.y = math.max(min.y, max.y)
    max.z = math.max(min.z, max.z)


    BoxTest = BoundBox.buildFromMinMax(min, max)

   -- RayTest = Ray.new(p, BoxTest.center - p)

    local IsIntersect = RayTest:IsIntersectBox(BoxTest)
    meshline = RayTest:GetMeshLine(5000, IsIntersect and LColor.new(255,0,0,255) or LColor.new(0,255,0,255))
    boxlines = BoxTest:buildMeshLines()
end

GenerateData()

app.render(function(dt)
    meshline:draw()
    boxlines:draw()
end)


app.keypressed(function(key, scancode, isrepeat)
    if key == "space" then
        GenerateData()
    end
end)

currentCamera3D.eye = Vector3.new( 33.386304308313, 363.36230638215, 232.64515424476)
currentCamera3D.look = Vector3.new( 22.558604721495, -61.107337559643, 5.2498110475302)