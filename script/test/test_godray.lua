math.randomseed(os.time()%10000)

local width = love.graphics.getPixelWidth() * 1.5 -- love.graphics.getWidth() * 2
local height = love.graphics.getPixelHeight()  * 1.5--love.graphics.getHeight() * 2
local scene = Scene3D.new()
-- scene.bgColor = LColor.new(110,110,110,255)

local cubenum = 10
local MeshTables = {}
for i = 1, cubenum do
    local mesh3d = Mesh3D.new("assert/obj/taiyang/Sphere.OBJ")
    mesh3d.transform3d:mulTranslationRight(-1500 + 3000 * math.random(), -1500 + 3000 * math.random(), -1500 + 3000 * math.random())
    local scale = math.random(1, 3)
    mesh3d.transform3d:mulScalingLeft(scale ,scale, scale)
    mesh3d:setBaseColor(LColor.new(math.random() * 255, math.random() * 255, math.random() * 255, 255))

    MeshTables[#MeshTables + 1] = mesh3d
    local node = scene:addMesh(mesh3d)
    -- node.PBR = true
end

local mesh3d = Mesh3D.new("assert/obj/taiyang/Sphere.OBJ")
mesh3d.transform3d:mulTranslationRight(0, 0, 0)
local scale = 0.1
mesh3d.transform3d:mulScalingLeft(scale ,scale, scale)

mesh3d:setBaseColor(LColor.new(255, 255, 255, 255))
local LightNode = scene:addMesh(mesh3d)

currentCamera3D.eye = Vector3.new( 525.36051214316, 2852.3172223799, 1982.0588684058)
currentCamera3D.look = Vector3.new( 22.558604721495, -61.107337559643, 5.2498110475302)

local w = RenderSet.screenwidth
local h = RenderSet.screenheight
local CanvasColor = Canvas.new(w, h, {format = "rgba8", readable = true, msaa = 0, mipmaps="none"})
local depthmap_depth_buffer = Canvas.new(w, h, {format = "depth32fstencil8", readable = true, msaa = 0, mipmaps="none"})
local bgColor = LColor.new(110,110,110,255)
local directionlight = DirectionLight.new((currentCamera3D.eye - currentCamera3D.look ):normalize(), LColor.new(255,255,255,255))
app.render(function(dt)
    love.graphics.setMeshCullMode("front")
    love.graphics.setDepthMode("less", true)
    love.graphics.setCanvas({CanvasColor.obj, depthstencil = depthmap_depth_buffer.obj})
    love.graphics.clear(bgColor._r, bgColor._g, bgColor._b, bgColor._a)
    mesh3d:draw()
    
    for i = 1, #MeshTables do
        MeshTables[i]:DrawPrePassBlack()
    end
    love.graphics.setCanvas()
    love.graphics.setMeshCullMode("none")
    -- CanvasColor:draw()

    local ScreenLightPos = RenderSet.getUseViewMatrix() * (RenderSet.getUseProjectMatrix() * Vector4.new(0, 0, 0, 1))
    local cavans = GodRayNode.Execute(CanvasColor, {ScreenLightPos.x, ScreenLightPos.y, ScreenLightPos.z, ScreenLightPos.w})

    love.graphics.setMeshCullMode("front")
    love.graphics.setDepthMode("equal", true)
    love.graphics.setCanvas({cavans.obj, depthstencil = depthmap_depth_buffer.obj})
    --love.graphics.clear(bgColor._r, bgColor._g, bgColor._b, bgColor._a)
    mesh3d:draw()
    
    for i = 1, #MeshTables do
        MeshTables[i]:draw()
    end
    love.graphics.setCanvas()
    love.graphics.setMeshCullMode("none")

    cavans:draw()
   
end)
app.keypressed(function(key, scancode, isrepeat)
    if key == "space" then
        log(currentCamera3D.eye.x, currentCamera3D.eye.y, currentCamera3D.eye.z)
        log(currentCamera3D.look.x, currentCamera3D.look.y, currentCamera3D.look.z)
    elseif key == "a" then
    end
end)

app.resizeWindow(function(w, h)
    CanvasColor = Canvas.new(w, h, {format = "rgba8", readable = true, msaa = 0, mipmaps="none"})
    depthmap_depth_buffer = Canvas.new(w, h, {format = "depth32fstencil8", readable = true, msaa = 0, mipmaps="none"})
end)
