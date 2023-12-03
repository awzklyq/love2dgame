local MotionManager = {}
MotionManager.Circle = {}

_G.MovedEntity = {}
function MovedEntity.new()-- lw :line width
    local me = setmetatable({}, {__index = MovedEntity});
    
    me.Data = {} -- {t, v}

    me.Time = 0
    me.PreDistance = 0
    me.Distance = 0
    return me;
end

function MovedEntity:Reset()
    self.PreDistance = 0
end

function MovedEntity:GetDistance()
    return self.Distance
end

function MovedEntity:AddTimeAndDistance(t, v)
    if t > self.Time then
        self.Time = t
    end
    
    self.Distance = math.max(self.Distance, v)
    self.Data[#self.Data + 1] = {t = t, v = v, ov = v}
    table.sort(self.Data, function(a, b)
         return a.t < b.t
    end)
end

function MovedEntity:ScaleDistace(scale)
    for i = 1, #self.Data do
        self.Data[i].v  = self.Data[i].ov * scale
    end
end


function MovedEntity:GetMoveOffset(t)
    t = t
    local st = 0
    local pred = 0
    for i = 1, #self.Data do
        if i ~= 1 then
            st = self.Data[i - 1].t
            pred = self.Data[i - 1].v
        end

        local lerpt = t - st
        local d = self.Data[i]
        if t <= d.t then
            local curdis =  math.lerp(pred, self.Data[i].v, lerpt / (self.Data[i].t - st))--d.v * (t / d.t)
            local dis =  curdis - self.PreDistance
            self.PreDistance = curdis
            -- log('bbbbbb', pred, self.Data[i].v, lerpt, t, st)
            -- log('aaaaaa', self.PreDistance, curdis, dis)
            return dis
        end
   end

   local dis = self.Data[#self.Data].v - self.PreDistance
   self.PreDistance = curdis
   return dis
end

function MovedEntity:IsVaild(t)
    return self.Time >= t 
end

function MovedEntity:Log(info)
    for i = 1, #self.Data do
        local d = self.Data[i]
        log(info, "Time: " .. tostring(d.t), "MoveOffset: " .. tostring(d.v))
    end
 end

_G.MotionCircleEntity = {}
function MotionCircleEntity.new(circle, me, Colliders)-- lw :line width
    local mce = setmetatable({}, {__index = MotionCircleEntity});
    
    mce.Circle = circle

    mce.ME = me

    mce.tick = 0

    mce.ErrorDis = 0

    mce.PreDistance = 0
    mce.Speed = 1


    return mce;
end

function MotionCircleEntity:SetTarget(v)
    self.Target = v
    self.IsArrived = false
    self.Dir = (self.Target - Vector.new(self.Circle.x, self.Circle.y)):normalize()
end

function MotionCircleEntity:SetDirection(dir)
    self.IsArrived = false
    self.Dir = dir:normalize()

    self.Target = self.Dir * (self.Me:GetDistance() - self.PreDistance)
end

function MotionCircleEntity:Start()
    self.ME:Reset()
    self.PreDistance = 0
    if self.Target then
        self.IsArrived = false
        self.tick = 0
        self.ErrorDis = 0
        MotionManager.Circle[#MotionManager.Circle + 1] = self
    end
    
end

function MotionCircleEntity:Stop()
    self.tick = 0

    local Circles = MotionManager.Circle
    for i = 1,  #Circles do
        if Circles[i] == self then
            table.remove(Circles, i)
            break
        end
    end

    self.Target = nil
    self.Dir = nil

    if self.StopEvent then
        self.StopEvent()
    end
end

function MotionCircleEntity:IsMove()
    local Circles = MotionManager.Circle
    for i = 1,  #Circles do
        if Circles[i] == self then
           return true
        end
    end

    return false
end

function MotionCircleEntity:MoveActive(MoveDis)
    local TargetDis = Vector.distance(Vector.new(self.Circle.x, self.Circle.y), self.Target) - self.Circle.r

    if MoveDis >= TargetDis then
        if MoveDis > TargetDis then
            self.ErrorDis = MoveDis - TargetDis
        else
            self.ErrorDis = 0
        end
        MoveDis = TargetDis;
        self.IsArrived = true
    end

    local MoveOffset = self.Dir * MoveDis
    self.PreDistance = self.PreDistance + MoveDis
    self.Circle.x = self.Circle.x + MoveOffset.x
    self.Circle.y = self.Circle.y + MoveOffset.y

    if self.IsArrived and self.ArrviedEvent then
        self.ArrviedEvent(self.Circle, self.Target, self.Dir)
    end
end

function MotionCircleEntity:Update(e)
    self.tick =  self.tick + e * self.Speed

    self.ErrorDis = 0
    local tick = math.min(self.tick, self.ME.Time)

    if self.IsArrived == false then
        local MoveDis = self.ME:GetMoveOffset(self.tick)
        self:MoveActive(MoveDis)
    end

    if self.ME:IsVaild(self.tick) == false then
        self:Stop()
    end
end

function MotionCircleEntity:Release()
    self:Stop()

    self.Circle = nil
end

MotionManager.Update = function(e)
    local Circles = MotionManager.Circle
    for i = 1, #Circles do
        Circles[i]:Update(e)
    end
end

_G.app.update(function(dt)
    MotionManager.Update(dt);
end)

-- _G.app.render(function(e)
--     BulletManager.render(e);
-- end)