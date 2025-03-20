
_G.TestDebug = false
local TestCube = Mesh3D.CreateCube()
TestCube.transform3d:Scale(2, 10, 2)

TestCube:SetBaseColor(LColor.new(0, 0, 180,255))

local TempTrangles = TestCube:GenerateTrangle3D()

local IsDrawLines = false
local _SwitchColorIndex = 0
app.render(function(dt)
    if IsDrawLines then
        if _SwitchColorIndex == 0 then
            for i = 1, #TempTrangles do
                TempTrangles[i]:draw()
            end
        else
            TempTrangles[_SwitchColorIndex]:draw()
        end
    else
        TestCube:draw()
    end
    
end)

-- 向量操作函数
local function dot(a, b)
    return a.x * b.x + a.y * b.y + a.z * b.z
end

local function cross(a, b)
    return {
        x = a.y * b.z - a.z * b.y,
        y = a.z * b.x - a.x * b.z,
        z = a.x * b.y - a.y * b.x
    }
end

local function normalize(v)
    local len = math.sqrt(v.x * v.x + v.y * v.y + v.z * v.z)
    return { x = v.x / len, y = v.y / len, z = v.z / len }
end

-- 射线与三角形求交算法
local function RayTriangleIntersectionAndBary(RayStart, RayDir, RayLength, A, B, C)
    local AB = { x = B.x - A.x, y = B.y - A.y, z = B.z - A.z } -- edge 1
    local AC = { x = C.x - A.x, y = C.y - A.y, z = C.z - A.z } -- edge 2
    local Normal = cross(AB, AC) -- 三角形法线
    local NegRayDir = { x = -RayDir.x, y = -RayDir.y, z = -RayDir.z }

    local Den = dot(NegRayDir, Normal)
    if math.abs(Den) < 1e-6 then -- 平行或远离
        return false
    end

    local InvDen = 1.0 / Den
    local RayToA = { x = RayStart.x - A.x, y = RayStart.y - A.y, z = RayStart.z - A.z }
    local Time = dot(RayToA, Normal) * InvDen
    if Time < 0 or Time > RayLength then -- 交点不在射线上
        return false
    end

    local RayToACrossNegDir = cross(NegRayDir, RayToA)
    local UU = dot(AC, RayToACrossNegDir) * InvDen
    if UU < -1e-6 or UU > 1 + 1e-6 then -- 交点在三角形外
        return false
    end

    local VV = -dot(AB, RayToACrossNegDir) * InvDen
    if VV < -1e-6 or (VV + UU) > 1 + 1e-6 then -- 交点在三角形外
        return false
    end

    -- 计算输出结果
    local OutT = Time
    local OutBary = { UU, VV }
    local OutN = normalize(Normal)
    OutN.x = OutN.x * (Den > 0 and 1 or -1)
    OutN.y = OutN.y * (Den > 0 and 1 or -1)
    OutN.z = OutN.z * (Den > 0 and 1 or -1)

    return true, OutT, OutBary, OutN
end

app.mousepressed(function(x, y, button, istouch)
   
    local ray = Ray.BuildFromScreen(x, y)
    local dis = TestCube:PickByRay(ray)

    local IsPick, _, _, _ = RayTriangleIntersectionAndBary(ray.orig, ray.dir)
    if dis > 0 then
        log('Pick Mesh!')
    end
end)

function SwitchDebugColor()
    if _SwitchColorIndex >= 1 and _SwitchColorIndex <= #TempTrangles then
        TempTrangles[_SwitchColorIndex]:SetBaseColor(LColor.new(255,255,255,255))
    end
    _SwitchColorIndex = _SwitchColorIndex + 1
    if _SwitchColorIndex > #TempTrangles then
        _SwitchColorIndex = 0
    end

    if _SwitchColorIndex >= 1 and _SwitchColorIndex <= #TempTrangles then
        TempTrangles[_SwitchColorIndex]:SetBaseColor(LColor.new(255,0,0,255))
    end

    log('SwitchDebugColor: ', _SwitchColorIndex)
end

function LogDebugPoint()
    if _SwitchColorIndex > 1 and _SwitchColorIndex <= #TempTrangles then
        TempTrangles[_SwitchColorIndex]:LogDebugPoint()
       
    end
end

app.keypressed(function(key, scancode, isrepeat)
    if key == "space" then
        SwitchDebugColor()
    elseif key == "z" then
        LogDebugPoint()
    end
end)

currentCamera3D.eye = Vector3.new( 50, 50, -50)
currentCamera3D.look = Vector3.new( 0 , 0, 0)

local checkb = UI.CheckBox.new( 10, 10, 20, 20, "IsDrawLines" )
checkb.ChangeEvent = function(Enable)
    IsDrawLines = Enable
end
