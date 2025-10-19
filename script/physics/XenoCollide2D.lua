_G.XenoCollide2D = {}

local SuperPoint = function(InPolygon, InDir)
    local _Center = InPolygon:GetCenter()

    local _TempDistance = 10000
    local _TempVector = InDir * _TempDistance
    local _Edge = Edge2D.new(_Center, _TempVector:AsPoint())

    local _Result = InPolygon:IntersectEdgesToEdge(_Edge)
    check(_Result ~= nil)

    return _Result[1].Position
end

-- Return Point2D
local SuperPoint2 = function(InP1, InP2, InDir)
    InDir:Normalize()
    local _p1 = SuperPoint(InP1, InDir)
    local _p2 = SuperPoint(InP2, InDir)

    return _p1 - _p2
end 

local RotationDirection = function(InDirection, InAngle)
    InDirection:Normalize()

    local C = Complex.CreateFromAngle(InAngle)
    local _NewDir = InDirection:AsComplex() * C

    return _NewDir:AsVector()
end

XenoCollide2D.CheckCollidePolygon2D = function(InP1, InP2)
    InP1:ReGenerateEdges()
    InP2:ReGenerateEdges()

    local _Center1 = InP1:GetCenter()

    local _Center2 = InP2:GetCenter()

    local V0 = _Center1 - _Center2

    local _TempDir = RotationDirection((Point2D.Origin -  V0):AsVector(), 45)--V0 - Point2D.Origin
    local V1 = SuperPoint2(InP1, InP2, _TempDir)

    _TempDir = RotationDirection((Point2D.Origin -  V0):AsVector(), -45)
    local V2 = SuperPoint2(InP1, InP2, _TempDir)

    log(V0.x, V0.y, V1.x, V1.y, V2.x, V2.y)

    local _Tri = Triangle2D.new(V0, V1, V2)
    log(_Tri:CheckPointIn(Vector.Origin))
end