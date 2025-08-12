_G.Triangle2D = {}

function Triangle2D.new(p1, p2, p3, IsNeedEdge, linewidth)-- Vector2 or Vector3...
    local tri = setmetatable({}, {__index = Triangle2D});

    tri.P1 = p1.renderid == Render.Point2Id and p1 or p1:ToPoint2D()
    tri.P2 = p2.renderid == Render.Point2Id and p2 or p2:ToPoint2D()
    tri.P3 = p3.renderid == Render.Point2Id and p3 or p3:ToPoint2D()

    tri.Color = LColor.new(255,255,255,255)

    tri.LineWidth = linewidth or 2

    if IsNeedEdge or IsNeedEdge == nil then
        tri.edge1 = Edge2D.new(tri.P1, tri.P2)
        tri.edge2 = Edge2D.new(tri.P2, tri.P3)
        tri.edge3 = Edge2D.new(tri.P3, tri.P1)

        if not tri.edge1.ThirdPoints then
            tri.edge1.ThirdPoints = {}
        end

        if not tri.edge2.ThirdPoints then
            tri.edge2.ThirdPoints = {}
        end

        if not tri.edge3.ThirdPoints then
            tri.edge3.ThirdPoints = {}
        end

        tri.edge1.ThirdPoints[#tri.edge1.ThirdPoints + 1] = tri.P3
        tri.edge2.ThirdPoints[#tri.edge2.ThirdPoints + 1] = tri.P1
        tri.edge3.ThirdPoints[#tri.edge3.ThirdPoints + 1] = tri.P2
    end

    tri.mode = "line"

    tri.vertices = {}
    tri:GetVertices()

    tri.renderid = Render.Triangle2DId ;

    tri:GenerateOutCircle()

    tri._IsDrawEdges = false

    return tri
end

function Triangle2D:ApplyTransform(InTransform)
    self.P1 = InTransform * self.P1
    self.P2 = InTransform * self.P2
    self.P3 = InTransform * self.P3

    self:GetVertices()
end

function Triangle2D:Copy()
    return Triangle2D.new(self.P1:Copy(), self.P2:Copy(), self.P3:Copy())
end

function Triangle2D:GetSurfaceArea()
    local v1 = self.P2 - self.P1
    local v2 = self.P3 - self.P1
    return math.abs(Vector.cross(v1, v2) * 0.5)
end
--InMode-> fill or line
function Triangle2D:SetRenderMode(InMode)
    self.mode = InMode
end

function Triangle2D:SetDrawEdges(InValue)
    self._IsDrawEdges = InValue
end

function Triangle2D:SetEdgesColor(...)
    self.edge1:SetColor(...)
    self.edge2:SetColor(...)
    self.edge3:SetColor(...)
end



function Triangle2D:HasPoint(p)
    return self.P1 == p or self.P2 == p or self.P3 == p
end

function Triangle2D.PointsEnableBuildTriagnle(p1, p2, p3)
    if p1.x == p2.x  and p2.x == p3.x then
        return false
    end

    if p1.y == p2.y  and p2.y == p3.y then
        return false
    end

    if p1.x == p2.x  and p2.x == p3.x then
        return false
    end

    if p1.y == p2.y  and p2.y == p3.y then
        return false
    end

    return Vector.cross(p2 - p1, p3 - p1) ~= 0
end

function Triangle2D:Release()
    self.edge1:Release()
    self.edge2:Release()
    self.edge3:Release()
end


function Triangle2D:Log(info)
    if not info then
        info = ''
    else
        info = info .. " "
    end
    log("self : ", self)
    self.P1:Log(info .. "Point1")
    self.P2:Log(info .. "Point2")
    self.P3:Log(info .. "Point3")
    log()
end

function Triangle2D:SetColor(r, g, b, a)
    self.Color.r = r
    self.Color.g = g
    self.Color.b = b
    self.Color.a = a
end

function Triangle2D:GetVertices()
    self.vertices = {}
    self.vertices[#self.vertices + 1] = self.P1.x
    self.vertices[#self.vertices + 1] = self.P1.y

    self.vertices[#self.vertices + 1] = self.P2.x
    self.vertices[#self.vertices + 1] = self.P2.y

    self.vertices[#self.vertices + 1] = self.P3.x
    self.vertices[#self.vertices + 1] = self.P3.y
end

function Triangle2D:CheckInLeftOfLineOrEdge(InObj)
    return self.P1:CheckInLeftOfLineOrEdge(InObj) and self.P2:CheckInLeftOfLineOrEdge(InObj) and self.P3:CheckInLeftOfLineOrEdge(InObj)
end

function Triangle2D:CheckInRightOfLineOrEdge(InObj)
    return self.P1:CheckInLeftOfLineOrEdge(InObj) == false and self.P2:CheckInLeftOfLineOrEdge(InObj) == false and self.P3:CheckInLeftOfLineOrEdge(InObj) == false
end

function Triangle2D:GetPointsOnEachSidesOfLineOrEdge(InObj)
    local LeftPoints = {}
    local RightPoints = {}
    if self.P1:CheckInLeftOfLineOrEdge(InObj) then
        LeftPoints[#LeftPoints + 1] = self.P1
    else
        RightPoints[#RightPoints + 1] = self.P1
    end

    if self.P2:CheckInLeftOfLineOrEdge(InObj) then
        LeftPoints[#LeftPoints + 1] = self.P2
    else
        RightPoints[#RightPoints + 1] = self.P2
    end

    if self.P3:CheckInLeftOfLineOrEdge(InObj) then
        LeftPoints[#LeftPoints + 1] = self.P3
    else
        RightPoints[#RightPoints + 1] = self.P3
    end

    return LeftPoints, RightPoints
end

function Triangle2D:GetEdgeEqual(edge)
    if self.edge1 == edge then
        return self.edge1
    elseif self.edge2 == edge then
        return self.edge2
    elseif self.edge3 == edge then
        return self.edge3
    end

    return nil
end

function Triangle2D:FindOneEdge(tri)
   local result = self:GetEdgeEqual(tri.edge1)
   if result then
        return result
   end

   result = self:GetEdgeEqual(tri.edge2)
   if result then
        return result
   end

   result = self:GetEdgeEqual(tri.edge3)
   if result then
        return result
   end

   return nil
end

function Triangle2D:GetOtherPointFromEdge(edge)
    if edge:CheckPointIn(self.P1) == false then
        return self.P1 
    elseif edge:CheckPointIn(self.P2) == false then
        return self.P2
    elseif edge:CheckPointIn(self.P3) == false then
        return self.P3 
    else
        errorAssert(false, "Triangle2D GetOtherPointFromEdge")
    end

end

function Triangle2D:GetOutCircleCenter()
    local x1, y1 = self.P1.x, self.P1.y
    local x2, y2 = self.P2.x, self.P2.y
    local x3, y3 = self.P3.x, self.P3.y

    local x0 = ((y2 - y1) * (y3 * y3 - y1 * y1 + x3 * x3 - x1 * x1) - (y3 - y1) * (  y2 * y2 - y1 * y1 + x2 * x2 - x1 * x1)) /  (2 * (x3 - x1) * (y2 - y1) - 2 * (x2 - x1) * (y3 - y1))
    
    local y0 = ((x2 - x1) * (x3 * x3 - x1 * x1 + y3 * y3 - y1 * y1) - (x3 - x1) * ( x2 * x2 - x1 * x1 + y2 * y2 - y1 * y1)) / (2 * (y3 - y1) * (x2 - x1) - 2 * (y2 - y1) * (x3 - x1))

    return Vector.new(x0, y0)
end

function Triangle2D:GenerateOutCircle()
    local center = self:GetOutCircleCenter()
    local r = Vector.distance(center, self.P1)
    self.OutCircle = Circle.new(r, center.x , center.y) 
end

function Triangle2D:IntersectEdgeNotSampePoint(edge)
    local IsIntersect1 = false
    if self.edge1:CheckPointIn(edge.P1) == false and self.edge1:CheckPointIn(edge.P2) == false then
        IsIntersect1 = math.IntersectLine(edge.P1, edge.P2, self.edge1.P1, self.edge1.P2)
    end

    if IsIntersect1 then
        return self.edge1
    end

    local IsIntersect2 = false
    if self.edge2:CheckPointIn(edge.P1) == false and self.edge2:CheckPointIn(edge.P2) == false then
        IsIntersect2 = math.IntersectLine(edge.P1, edge.P2, self.edge2.P1, self.edge2.P2)
    end

    if IsIntersect2 then
        return self.edge2
    end

    local IsIntersect3 = false
    if self.edge3:CheckPointIn(edge.P1) == false and self.edge3:CheckPointIn(edge.P2) == false then
        IsIntersect3 = math.IntersectLine(edge.P1, edge.P2, self.edge3.P1, self.edge3.P2)
    end

    if IsIntersect3 then
        return self.edge3
    end

    return nil
end

function Triangle2D:IntersectTriangleNotSampePoint(tri)
    local edge1 = self:IntersectEdgeNotSampePoint(tri.edge1)
    if edge1 then
        return edge1, tri.edge1
    end

    local edge2 = self:IntersectEdgeNotSampePoint(tri.edge2)
    if edge2 then
        return edge2, tri.edge2
    end

    local edge3 = self:IntersectEdgeNotSampePoint(tri.edge3)
    if edge3 then
        return edge3, tri.edge3
    end
    
    return nil, nil
end

function Triangle2D:draw()
    -- local r, g, b, a = love.graphics.getColor( );
    Render.RenderObject(self);
    -- love.graphics.setColor(r, g, b, a );

    if self._IsDrawEdges then
        self.edge1:draw()
        self.edge2:draw()
        self.edge3:draw()
    end
end

function Triangle2D:CheckPointInOutCircle(Point)
    return self.OutCircle:CheckPointIn(Point)
end

function Triangle2D:CheckOnePoint(Point)
   return self.P1 == Point or self.P2 == Point or self.P3 == Point
end

function Triangle2D:CheckTriangleEqual(tri)
    return self:CheckOnePoint(tri.P1) and self:CheckOnePoint(tri.P2) and self:CheckOnePoint(tri.P3)
end

function Triangle2D:CheckPointIn(Point)
    local v1 = (self.P1 - Point):ToVector():normalize()
    local v2 = (self.P2 - Point):ToVector():normalize()
    local v3 = (self.P3 - Point):ToVector():normalize()

    local a1 = Vector.angle(v1, v2)
    local a2 = Vector.angle(v2, v3)
    local a3 = Vector.angle(v3, v1)

    if math.abs((a1 + a2 + a3) - math.c2pi) > math.cEpsilon then
        return false
    end

    return true;
end

function Triangle2D:SetMouseEventEable(enable)
    AddEventToPolygonevent(self, enable)
end


function Triangle2D:CheckPointInXY(x, y)
    return self:CheckPointIn(Vector.new(x, y))
end

function Triangle2D:GetCenter()
    return (self.P1 + self.P2 + self.P3) / 3
end


_G.Triangle2Ds = {}

function Triangle2Ds.new(vertices)-- Vector2 or Vector3...
    local tris = setmetatable({}, {__index = Triangle2Ds});

    tris.Triangles = {}
    if vertices and #vertices > 0 then
    
        local count = math.floor( #vertices / 3) * 3
        if count > 0 then
            for i = 1, count, 3 do
                tris.Triangles[#tris.Triangles + 1] = Triangle2D.new(vertices[i], vertices[i + 1], vertices[i + 2])
            end
        end
    end

    return tris;
end

function Triangle2Ds:GenerateRandomPoints(TriangleCount, StartPoint, EndPoint)
    for i = 1, TriangleCount do
        tris.Triangles[#tris.Triangles + 1] = Triangle2D.new(vertices[i], vertices[i + 1], vertices[i + 2])
    end
end