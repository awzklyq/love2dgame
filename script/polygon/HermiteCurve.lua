_G.HermiteCurve = {}

function HermiteCurve.new(p1, p2, pd1, pd2, seg)
    local hc = setmetatable({}, {__index = HermiteCurve}); 

    hc.P1 = p1
    hc.P2 = p2
    hc.PD1 = pd1
    hc.PD2 = pd2

    hc.seg = seg or 50

    hc.DebugLines = {}

    hc:GenerateData()
    hc:GenerateDebugLines()

    return hc
end

function HermiteCurve:GenerateData()
    self.A = self.PD1 + self.PD2 + (self.P1 - self.P2) * 2
    self.B = (self.P2 - self.P1) * 3 - self.PD1 * 2 - self.PD2
    self.C = self.PD1
    self.D = self.P1
end

function HermiteCurve:GenerateDebugLines()
    self:GenerateData()
    self.DebugLines = {}
    for i = 0, self.seg - 1 do
        local t1 = i / self.seg
        local t2 = (i + 1) / self.seg

        local p1 = self:GetPoint(t1)
        local p2 = self:GetPoint(t2)
        self.DebugLines[#self.DebugLines + 1] = Line.new(p1.x, p1.y, p2.x, p2.y)
    end
end

function HermiteCurve:GetPoint(t)
    return self.A * t * t * t + self.B * t * t + self.C * t + self.D
end

function HermiteCurve:draw()
    for i = 1, #self.DebugLines do
        self.DebugLines[i]:draw()
    end
end