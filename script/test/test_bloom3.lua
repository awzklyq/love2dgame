math.randomseed(os.time()%10000)

local width = love.graphics.getPixelWidth() * 1.5 -- love.graphics.getWidth() * 2
local height = love.graphics.getPixelHeight()  * 1.5--love.graphics.getHeight() * 2
local scene = Scene3D.new()
scene.bgColor = LColor.new(0,0,0,255)

local cubenum = 3
for i = 1, cubenum do
    local mesh3d = Mesh3D.new("assert/obj/taiyang/Sphere.OBJ")
    mesh3d.transform3d:mulTranslationRight(-4000 + 1500 * i, -3000 + 1500 * i, 800)
    local scale = 3--math.random(0.5, 2)
    mesh3d.transform3d:mulScalingLeft(scale ,scale, scale)

    local ic = i % 2 == 0 and 1 or 0
    local icc = i % 3 == 0 and 1 or 0
    local iccc = icc * ic == 0 and 1 or 0
    mesh3d:setBaseColor(LColor.new((math.random() * 1000 + 255) * iccc, (math.random() * 1000 + 255) * ic, (math.random() * 1000 + 255) * icc, 255))
    --mesh3d:setBaseColor(LColor.new(1000, 20, 10, 255))
    local node = scene:addMesh(mesh3d)
    -- node.PBR = true
end

currentCamera3D.eye = Vector3.new( 525.36051214316, 2852.3172223799, 1982.0588684058)
currentCamera3D.look = Vector3.new( 22.558604721495, -61.107337559643, 5.2498110475302)

local directionlight = DirectionLight.new((currentCamera3D.eye - currentCamera3D.look ):normalize(), LColor.new(255,255,255,255))
-- local lightnode = scene:addLight(directionlight)
scene.needBloom3 = true
-- scene.needSSAO = true
app.render(function(dt)
    scene:update(dstlen)
    scene:draw(true)

    love.graphics.print( "Press Key A.  Bloom3: "..tostring(scene.needBloom3) .. " Key B TAA " .. tostring(scene.needTAA) .." Key N FXAA " .. tostring(scene.needFXAA).. " Key Z HDR: " .. tostring(RenderSet.HDR), 10, 10)

    love.graphics.print( " Key C needToneMapping: " .. tostring(scene.needToneMapping) .. ' Bloom2.Adapted_lum:' .. tostring(Bloom2.Adapted_lum) .. " Bloom2.ClamptBrightness: " .. tostring(Bloom2.ClamptBrightness), 10, 40)
   
end)

app.keypressed(function(key, scancode, isrepeat)
    if key == "space" then
        log(currentCamera3D.eye.x, currentCamera3D.eye.y, currentCamera3D.eye.z)
        log(currentCamera3D.look.x, currentCamera3D.look.y, currentCamera3D.look.z)
    elseif key == "a" then
        scene.needBloom3 = not scene.needBloom3
    elseif key == "b" then
        scene.needTAA = not scene.needTAA
    elseif key == "n" then
        scene.needFXAA = not scene.needFXAA
    elseif key == "z" then
        RenderSet.HDR = not RenderSet.HDR
        HDRSetting(RenderSet.HDR)

        scene:reseizeScreen(RenderSet.screenwidth, RenderSet.screenheight)
    elseif key == "c" then
        scene.needToneMapping = not scene.needToneMapping
    elseif key == "up" then
        Bloom2.Adapted_lum = math.clamp(0, 1,Bloom2.Adapted_lum  + 0.05)
    elseif key == "down" then
        Bloom2.Adapted_lum = math.clamp(0, 1,Bloom2.Adapted_lum  - 0.05)
    elseif key == "right" then
        Bloom2.ClamptBrightness = math.clamp(0, 1,Bloom2.ClamptBrightness  + 0.05)
    elseif key == "left" then
        Bloom2.ClamptBrightness = math.clamp(0, 1, Bloom2.ClamptBrightness  - 0.05)
    end
end)


