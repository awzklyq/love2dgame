_G.BSplineCurve = {}
BSplineCurve.Meta = {__index = BSplineCurve}
function BSplineCurve.new(InControlPoints, InK)
    local bs = setmetatable({}, BSplineCurve.Meta); 

    bs._ControlPoints = InControlPoints
    bs._K = InK

    bs._MaxKNot = 0
    bs._ControlNumber = #InControlPoints
    _errorAssert(InK < bs._ControlNumber)

    bs:GenerateKnotVector()
    return bs
end

function BSplineCurve:GenerateKnotVector()
    self._KNot = {}
    local m = self._ControlNumber + self._K + 1

    local IK = 0
    for i = 1, m do
        if i <= self._K then
            self._KNot[i] = IK
        elseif m - i <= self._K - 1 then
            self._KNot[i] = IK
        else
            IK = IK + 1
            self._KNot[i] = IK
        end
    end

    self._MaxKNot = IK
end

function BSplineCurve:SplineBasis(InI, InK, InT)
    if InK == 1 then
        if self._KNot[InI] <= InT and InT < self._KNot[InI+1] then
            return 1
        else
            return 0
        end
    else
        local denom1 = self._KNot[InI+InK-1] - self._KNot[InI]
        local denom2 = self._KNot[InI+InK] - self._KNot[InI+1]
        local term1 = 0
        local term2 = 0

        if denom1 ~= 0 then
            term1 = ((InT - self._KNot[InI]) / denom1) * self:SplineBasis(InI, InK-1, InT)
        end

        if denom2 ~= 0 then
            term2 = ((self._KNot[InI+InK] - InT) / denom2) * self:SplineBasis(InI+1, InK-1, InT)
        end

        return term1 + term2
    end
end

function BSplineCurve:GetPointFromT(InT)
    local n = self._ControlNumber

    local p = Vector.new()
    for i = 1, n do
        local basis = self:SplineBasis(i, self._K + 1, InT)
        p.x = p.x + self._ControlPoints[i].x * basis
        p.y = p.y + self._ControlPoints[i].y * basis
    end

    return p
end

function BSplineCurve:GetPoints(InNumber)
    local _Min = 1 -- TODO
    local _Max = self._MaxKNot 

    local PointNumber = InNumber or 100
    local _Step = (_Max - _Min) / PointNumber
    local Results = {}
    Results[1] = self._ControlPoints[1]
    for  i = 1, PointNumber do
        Results[#Results + 1] = self:GetPointFromT(_Min + (i - 1) * _Step)
    end

    Results[#Results + 1] = self._ControlPoints[#self._ControlPoints]
    return Results
end


function BSplineCurve:GenerateDebugLines()
    self._DebugLines = {}
    self._DebugPoints = self:GetPoints()
    for i = 1, #self._DebugPoints - 1 do
        local p1 = self._DebugPoints[i]
        local p2 = self._DebugPoints[i + 1]
        self._DebugLines[#self._DebugLines + 1] = Line.new(p1.x, p1.y, p2.x, p2.y)
    end
end

function BSplineCurve:draw()
    if self._DebugLines then
        for i = 1, #self._DebugLines do
            self._DebugLines[i]:draw()
        end
    end
end