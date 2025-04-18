-- math.randomseed(os.time()%10000)

local width = love.graphics.getPixelWidth() * 1.5 -- love.graphics.getWidth() * 2
local height = love.graphics.getPixelHeight()  * 1.5--love.graphics.getHeight() * 2

local frustummeshlines
local scene = Scene3D.new()
scene.isDrawBox = true
local plane = Mesh3D.new("assert/obj/plane.obj")
plane:setBaseColor(LColor.new(125,125,125, 255))
-- mesh3d:setTexture(love.graphics.newImage("assert/obj/earth.png"))
-- mesh3d.transform3d = Matrix3D.getTransformationMatrix(Vector3.new(0,0,-20), Vector3.new(), Vector3.new(1,1,1))
local cubenum = 50
for i = 1, cubenum do
    local mesh3d = Mesh3D.new("assert/obj/bbb.obj")
    mesh3d.transform3d:mulTranslationRight(math.random(-1500, 1500), math.random(-1000, 1200), math.random(-500, 500))
    mesh3d.transform3d:mulScalingLeft(0.5, 0.5, 0.5)
    mesh3d:setBaseColor(LColor.new(math.random(1, 255), math.random(1, 255), math.random(1, 255), 255))

    local node = scene:addMesh(mesh3d)
    node.isDrawBox = true
end

currentCamera3D.eye = Vector3.new( 33.386304308313, 363.36230638215, 232.64515424476)
currentCamera3D.look = Vector3.new( 22.558604721495, -61.107337559643, 5.2498110475302)

plane.transform3d:mulTranslationRight(0,-100,-100)
plane.transform3d:mulScalingLeft(50,1,50)

local baseshader = Shader.GetBase3DShader()
plane:setBaseColor(LColor.new(125, 125,255, 255))
-- plane.nolight = true
-- local planenode = scene:addMesh(plane)

local rendertype = 1

local canvas = Canvas.new(love.graphics.getPixelWidth(), love.graphics.getPixelHeight(), settings)
local meshquad = _G.MeshQuad.new(love.graphics.getWidth(), love.graphics.getHeight(), LColor.new(255, 255, 255, 255), canvas)
meshquad.shader = Shader.GetFXAAShader(canvas:getWidth(), canvas:getHeight())

app.render(function(dt)
    scene:update(dt)
    scene:draw(true)

    if frustummeshlines then
        frustummeshlines:draw()
    end
    love.graphics.print( "Press Key Space.  scene.needFXAA: "..tostring(scene.needFXAA) .. " Frustum Cull: "..tostring(RenderSet.isNeedFrustum) .. " Mesh nodes Number: "..tostring(scene:getMeshNodesNumber()).. " Culled Number: "..tostring(scene:getFrusumCulledNumber()), 10, 10)
end)

app.keypressed(function(key, scancode, isrepeat)
    if key == "space" then
        -- frustummeshlines = scene.frustum:buildDrawLinesFromFrustum()
        scene.isDrawOctrees = not scene.isDrawOctrees
    elseif key == "a" then
        scene.needFXAA = not scene.needFXAA
    end

    if key == 'x' then
        RenderSet.isNeedFrustum = not RenderSet.isNeedFrustum
    end
end)
