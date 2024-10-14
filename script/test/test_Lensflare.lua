FileManager.addAllPath("assert")

currentCamera3D.eye = Vector3.new(-17, -303,  67)
currentCamera3D.look = Vector3.new( 0, 0, 1)

local SunPlane = BillBoard.new(200, 200)--BillBoard.new(100, 100)

local StartPos = Vector3.new(800, 80, -80)

SunPlane.Position:Set(StartPos)

SunPlane:SetImage(ImageEx.new('BA.png'))

local  Lensflare = {}
local LensflareCount = 5

for i = 1, LensflareCount do
    Lensflare[i] = BillBoard.new(100, 100)
    Lensflare[i]:SetImage(ImageEx.new('flare3.png'))
    Lensflare[i].Position:Set(StartPos)
end

local aixs = Aixs.new(0,0,0, 200)
-- aixs:SetTransform(SunPlane.transform3d)
local mesh3d = Mesh3D.new("Sphere.OBJ")

local NOC = 1
local Mul = 2
local CacleNOC = function()
    local Num = 0
    for i = 1, LensflareCount do
        Num = Num + math.pow(2,  i)
    end

    NOC = Num
    log('aaaaa', NOC)
end

CacleNOC()

local CacleDirection = function()
    local CameraDir = currentCamera3D:GetDirction()
    local TargetDir = (SunPlane.Position - currentCamera3D.eye):normalize()
    local DistanceToSun = Vector3.distance(SunPlane.Position, currentCamera3D.eye)

    local DistanceToCenter = Vector3.dot(CameraDir, TargetDir) * DistanceToSun

    local CenterPos = currentCamera3D.eye + CameraDir * DistanceToCenter
    local MoveDir = (CenterPos - SunPlane.Position):normalize()
    local MoveDis = math.sqrt(DistanceToSun * DistanceToSun - DistanceToCenter * DistanceToCenter) * 2

    local OffsetDis = MoveDis / NOC
    local Num = 0
    for i = 1, LensflareCount do
        Num = Num + math.pow(2,  i);
        Lensflare[i].Position:Set(SunPlane.Position + MoveDir * OffsetDis * Num)
       
        Lensflare[i].Scale.x = Num / NOC
        Lensflare[i].Scale.y = Num / NOC
        Lensflare[i].Scale.z = Num / NOC
        -- Lensflare[i].Position:Set(CenterPos)
    end

    -- log(CameraDir.x, CameraDir.y, CameraDir.z)
    -- log('aaaaa', currentCamera3D.eye.x, currentCamera3D.eye.y, currentCamera3D.eye.z)
    -- log('aaaaa', currentCamera3D.look.x, currentCamera3D.look.y, currentCamera3D.look.z)

    local mat = Matrix3D.new()
    mat:mulTranslationRight(CenterPos.x, CenterPos.y, CenterPos.z)
    mesh3d.transform3d:Set(mat)

end

app.update(function(dt)
    CacleDirection()
end)

app.render(function(dt)
    for i = 1, LensflareCount do
        Lensflare[i]:draw()
    end
    SunPlane:draw()

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

-- local scrollbarR = UI.ScrollBar.new( 'Radius', 10, 40, 200, 40, 10, 100, 1)
-- scrollbarR.Value = 20
-- scrollbarR.ChangeEvent = function(v)
--     SunPlane.Radius = v
-- end

-- local scrollbarP = UI.ScrollBar.new( 'Power', 10, 100, 200, 40, 0.1, 50, 0.1)
-- scrollbarP.Value = 1
-- scrollbarP.ChangeEvent = function(v)
--     SunPlane.LightPower = v
-- end