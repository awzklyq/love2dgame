FileManager.addAllPath("assert")

local mesh3d = Mesh3D.new("SM_RailingStairs_Internal.OBJ")
mesh3d:setNormalMap("T_Railing_N.TGA")
currentCamera3D.eye = Vector3.new( 33.386304308313, 363.36230638215, 232.64515424476)
currentCamera3D.look = Vector3.new( 22.558604721495, -61.107337559643, 5.2498110475302)

local imagenames = {'T_Railing_M.TGA', "T_FloorMarble_D.TGA"}
index = 1
local image = ImageEx.new(imagenames[index]) 
app.resizeWindow(function(w, h)
    image.renderWidth = w
    image.renderHeight = h
end)

local scene = Scene3D.new()
scene.needSSAO = true
local node = scene:addMesh(mesh3d)
app.render(function(dt)
    -- image:draw()
    -- mesh3d:draw()
    scene:update(dt)
    -- scene:draw(true)
    scene:drawDepth()
    scene:getDepthCanvas():draw()
    love.graphics.print( "Image name: ".. imagenames[index], 10, 10)
end)

app.keypressed(function(key, scancode, isrepeat)
    if key == "space" then
        currentCamera3D.eye = Vector3.sub(currentCamera3D.eye, currentCamera3D.look)
        currentCamera3D.look = Vector3.new(0,0,0)
    end

    if key == "up" then
        index = index +1
        if index == #imagenames +1 then
            index = 1
        end
        image = ImageEx.new(imagenames[index]) 
        image.renderWidth = RenderSet.screenwidth
        image.renderHeight = RenderSet.screenheight

        mesh3d:setCanvas(image)
    end
end)
