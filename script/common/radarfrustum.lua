_G.RadarFrustum2D = {}
function RadarFrustum2D.new(pos, dir, fov, near, far)
    local frustum = setmetatable({}, {__index = RadarFrustum2D});
    frustum.FOV = fov
    frustum.Far = far
    frustum.Near = near
    frustum.Position = pos
    frustum.Direction = dir
    frustum.Direction:normalize()

    frustum.Forward =  frustum.Direction * far
    
    frustum.TanFactor = math.tan(frustum.FOV * 0.5)

    frustum.RLmit = frustum.Far * frustum.TanFactor;
    frustum.Right = frustum.Forward + Vector.new(frustum.Direction.y, -frustum.Direction.x) * frustum.RLmit

    frustum.RightNormalize = Vector.copy(frustum.Right):normalize()
    return frustum
end

function RadarFrustum2D:SetDirection(dir)
    self.Direction = dir
    self.Direction:normalize()

    self.Forward = self.Direction * self.Far
    self.Right = self.Forward + Vector.new(self.Direction.y, -self.Direction.x) * self.RLmit
    self.RightNormalize = Vector.copy(self.Right):normalize()
end

function RadarFrustum2D:SetFar(far)
    self.Far = far
    self.Forward = self.Direction * self.Far

    self.RLmit = self.Far * self.TanFactor;
    self.Right = self.Forward + Vector.new(self.Direction.y, -self.Direction.x) * self.RLmit
    self.RightNormalize = Vector.copy(self.Right):normalize()
end

function RadarFrustum2D:IsPointIn(point)
    local OP = point - self.Position
    local f = Vector.dot(OP, self.Direction)

    if f < self.Near or f > self.Far then
        return false
    end

    local r = Vector.dot(OP, self.RightNormalize)
    local rlimt = (f / self.Far) * self.RLmit
    if r < 0 or r > rlimt * 1.5 then -- r < -rlimt or r > rlimt TODO..
        return false
    end

    return true
end

function RadarFrustum2D:GetTriangle()
    local pos1 = Vector.copy(self.Position)

    local pos2 = self.Position + self.Right
    local pos3 = self.Position + self.Forward - Vector.new(self.Direction.y, -self.Direction.x) * (self.RLmit)

    return Triangle2D.new(pos1, pos2, pos3, 3)
end

function RadarFrustum2D:GetNearLine()

    local BasePos = self.Position + (self.Direction * self.Near)
    local dis = self.RLmit * (self.Near / self.Far)
  
    local pos1 = BasePos - Vector.new(self.Direction.y, -self.Direction.x) * dis
    local pos2 = BasePos + Vector.new(self.Direction.y, -self.Direction.x) * dis

    return Line.new(pos1.x, pos1.y, pos2.x, pos2.y, 3)
end