_G.LMVelocityObstacles = {}

LMVelocityObstacles.IsDrawCone2D = false

local Objs = {}
local Cone2Ds = {}

LMVelocityObstacles.AvoidPower = 0.7

local WeakObjs = setmetatable({}, {__mode = "k"})
--obj:GetCircle, GetDirection, GetVelocity
LMVelocityObstacles.AddObj = function(obj)
    if WeakObjs[obj] then
        return
    end

    -- Obj need IsNeedAvoidObstacles true
    WeakObjs[obj] = {}
    Cone2Ds[#Cone2Ds + 1] = Cone2D.new()

    Objs[#Objs + 1] = obj

end

LMVelocityObstacles.RemoveObj = function(obj)
    if not WeakObjs[obj] then
        return
    end

    WeakObjs[obj] = nil

    for i = #Objs, 1, -1 do
        if Objs[i] == obj then
            table.remove(Objs, i)
            table.remove(Cone2Ds, i)
            break
        end
    end

end


LMVelocityObstacles.AvoidObstacles = function(InObj, InCone2D, OutData)
    local e = RenderSet.FrameInterval
    local c = InObj:GetCircle()
    local dir = InObj:GetTargetDirection()
    local v = InObj:GetVelocity()

    local NeedRoationAngles = {15, 30, 45, 75, 90, 120, 150}
    local OutPosition = Vector.new()
    local FindAngle = 0
    
    OutData.IsFindAngle = false
    for i = OutData.FindAngleIndex, #NeedRoationAngles do
        local defaultdir = Vector.copy(dir)
        defaultdir:RotateClockwise(NeedRoationAngles[i])
        
        InObj:GetVelocityTargetFromParame(e, defaultdir, v, OutPosition)

        if not InCone2D:CheckPointInVec(OutPosition) then
            FindAngle = NeedRoationAngles[i]
            FindAngleIndex = i
            OutData.FindAngleIndex = i
            OutData.IsFindAngle = true

            local HarfDir = Vector.copy(dir)
            HarfDir:RotateClockwise(NeedRoationAngles[i] *LMVelocityObstacles.AvoidPower)
            OutData.FindDir:Set(HarfDir)
            break
        end

        --TODO..
        if OutData.IsFindAngle == false then
        end
    end


    -- local v = dir * InObj:GetF
    -- local pos = Vector.new(in)
end

LMVelocityObstacles.ProcessObj = function(obj)
    if not  WeakObjs[obj] then
        return
    end

    local e = RenderSet.FrameInterval

    WeakObjs[obj] = {}

    --Genenrate Cone2d 
    local c1 = obj:GetCircle()
    local ObjV = obj:GetVelocity()
    local ObjVdir = obj:GetTargetDirection()

    local AvoidData = {IsFindAngle = false, FindAngleIndex = 1, FindDir = Vector.new()}
    local OutPosition = Vector.new()
    local pos = Vector.copy(obj:GetPosition())
    for i = 1, #Objs do
        if obj ~= Objs[i] then
            local c2 = Objs[i]:GetCircle()
            local c = Circle.new(c1.r + c2.r, c2.x, c2.y)
            math.GetTangentCone2D(pos, c, Cone2Ds[i])
            if  Cone2Ds[i]:GetAngle() < math.pi * 0.5 then
                Objs[i]:GetVelocityTargetFromParame(e, Objs[i]:GetTargetDirection(), Objs[i]:GetVelocity(), OutPosition)
                local v1 = OutPosition - Objs[i]:GetPosition()
                Cone2Ds[i]:MoveVec(v1)
    
                -- The Object is in cone, Need avoid obstacles
                obj:GetVelocityTargetFromParame(e, obj:GetTargetDirection(), obj:GetVelocity(), OutPosition)
                if Cone2Ds[i]:CheckPointInVec(OutPosition) then
                    -- log(Cone2Ds[i], pos.x, pos.y, Cone2Ds[i].pos.x, Cone2Ds[i].pos.y )
                    LMVelocityObstacles.AvoidObstacles(obj, Cone2Ds[i], AvoidData)
                    --TODO, Angle is accumulate..
                    if AvoidData.IsFindAngle then
                        obj:SetFixDirection(AvoidData.FindDir)
                    end
                end
            else
                local defaultdir = Vector.copy(ObjVdir)
                defaultdir:RotateClockwise(90 * LMVelocityObstacles.AvoidPower)
                obj:SetFixDirection(defaultdir)

                AvoidData.FindAngleIndex =  5
                AvoidData.FindDir:Set(defaultdir)
                -- log(Cone2Ds[i], ObjVdir.x, ObjVdir.y, defaultdir.x, defaultdir.y )
            end
        end
    end
end

LMVelocityObstacles.Process = function()
    if #Objs <= 1 then return end

    for i = 1, #Objs do
        if Objs[i].IsNeedAvoidObstacles and  Objs[i]:IsMoving() then
            LMVelocityObstacles.ProcessObj(Objs[i])
        end
    end
end

app.update(function(dt)
    LMVelocityObstacles.Process()
end)

app.render(function(dt)
    if LMVelocityObstacles.IsDrawCone2D then
        for i = 1, #Cone2Ds do
            -- if not Objs[i].IsNeedAvoidObstacles then
                -- log(Objs[i].CurPos.x, Objs[i].CurPos.y, Cone2Ds[i].pos.x, Cone2Ds[i].pos.y)
                Cone2Ds[i]:draw()
            -- end
        end
    end
end)