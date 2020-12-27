local width = love.graphics.getPixelWidth() * 1.5 -- love.graphics.getWidth() * 2
local height = love.graphics.getPixelHeight()  * 1.5--love.graphics.getHeight() * 2

local plane = Mesh3D.new("assert/obj/plane.obj")
plane:setBaseColor(LColor.new(125,125,125, 255))
-- mesh3d:setTexture(love.graphics.newImage("assert/obj/earth.png"))
-- mesh3d.transform3d = Matrix3D.getTransformationMatrix(Vector3.new(0,0,-20), Vector3.new(), Vector3.new(1,1,1))
local cubes = {}
local cubenum = 40
for i = 1, cubenum do
    local mesh3d = Mesh3D.new("assert/obj/bbb.obj")
    mesh3d.transform3d:mulTranslationRight(math.random(-700, 700), math.random(-200, 400), math.random(-500, 500))
    mesh3d.transform3d:mulScalingLeft(0.5, 0.5, 0.5)
    mesh3d:setBaseColor(LColor.new(math.random(1, 255), math.random(1, 255), math.random(1, 255), 255))
    table.insert(cubes, mesh3d)
end

currentCamera3D.eye = Vector3.new( 33.386304308313, 363.36230638215, 232.64515424476)
currentCamera3D.look = Vector3.new( 22.558604721495, -61.107337559643, 5.2498110475302)

local lightdir =Vector3.new(0,-1,0) --Vector3.sub(currentCamera3D.look, currentCamera3D.eye)

plane.transform3d:mulTranslationRight(0,-100,-100)
plane.transform3d:mulScalingLeft(50,1,50)
local clearcolor = false

local baseshader = Shader.GetBase3DShader()
plane:setBaseColor(LColor.new(125, 125,125, 255))
local depth_buffer = Canvas.new(width, height, {format = "depth32fstencil8", readable = true, msaa = 0, mipmaps="none"})
local color_buffer = Canvas.new(width, height, {format = "rgba8", readable = true, msaa = 0, mipmaps="none"})

local meshshader = Shader.GetBase3DShader();
local function renderMesh()

    love.graphics.setMeshCullMode("front")
    love.graphics.setDepthMode("less", true)
    for i = 1, #cubes do
        -- cubes[i].shader = baseshader
        cubes[i]:draw()
    end
    -- plane.shader = baseshader
    plane:draw()
end

local directionlight = DirectionLight.new(Vector3.new(0, 0.1, 0.5), LColor.new(255,255,255,255))
_G.useLight(directionlight)
app.render(function(dt)

    if clearcolor then
        love.graphics.clear(0.5,0.5,0.5)
    end
    
    love.graphics.setCanvas({color_buffer.obj, depthstencil = depth_buffer.obj})
    love.graphics.clear(0,0, 0, 0)
    renderMesh()
    love.graphics.setCanvas()
    color_buffer:draw()
end)

local shaderindex = 0
app.keypressed(function(key, scancode, isrepeat)
    if key == "space" then
        -- log('eye: ',currentCamera3D.eye.x, currentCamera3D.eye.y, currentCamera3D.eye.z)
        -- log('look: ',currentCamera3D.look.x, currentCamera3D.look.y, currentCamera3D.look.z)
    end

    -- if key == "up" then
    --     plane.transform3d:mulTranslationRight(0,-10,0)
    -- end

    -- if key == "down" then
    --     plane.transform3d:mulTranslationRight(0,0,-10)
    -- end
end)
