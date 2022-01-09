math.randomseed(os.time()%10000)

local width = love.graphics.getPixelWidth() * 1.5 -- love.graphics.getWidth() * 2
local height = love.graphics.getPixelHeight()  * 1.5--love.graphics.getHeight() * 2
local scene = Scene3D.new()
scene.bgColor = LColor.new(100,100,100,255)
-- mesh3d:setTexture(love.graphics.newImage("assert/obj/earth.png"))
-- mesh3d.transform3d = Matrix3D.getTransformationMatrix(Vector3.new(0,0,-20), Vector3.new(), Vector3.new(1,1,1))
local cubenum = 10
for i = 1, cubenum do
    local mesh3d = Mesh3D.new("assert/obj/taiyang/Sphere.OBJ")
    mesh3d.transform3d:mulTranslationRight(-3000 + 400 * i, -3000 + 400 * i, 800)
    local scale = 3--math.random(0.5, 2)
    mesh3d.transform3d:mulScalingLeft(scale ,scale, scale)
    mesh3d:setBaseColor(LColor.new(10,10,10, 255))

    local node = scene:addMesh(mesh3d)
    node.PBR = true --i % 2 == 0
end

currentCamera3D.eye = Vector3.new( 33.386304308313, 363.36230638215, 232.64515424476)
currentCamera3D.look = Vector3.new( 22.558604721495, -61.107337559643, 5.2498110475302)

local directionlight = DirectionLight.new((currentCamera3D.eye - currentCamera3D.look ):normalize(), LColor.new(255,255,255,255))
local lightnode = scene:addLight(directionlight)
local rendertype = 1

local canvas = Canvas.new(love.graphics.getPixelWidth(), love.graphics.getPixelHeight(), settings)
local meshquad = _G.MeshQuad.new(love.graphics.getWidth(), love.graphics.getHeight(), LColor.new(255, 255, 255, 255), canvas)
meshquad.shader = Shader.GetFXAAShader(canvas:getWidth(), canvas:getHeight())

local frustummeshlines
app.render(function(dt)
    scene:update(dstlen)
    scene:draw(true)
   
end)
print("出生")
app.keypressed(function(key, scancode, isrepeat)
    if key == "space" then

    elseif key == "a" then
        scene.needFXAA = not scene.needFXAA
    end

    if key == 'x' then
    end

    -- if key == love.keyboard.isDown( key )"up" then
    --     mesh.transform3d:mulTranslationRight(0,0,20)
    -- elseif key == "down" then
    --     mesh.transform3d:mulTranslationRight(0,0,-20)
    -- elseif key == "left" then
    --     mesh.transform3d:mulTranslationRight(0,20,0)
    -- elseif key == "right" then
    --     mesh.transform3d:mulTranslationRight(0,-20,0)
    -- end
end)
