FileManager.addAllPath("assert")

local aixs = Aixs.new(0,0,0, 150)

local mesh = Mesh3D.new("aaa.obj")

local ob = OrientedBox.buildFormMinMax(Vector3.new(-300, -300, -300), Vector3.new(300, 300, 300))
local boxlines = ob:buildMeshLines()
RenderSet.isNeedFrustum = true

local frustum = Frustum.new()
local frustummeshlines

local width = love.graphics.getPixelWidth() * 1.5 -- love.graphics.getWidth() * 2
local height = love.graphics.getPixelHeight()  * 1.5--love.graphics.getHeight() * 2
local depth_buffer = Canvas.new(width, height, {format = "depth32fstencil8", readable = true, msaa = 0, mipmaps="none"})
local color_buffer = Canvas.new(width, height, {format = "rgba8", readable = true, msaa = 0, mipmaps="none"})
app.render(function(dt)

    love.graphics.setDepthMode("less", true)
    love.graphics.setCanvas({ color_buffer.obj, depthstencil = depth_buffer.obj})
    love.graphics.clear(0, 0, 0, 1)
    mesh:draw()
    aixs:draw()
    boxlines:draw()
    if frustummeshlines then
        frustummeshlines:draw()
    end

    love.graphics.setCanvas()

    color_buffer:draw()
end)

app.keypressed(function(key, scancode, isrepeat)
    if key == "space" then
        local camera3d = _G.getGlobalCamera3D()
       

        -- local far = camera3d.farClip
        -- camera3d.farClip = 500

        -- local nearClip = camera3d.nearClip
        -- camera3d.nearClip = 19
        frustum:buildFromViewAndProject( RenderSet.getCameraFrustumViewMatrix(), RenderSet.getCameraFrustumProjectMatrix() )
        -- frustum:buildFromOrientedBox(ob)
        -- frustummeshlines = Frustum.buildDrawLines( camera3d)
        frustummeshlines = frustum:buildDrawLinesFromFrustum()
        -- camera3d.farClip = far
        -- camera3d.nearClip =nearClip
    elseif key == "w" then
        local box = BoundBox.buildFromMesh3D(mesh)
        
        box = mesh.transform3d:mulBoundBox(box)

        -- log(tostring(frustum:insideOrientedBox(box)))
        log(tostring(frustum:insideBox(box:getBoundBox())))
    elseif key == "x" then
        local pos = Vector3.new(mesh.transform3d:getData(1,4), mesh.transform3d:getData(2,4), mesh.transform3d:getData(3,4))
        log('pos: ', pos.x, pos.y, pos.z)
        log(tostring(frustum:insidePosition(pos)))

    elseif key == "up" then
        mesh.transform3d:mulTranslationRight(0,0,500)
    elseif key == "down" then
        mesh.transform3d:mulTranslationRight(0,0,-500)
    elseif key == "left" then
        mesh.transform3d:mulTranslationRight(0,500,0)
    elseif key == "right" then
        mesh.transform3d:mulTranslationRight(0,-500,0)
    elseif key == "a" then
        mesh.transform3d:mulTranslationRight(500,0,0)
    elseif key == "d" then
        mesh.transform3d:mulTranslationRight(-500,0,0)
    end

    local width = love.graphics.getPixelWidth()
local height = love.graphics.getPixelHeight()
    depth_buffer = Canvas.new(width, height, {format = "depth32fstencil8", readable = true, msaa = 0, mipmaps="none"})
    color_buffer = Canvas.new(width, height, {format = "rgba8", readable = true, msaa = 0, mipmaps="none"})
end)

currentCamera3D.eye = Vector3.new( 150, 0, 0)
currentCamera3D.look = Vector3.new( 50, 50, 0)