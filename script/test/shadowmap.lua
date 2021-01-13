local width = love.graphics.getPixelWidth() * 1.5 -- love.graphics.getWidth() * 2
local height = love.graphics.getPixelHeight()  * 1.5--love.graphics.getHeight() * 2
local scene = Scene3D.new()
local plane = Mesh3D.new("assert/obj/plane.obj")
plane:setBaseColor(LColor.new(125,125,125, 255))
-- mesh3d:setTexture(love.graphics.newImage("assert/obj/earth.png"))
-- mesh3d.transform3d = Matrix3D.getTransformationMatrix(Vector3.new(0,0,-20), Vector3.new(), Vector3.new(1,1,1))
local cubenum = 40
for i = 1, cubenum do
    local mesh3d = Mesh3D.new("assert/obj/bbb.obj")
    mesh3d.transform3d:mulTranslationRight(math.random(-700, 700), math.random(-200, 400), math.random(-500, 500))
    mesh3d.transform3d:mulScalingLeft(0.5, 0.5, 0.5)
    mesh3d:setBaseColor(LColor.new(math.random(1, 255), math.random(1, 255), math.random(1, 255), 255))

    local node = scene:addMesh(mesh3d)
    node.isDrawBox = true
end

currentCamera3D.eye = Vector3.new( 33.386304308313, 363.36230638215, 232.64515424476)
currentCamera3D.look = Vector3.new( 22.558604721495, -61.107337559643, 5.2498110475302)

local lightdir =Vector3.new(0,-1,0) --Vector3.sub(currentCamera3D.look, currentCamera3D.eye)

plane.transform3d:mulTranslationRight(0,-100,-100)
plane.transform3d:mulScalingLeft(50,1,50)

local baseshader = Shader.GetBase3DShader()
plane:setBaseColor(LColor.new(125, 125,125, 255))
plane.nolight = true
scene:addMesh(plane)


local directionlight = DirectionLight.new(Vector3.new(0, 0.1, 0.5), LColor.new(255,255,255,255))
scene:addLight(directionlight)
local rendertype = 1
app.render(function(dt)
    scene:update(dt)
    if rendertype == 1 then
        scene:draw(true)
    else
        scene:drawDepth()
        local canvas = scene:getDepthCanvas()
        canvas:draw()
    end
    
    love.graphics.print( "Press Key Space", 10, 10)
end)

app.keypressed(function(key, scancode, isrepeat)
    if key == "space" then
        -- log('eye: ',currentCamera3D.eye.x, currentCamera3D.eye.y, currentCamera3D.eye.z)
        -- log('look: ',currentCamera3D.look.x, currentCamera3D.look.y, currentCamera3D.look.z)
        rendertype = 3 - rendertype
    end

    -- if key == "up" then
    --     plane.transform3d:mulTranslationRight(0,-10,0)
    -- end

    -- if key == "down" then
    --     plane.transform3d:mulTranslationRight(0,0,-10)
    -- end
end)
