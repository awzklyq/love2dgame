FileManager.addAllPath("assert")
math.randomseed(os.time()%10000)

-- local plane = Mesh3D.new("plane.obj")
-- plane:setBaseColor(LColor.new(125,125,125, 255))

local scene = Scene3D.new()
scene.needSSDO = true
-- scene:addMesh(plane)

local cubenum = 20
for i = 1, cubenum do
    -- local mesh3d = Mesh3D.new("cube.obj")
    local mesh3d = Mesh3D.new("bbb.obj")
    
    -- mesh3d.transform3d:mulTranslationRight(math.random(-150, 150), math.random(-200, 300), math.random(-200, 200))
    -- mesh3d.transform3d:mulScalingLeft(math.random(20, 50), math.random(20, 50), math.random(20, 50))
    -- mesh3d:setBaseColor(LColor.new(math.random(1, 255), math.random(1, 255), math.random(1, 255), 255))

    mesh3d.transform3d:mulTranslationRight(math.random(-1000, 1000), math.random(-500, 500), math.random(-250, 400))
    local scale = math.random(0.5, 3)
    mesh3d.transform3d:mulScalingLeft(scale, scale, scale)
    mesh3d:setBaseColor(LColor.new(math.random(1, 255), math.random(1, 255), math.random(1, 255), 255))


    local node = scene:addMesh(mesh3d)
end

-- mesh3d:setNormalMap("T_Railing_N.TGA")
currentCamera3D.eye = Vector3.new( 33.386304308313, 363.36230638215, 232.64515424476)
currentCamera3D.look = Vector3.new( 22.558604721495, -61.107337559643, 5.2498110475302)


local RenderNormal = false
local RenderDepth = false
app.render(function(dt)
    scene:update(dt)
    scene:draw(true)

    if RenderNormal then
        scene.canvasnormal:draw()
    elseif RenderDepth then
        scene.canvasdepth:draw()
    end
    love.graphics.print( " SSDO: ".. tostring(scene.needSSDO) .. " SSAOValue: ".. tostring(RenderSet.getSSAOValue()).." SSAODepthLimit: ".. tostring(RenderSet.getSSAODepthLimit()) .. " SSDONode.Power： " .. tostring(SSDONode.Power), 10, 10)
end)

app.keypressed(function(key, scancode, isrepeat)
    if key == "space" then
        currentCamera3D.eye = Vector3.sub(currentCamera3D.eye, currentCamera3D.look)
        currentCamera3D.look = Vector3.new(0,0,0)
    end

    if key == "up" then
        RenderSet.setSSAOValue(RenderSet.getSSAOValue() + 1)
    elseif key == 'down' then
        RenderSet.setSSAOValue(RenderSet.getSSAOValue() -  1)
    end

    if key == "left" then
        RenderSet.setSSAODepthLimit(RenderSet.getSSAODepthLimit() + 0.00001)
    elseif key == 'right' then
        RenderSet.setSSAODepthLimit(math.max(RenderSet.getSSAODepthLimit() - 0.00001, 0))
    end

    if key == "a" then
        scene.needSSDO = not scene.needSSDO
    elseif key == 'z' then
        SSDONode.Power = SSDONode.Power - 0.05
    elseif key == 'x' then
        SSDONode.Power = SSDONode.Power + 0.05

    end
end)
