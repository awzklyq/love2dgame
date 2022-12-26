-- math.randomseed(os.time()%10000)
FileManager.addAllPath("assert")

local width = love.graphics.getPixelWidth() * 1.5 -- love.graphics.getWidth() * 2
local height = love.graphics.getPixelHeight()  * 1.5--love.graphics.getHeight() * 2
local scene = Scene3D.new()
-- scene.bgColor = LColor.new(0, 0, 0, 255)
local plane = Mesh3D.new("assert/obj/plane.obj")
plane:setBaseColor(LColor.new(125,125,125, 255))
-- mesh3d:setTexture(love.graphics.newImage("assert/obj/earth.png"))
-- mesh3d.transform3d = Matrix3D.getTransformationMatrix(Vector3.new(0,0,-20), Vector3.new(), Vector3.new(1,1,1))
local cubenum = 20
local nodes = {}
for i = 1, cubenum do
    local mesh3d = Mesh3D.new("assert/obj/bbb.obj")
    mesh3d.transform3d:mulTranslationRight(math.random(-1000, 1000), math.random(-500, 500), math.random(-500, 500))
    local scale = math.random() * 2
    mesh3d.transform3d:mulScalingLeft(scale, scale, scale)
    mesh3d:setBaseColor(LColor.new(math.random(1, 255), math.random(1, 255), math.random(1, 255), 255))

    mesh3d.needVelocityBuff = true

    mesh3d:setCanvas(ImageEx.new("wb.jpg") )
    local node = scene:addMesh(mesh3d)

    node.speed = math.random()

    table.insert(nodes, node)
end

currentCamera3D.eye = Vector3.new( 33.386304308313, 363.36230638215, 232.64515424476)
currentCamera3D.look = Vector3.new( 22.558604721495, -61.107337559643, 5.2498110475302)

plane.transform3d:mulTranslationRight(0,-100,-100)
plane.transform3d:mulScalingLeft(50,1,50)

plane:setBaseColor(LColor.new(125, 125,255, 255))
-- plane.nolight = true
-- local planenode = scene:addMesh(plane)

local IsDrawVelocity = false

-- VelocityBuffNode.VelocityBuff

local color_buffer = Canvas.new(100, 100, {format = "rgba8", readable = true, msaa = 0, mipmaps="none"})

local speed = 1

app.update(function(dt)
    -- for i = 1, #nodes do
    --     nodes[i].mesh.transform3d:mulRotationRight(0, 1, 0, speed * nodes[i].speed * dt)
    --     --nodes[i].mesh.transform3d:mulTranslationRight(0, 0, speed * nodes[i].speed * dt)
    --  end
end)


app.render(function(dt)

    scene:update(dt)
    scene:draw(true)


    if IsDrawVelocity then
        VelocityBuffNode.VelocityBuff:draw()
    end
    
    for i = 1, #nodes do
        nodes[i].mesh.transform3d:mulRotationRight(0, 1, 0, speed * nodes[i].speed * love.timer.getFPS() * 0.001)
        --nodes[i].mesh.transform3d:mulTranslationRight(0, 0, speed * nodes[i].speed * dt)
     end

    love.graphics.print( "Press Key Space.  scene.needVelocityBuff: "..tostring(scene.needVelocityBuff) .. " VelocityBuffNode.uVelocityScale: " .. tostring(VelocityBuffNode.uVelocityScale) .. " speed: " .. tostring(speed) .. "  FPS: " .. tostring(love.timer.getFPS()), 10, 10)
end)

app.keypressed(function(key, scancode, isrepeat)
    if key == "space" then
        scene.needVelocityBuff = not scene.needVelocityBuff
    elseif key == 'w' then
        VelocityBuffNode.uVelocityScale = VelocityBuffNode.uVelocityScale + 0.5
    elseif key == 's' then
        VelocityBuffNode.uVelocityScale = VelocityBuffNode.uVelocityScale - 0.5
    elseif key == 'e' then
        speed = speed + 0.1
    elseif key == 'd' then
        speed = speed - 0.1
    elseif key == 'r' then
        speed = -speed
    elseif key == 'a' then
        IsDrawVelocity = not IsDrawVelocity
    end
end)
