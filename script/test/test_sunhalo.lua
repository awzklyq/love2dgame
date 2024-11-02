
FileManager.addAllPath("assert")

currentCamera3D.eye = Vector3.new(-17, -303,  67)
currentCamera3D.look = Vector3.new( 0, 0, 1)

local SunPlane = BillBoard.new(200, 200)--BillBoard.new(100, 100)

local HaloPlane = BillBoard.new(800, 800)--BillBoard.new(100, 100)

local StartPos = Vector3.new(800, 80, -80)

SunPlane.Position:Set(StartPos)
HaloPlane.Position:Set(StartPos)
SunPlane:SetImage(ImageEx.new('BA.png'))
HaloPlane:SetImage(ImageEx.new('T_Lensflare_01.png'))

local aixs = Aixs.new(0,0,0, 200)
-- aixs:SetTransform(SunPlane.transform3d)
local mesh3d = Mesh3D.new("Sphere.OBJ")

local OriAlpha = HaloPlane.Alpha
local AngleMin = math.cos(math.rad(60))
local AngleMinThreshold = 1.0 - AngleMin
local CacleDirection = function()
    local CameraDir = currentCamera3D:GetDirction()
    local TargetDir = (SunPlane.Position - currentCamera3D.eye):normalize()
    local CTAngle = Vector3.dot(CameraDir, TargetDir);
   
    HaloPlane.Alpha = (CTAngle - AngleMin) / AngleMinThreshold

end

app.update(function(dt)
    CacleDirection()
end)

app.render(function(dt)

    SunPlane:draw()
    HaloPlane:draw()
    -- mesh3d:draw()
    aixs:draw()
end)


app.keypressed(function(key, scancode, isrepeat)
    if key == "space" then
        log(currentCamera3D.eye.x, currentCamera3D.eye.y, currentCamera3D.eye.z)
        log(currentCamera3D.look.x, currentCamera3D.look.y, currentCamera3D.look.z)
    elseif key == 'left' then
        SunPlane.Position.x = SunPlane.Position.x + 10
    elseif key == 'right' then
        SunPlane.Position.x = SunPlane.Position.x - 10
    end
end)


-- local checkb = UI.CheckBox.new( 10, 10, 20, 20, "Test Use Scatter" )
-- checkb.ChangeEvent = function(Enable)
--     if Enable then
--         SunPlane.shader = Shader.GetBillBoardSunInScatterShader()
--     else
--         SunPlane.shader = Shader.GetBillBoardSunShader()
--     end
-- end

local scrollbarR = UI.ScrollBar.new( 'Halo Alpha', 10, 10, 200, 40, 0, 1, 0.01)
scrollbarR.Value = 1
scrollbarR.ChangeEvent = function(v)
    HaloPlane.Alpha = v
end

-- local scrollbarP = UI.ScrollBar.new( 'Power', 10, 100, 200, 40, 0.1, 50, 0.1)
-- scrollbarP.Value = 1
-- scrollbarP.ChangeEvent = function(v)
--     SunPlane.LightPower = v
-- end