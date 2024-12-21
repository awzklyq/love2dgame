_G.VelocityObstacles = {}

local Objs = {}
local Cone2Ds = {}

local WeakObjs = setmetatable({}, {__mode = "kv"})
--obj:GetCircle, GetDirection, GetVelocity
VelocityObstacles.AddObj = function(obj)
    if WeakObjs[obj] then
        return
    end

    WeakObjs[obj] = {}
    Cone2Ds[#Cone2Ds + 1] = Cone2D.new()

    Objs[#Objs + 1] = obj

end

VelocityObstacles.RemoveObj = function(obj)
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


VelocityObstacles.AvoidObstacles = function(InObj, InCone2D, OutData)
    local e = RenderSet.FrameInterval
    local c = InObj:GetCircle()
    local dir = InObj:GetDirection()
    local v = InObj:GetVelocity()

    local NeedRoationAngles = {10, 15, 30, 45, 60, 75, 90}
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
            break
        end

        if OutData.IsFindAngle == false then
        end
    end


    -- local v = dir * InObj:GetF
    -- local pos = Vector.new(in)
end

VelocityObstacles.ProcessObj = function(obj)
    if not  WeakObjs[obj] then
        return
    end

    local e = RenderSet.FrameInterval

    WeakObjs[obj] = {}

    --Genenrate Cone2d 
    local c1 = obj:GetCircle()
    local ObjV = obj:GetVelocity()
    local ObjVdir = Obj:GetDirection()

    local AvoidData = {IsFindAngle = false, FindAngleIndex = 1}
    local OutPosition = Vector.new()
    for i = 1, #Objs do
        if obj ~= Objs[i] then
            local c2 = Objs[i]:GetCircle()
            local c = Circle.new(c1.r + c2.r, c2.x, c2.y)
            math.GetTangentCone2D(pos, c, Cone2Ds[i])

            Objs[i]:GetVelocityTargetFromParame(e, Objs[i]:GetDirection(), Objs[i]:GetVelocity(), OutPosition)
            local v1 = OutPosition - Objs[i]:GetPosition()
            Cone2Ds[i]:MoveVec(v1)

            -- The Object is in cone, Need avoid obstacles
            obj:GetVelocityTargetFromParame(e, obj:GetDirection(), obj:GetVelocity(), OutPosition)
            if Cone2Ds[i]:CheckPointInVec(OutPosition) then

                VelocityObstacles.AvoidObstacles(obj, Cone2Ds[i])
            end
        end
    end


end