local vector = require("script.light.lib.vector")
_G.XenoCollide2D = {}

local SuperPoint = function(InPolygon, InDir, InOriPoint)
    local _Center = InOriPoint or InPolygon:GetCenter()

    local _TempDistance = 10000
    local _TempVector = InDir * _TempDistance
    local _Edge = Edge2D.new(_Center, _TempVector:AsPoint())

    local _Result = InPolygon:IntersectEdgesToEdge(_Edge)
    check(_Result ~= nil)

    return _Result[1].Position
end

-- Return Point2D
local SuperPoint2 = function(InPolygon1, InPolygon2, InDir, InOriPoint)
    InDir:Normalize()
    local _p1 = SuperPoint(InPolygon1, InDir, InOriPoint)
    local _p2 = SuperPoint(InPolygon2, -InDir, InOriPoint)

    return _p1 - _p2
end 

local RotationDirection = function(InDirection, InAngle)
    InDirection:Normalize()

    local C = Complex.CreateFromAngle(InAngle)
    local _NewDir = InDirection:AsComplex() * C

    return _NewDir:AsVector()
end

local GetNewSupport1 = function(InPolygon1, InPolygon2, InP0, InP1, InP2)
    local _TempDir = (InP1 - InP2):AsVector():Normalize()
    _TempDir = RotationDirection(_TempDir, 90)

    local _OriDir = (Point2D.Origin - InP0):AsVector():Normalize()

    if Vector.dot(_TempDir, _OriDir) < 0 then
        _TempDir = -_TempDir
    end

    local _TempP = (InP1 + InP2) * 0.5
    return SuperPoint2(InPolygon1, InPolygon2, _TempDir)
end

local GetNewSupport2 = function(InP, InP0, InP1, InP2)
    local OriDir = (Point2D.Origin - InP0):AsVector():Normalize()
    local _Edge = Edge2D.new(InP0, (OriDir * 10000):AsPoint())

    local _IsLeft = _Edge:CheckPointInLeftOfEdge(InP)
    local _TempEdge1 = Edge2D.new(InP1, InP)
    local _TempEdge2 = Edge2D.new(InP2, InP)
    if _Edge:CheckIntersectLineOrEdge2D(_TempEdge1) then
        return InP1
    elseif _Edge:CheckIntersectLineOrEdge2D(_TempEdge2) then 
        return InP2
    else
        check(false)
    end
end

local GetOtherSupport = function(InPolygon1, InPolygon2, InP0, InP1)
    local OriDir = (Point2D.Origin - InP0):AsVector():Normalize()
    local _Edge = Edge2D.new(InP0, (OriDir * 10000):AsPoint())
    local _IsLeft = _Edge:CheckPointInLeftOfEdge(InP1)

    local _TempDir = InP1 - Point2D.Origin
    local _P = nil
    for i = 45, 315, 45 do
        local _NewDir = RotationDirection(_TempDir:AsVector(), i)
        _P = SuperPoint2(InPolygon1, InPolygon2, _NewDir)
        local _TempEdge = Edge2D.new(InP1, _P)
        if _Edge:CheckIntersectLineOrEdge2D(_TempEdge) then
            break
        end
    end

    check(_P ~= nil)

    return _P
end

local _PreDistance = 0.0
local CheckCollidePolygon2DInner
CheckCollidePolygon2DInner = function(InPolygon1, InPolygon2, InP0, InP1, InP2)
    local _TempP = (InP1 + InP2) * 0.5
    -- local _NewP1 = SuperPoint2(InPolygon1, InPolygon2, _TempP:AsVector())
    local _NewP1 = GetNewSupport1(InPolygon1, InPolygon2, InP0, InP1, InP2)
   
    local _NewP2 = GetNewSupport2(_NewP1, InP0, InP1, InP2)

    local _Tri = Triangle2D.new(InP0, _NewP1, _NewP2)

    if _Tri:CheckPointIn(Vector.Origin) then
        -- log('ccccccccccc', InP0.x, InP0.y, _NewP1.x, _NewP1.y, _NewP2.x, _NewP2.y)
        return true
    end

    local _Distance = Vector.distance(_NewP1, _TempP)
    if math.abs(_Distance - _PreDistance) < math.MinNumber then
        return false
    end

    _PreDistance = _Distance

    -- log('dddddddddddddddddddd', InP0.x, InP0.y, _NewP1.x, _NewP1.y, _NewP2.x, _NewP2.y)
    return CheckCollidePolygon2DInner(InPolygon1, InPolygon2, InP0, _NewP1, _NewP2)
end

XenoCollide2D.CheckCollidePolygon2D = function(InPolygon1, InPolygon2)
    InPolygon1:ReGenerateEdges()
    InPolygon2:ReGenerateEdges()

    _PreDistance = math.MaxNumber 
    local _Center1 = InPolygon1:GetCenter()

    local _Center2 = InPolygon2:GetCenter()

    local V0 = _Center1 - _Center2

    local _TempDir = RotationDirection((Point2D.Origin -  V0):AsVector(), 45)--V0 - Point2D.Origin
    local V1 = SuperPoint2(InPolygon1, InPolygon2, _TempDir)

    local V2 = GetOtherSupport(InPolygon1, InPolygon2, V0, V1)

    local _Tri = Triangle2D.new(V0, V1, V2)
    if _Tri:CheckPointIn(Vector.Origin) then
        return true
    end

    return CheckCollidePolygon2DInner(InPolygon1, InPolygon2, V0, V1, V2)
end