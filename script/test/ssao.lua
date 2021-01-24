FileManager.addAllPath("assert")
math.randomseed(os.time()%10000)
local mesh3d = Mesh3D.new("SM_RailingStairs_Internal.OBJ")
mesh3d:setNormalMap("T_Railing_N.TGA")
currentCamera3D.eye = Vector3.new( 33.386304308313, 363.36230638215, 232.64515424476)
currentCamera3D.look = Vector3.new( 22.558604721495, -61.107337559643, 5.2498110475302)
for i = 1, 12 do
    local v = Vector3.new(math.random(-100, 100), math.random(-100, 100), math.random(-100, 100))
    v:normalize()
    v:mulSelf(math.random(1, 3))
    log("vec4 rpos"..tostring(i).." = vec4("..string.format("%0.4f", v.x)..', '..string.format("%0.4f", v.y)..', '..string.format("%0.4f", v.z).. ', 1);')
end

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
    scene:draw(true)
    -- scene:drawDepth()
    -- scene:getDepthCanvas():draw()
    love.graphics.print( "Image name: ".. imagenames[index] .. " SSAO: ".. tostring(scene.needSSAO) .. " SSAOValue: ".. tostring(RenderSet.getSSAOValue()), 10, 10)
end)

app.keypressed(function(key, scancode, isrepeat)
    if key == "space" then
        currentCamera3D.eye = Vector3.sub(currentCamera3D.eye, currentCamera3D.look)
        currentCamera3D.look = Vector3.new(0,0,0)
    end

    if key == "up" then
        -- index = index +1
        -- if index == #imagenames +1 then
        --     index = 1
        -- end
        -- image = ImageEx.new(imagenames[index]) 
        -- image.renderWidth = RenderSet.screenwidth
        -- image.renderHeight = RenderSet.screenheight

        -- mesh3d:setCanvas(image)

        RenderSet.setSSAOValue(RenderSet.getSSAOValue() + 0.0001)
    elseif key == 'down' then
        RenderSet.setSSAOValue(RenderSet.getSSAOValue() - 0.0001)
    end

    if key == "a" then
        scene.needSSAO = not scene.needSSAO
    end
end)
