math.randomseed(os.time()%10000)
log(math.pow(2,32))
local width = love.graphics.getPixelWidth() * 1.5 -- love.graphics.getWidth() * 2
local height = love.graphics.getPixelHeight()  * 1.5--love.graphics.getHeight() * 2
local scene = Scene3D.new()
local plane = Mesh3D.new("assert/obj/plane.obj")
plane:setBaseColor(LColor.new(125,125,125, 255))
-- mesh3d:setTexture(love.graphics.newImage("assert/obj/earth.png"))
-- mesh3d.transform3d = Matrix3D.getTransformationMatrix(Vector3.new(0,0,-20), Vector3.new(), Vector3.new(1,1,1))
local cubenum = 20
local mesh
for i = 1, cubenum do
    local mesh3d = Mesh3D.new("assert/obj/bbb.obj")
    mesh3d.transform3d:mulTranslationRight(math.random(-1000, 1000), math.random(-500, 900), math.random(-500, 500))
    -- plane.transform3d:mulTranslationRight(30,-100, 50)
    mesh3d.transform3d:mulScalingLeft(1, 1, 1)
    -- mesh3d:setBaseColor(LColor.new(math.random(1, 255), math.random(1, 255), math.random(1, 255), 255))
    mesh3d:setBaseColor(LColor.new(255,255,255, 255))

    local node = scene:addMesh(mesh3d)
    node.shadowCaster = true

    mesh = mesh3d
end

currentCamera3D.eye = Vector3.new( 33.386304308313, 363.36230638215, 232.64515424476)
currentCamera3D.look = Vector3.new( 22.558604721495, -61.107337559643, 5.2498110475302)

plane.transform3d:mulTranslationRight(0,-100,-100)
plane.transform3d:mulScalingLeft(50,1,50)

local baseshader = Shader.GetBase3DShader()
plane:setBaseColor(LColor.new(125, 125,255, 255))
-- plane.nolight = true
local planenode = scene:addMesh(plane)
planenode.shadowReceiver = true

local directionlight = DirectionLight.new(Vector3.new(1, 1, -1):normalize(), LColor.new(150,150,150,255))
local lightnode = scene:addLight(directionlight)
lightnode.needshadow = true

local PL = PointLight.new(Vector3.new(30,-100, 50),  LColor.new(255, 0, 0,255), 800, 10)
UseLight(PL)
scene.needLights = true
app.render(function(dt)
    scene:update(dt)
    scene:drawDirectionLightCSM()
    scene:draw(true)
end)

local checkb = UI.CheckBox.new( 10, 10, 20, 20, "PointLights" )
checkb.IsSelect = scene.needLights
checkb.ChangeEvent = function(Enable)
    scene.needLights = Enable
end
