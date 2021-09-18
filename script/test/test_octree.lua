-- math.randomseed(os.time()%10000)

local width = love.graphics.getPixelWidth() * 1.5 -- love.graphics.getWidth() * 2
local height = love.graphics.getPixelHeight()  * 1.5--love.graphics.getHeight() * 2
local scene = Scene3D.new()
scene.isDrawBox = true
local plane = Mesh3D.new("assert/obj/plane.obj")
plane:setBaseColor(LColor.new(125,125,125, 255))
-- mesh3d:setTexture(love.graphics.newImage("assert/obj/earth.png"))
-- mesh3d.transform3d = Matrix3D.getTransformationMatrix(Vector3.new(0,0,-20), Vector3.new(), Vector3.new(1,1,1))
local cubenum = 100
local nodes = {}
for i = 1, cubenum do
    local mesh3d = Mesh3D.new("assert/obj/bbb.obj")
    mesh3d.transform3d:mulTranslationRight(math.random(-2000, 2000), math.random(-1000, 1000), math.random(-1000, 1000))
    mesh3d.transform3d:mulScalingLeft(0.5, 0.5, 0.5)
    mesh3d:setBaseColor(LColor.new(math.random(1, 255), math.random(1, 255), math.random(1, 255), 255))

    local node = scene:addMesh(mesh3d)
    table.insert(nodes, node)
end

currentCamera3D.eye = Vector3.new( 33.386304308313, 363.36230638215, 232.64515424476)
currentCamera3D.look = Vector3.new( 22.558604721495, -61.107337559643, 5.2498110475302)

plane.transform3d:mulTranslationRight(0,-100,-100)
plane.transform3d:mulScalingLeft(50,1,50)

plane:setBaseColor(LColor.new(125, 125,255, 255))
-- plane.nolight = true
local planenode = scene:addMesh(plane)


local frustummeshlines
app.render(function(dt)
    scene:update(dt)
    scene:draw(true)
    love.graphics.print( "Press Key Space.  scene.isDrawOctrees: "..tostring(scene.isDrawOctrees) , 10, 10)
end)

app.keypressed(function(key, scancode, isrepeat)
    if key == "space" then
        scene.isDrawOctrees = not scene.isDrawOctrees
    elseif key == 'w' then
        for i, v in pairs(nodes) do
            log('wwwwww')
            if v.octreenode then
                v.octreenode.visible = true
            end
        end

    elseif key == 'a' then
        for i, v in pairs(nodes) do
            -- if not v.octreenode then
                v.visible = true
            -- end
        end
    end
end)
