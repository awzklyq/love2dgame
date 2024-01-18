math.randomseed(os.time()%10000)

local width = love.graphics.getPixelWidth() * 1.5 -- love.graphics.getWidth() * 2
local height = love.graphics.getPixelHeight()  * 1.5--love.graphics.getHeight() * 2
local scene = Scene3D.new()
scene.IsDrawBox = true
scene.bgColor = LColor.new(0,0,0,255)

local cubenum = 10

for i = 1, cubenum do
    local mesh3d = Mesh3D.new("assert/obj/taiyang/Sphere.OBJ")
    mesh3d.transform3d:mulTranslationRight(-3000 + 500 * i, -3000 + 500 * i, 800)
    local scale = 3--math.random(0.5, 2)
    mesh3d.transform3d:mulScalingLeft(scale ,scale, scale)
    mesh3d:setBaseColor(LColor.new(math.random() * 255, math.random() * 255, math.random() * 255, 255))

    local node = scene:addMesh(mesh3d)
    node.IsDrawBox = true
end

currentCamera3D.eye = Vector3.new( 525.36051214316, 2852.3172223799, 1982.0588684058)
currentCamera3D.look = Vector3.new( 22.558604721495, -61.107337559643, 5.2498110475302)

local directionlight = DirectionLight.new((currentCamera3D.eye - currentCamera3D.look ):normalize(), LColor.new(255,255,255,255))

local TestRay
app.render(function(dt)
    scene:update(dstlen)
    scene:draw(true) 
end)

app.mousereleased(function(x, y, button, istouch)
    local PickNodes = scene:Pick(x, y)
    if #PickNodes > 0 then
        PickNodes[1].Node.IsDrawBox = not PickNodes[1].Node.IsDrawBox 
    end
end)


-- local checkb = UI.CheckBox.new( 10, 10, 20, 20, "EnablePick" )
-- checkb.IsSelect = EnablePick
-- checkb.ChangeEvent = function(Enable)
--     EnablePick = Enable
-- end
