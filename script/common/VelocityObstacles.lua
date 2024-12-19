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

VelocityObstacles.ProcessObj = function(obj)
    if not  WeakObjs[obj] then
        return
    end

    WeakObjs[obj] = {}

    --Genenrate Cone2d 
    local c1 = obj:GetCircle()
    local pos = Vector.new(c1.x, c1.y)
    for i = 1, #Objs do
        if obj ~= Objs[i] then
            local c2 = Objs[i]:GetCircle()
            local c = Circle.new(c1.r + c2.r, c2.x, c2.y)
            math.GetTangentCone2D(pos, c, Cone2Ds[i])
        end
    end


end