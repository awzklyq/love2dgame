FileManager.addAllPath("assert")

local aixs = Aixs.new(0,0,0, 150)

local mesh = Mesh3D.new("SM_TrimWall_U_Internal.obj")

local frustum = Frustum.new()
local frustummeshlines
app.render(function(dt)

    mesh:draw()
    aixs:draw()
    
    if frustummeshlines then
        frustummeshlines:draw()
    end
end)


app.keypressed(function(key, scancode, isrepeat)
    if key == "space" then
        local camera3d = _G.getGlobalCamera3D()
        frustummeshlines = Frustum.buildDrawLines( camera3d)

        frustum:buildFromViewAndProject( RenderSet.getCameraFrustumViewMatrix(), RenderSet.getCameraFrustumProjectMatrix() )

    elseif key == "w" then
        local box = BoundBox.buildFromMesh3D(mesh)
        box = mesh.transform3d:mulBoundBox(box)
        log(tostring(frustum:insideBox(box)))

    elseif key == "up" then
        mesh.transform3d:mulTranslationRight(0,0,50)
    elseif key == "down" then
        mesh.transform3d:mulTranslationRight(0,0,-50)
    elseif key == "left" then
        mesh.transform3d:mulTranslationRight(0,50,0)
    elseif key == "right" then
        mesh.transform3d:mulTranslationRight(0,-50,0)
    end
end)

currentCamera3D.eye = Vector3.new( 150, 0, 0)
currentCamera3D.look = Vector3.new( 50, 50, 0)