_G.BezierCurve = {}

function BezierCurve.new(p1, p2, p3, p4, seg)
    local bz = setmetatable({}, {__index = BezierCurve}); 

    bz.P1 = p1
    bz.P2 = p2
    bz.P3 = p3

    if not p1 or not p2 or not p3 then
        _errorAssert(false, "BezierCurve : not p1 or not p2 or not p3 ")
    end

    bz.P4 = p4

    bz.seg = seg or 50

    bz.DebugLines = {}
    bz.DebugPoints = {}
    bz:GenerateDebugLines()

    return bz
end

function BezierCurve:GenerateDebugLines()
    self.DebugLines = {}
    self.DebugPoints = {}
    for i = 0, self.seg - 1 do
        local t1 = i / self.seg
        local t2 = (i + 1) / self.seg

        local p1 = self:GetPoint(t1)
        local p2 = self:GetPoint(t2)
        self.DebugLines[#self.DebugLines + 1] = Line.new(p1.x, p1.y, p2.x, p2.y)
        self.DebugPoints[#self.DebugPoints + 1] = Vector.new(p1.x, p1.y)
    end

    local DebugLine = self.DebugLines[#self.DebugLines]
    self.DebugPoints[#self.DebugPoints + 1] = Vector.new(DebugLine.x2, DebugLine.y2)
end

function BezierCurve:GetPoint(t)
    t = math.clamp(t, 0, 1)
    if self.P4 then
        return self.P1 * math.pow(1 - t, 3) + self.P2 * 3 * t * (1 - t) * (1 - t) + self.P3 * t * t * (1 - t) + self.P4 * t * t * t;
    else
        return self.P1 * (1 - t) * (1 - t) + self.P2  * 2 * t * (1 - t) + self.P3 * t * t;
    end
end

function BezierCurve:draw()
    for i = 1, #self.DebugLines do
        self.DebugLines[i]:draw()
    end
end