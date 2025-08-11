
_G.Edge2D = {}


local metatable_Edge2D = {}
metatable_Edge2D.__index = Edge2D

metatable_Edge2D.__eq = function(myvalue, value)
    return (myvalue.P1 == value.P1 and  myvalue.P2 == value.P2) or (myvalue.P1 == value.P2 and  myvalue.P2 == value.P1)
end

function Edge2D.new(p1, p2)
    local edge = setmetatable({}, metatable_Edge2D);

    edge.P1 = p1
    edge.P2 = p2

    if not edge.P1.Edges then
        edge.P1.Edges = {}
    end

    if not edge.P2.Edges then
        edge.P2.Edges = {}
    end

    edge.P1.Edges[#edge.P1.Edges + 1] = edge
    edge.P2.Edges[#edge.P2.Edges + 1] = edge

    edge.Color = LColor.new(255,255,255,255)

    edge.renderid = Render.EdgeId;
    return edge
end

function Edge2D.Copy(edge)
    return Edge2D.new(Vector.Copy(edge.P1), Vector.Copy(edge.P2))
end

function Edge2D:SetColor(InR, InG, InB, InA)
    if InG == nil then
        self.Color:Set(InR)
    else
        self.Color.r = InR
        self.Color.g = InG
        self.Color.b = InB
        self.Color.a = InA
    end
end


function Edge2D:GetOtherPoint(p)
    if self.P1 == p then
        return self.P2
    elseif  self.P2 == p then
        return self.P1
    else
        assert(false)
    end 
end

function Edge2D:CheckPointIn(p)
    return self.P1 == p or self.P2 == p
end


function Edge2D:Log(info)
    if not info then
        info = ''
    else
        info = info .. " "
    end
    self.P1:Log(info .. "Point1")
    self.P2:Log(info .. "Point2")
end

function Edge2D:ChangePoint(p, newp)
    if self.P1 == p then
        self.P1 = newp
    elseif self.P2 == p then
        self.P2 = newp
    -- else
    --     assert(false)
    end 
end

function Edge2D:CheckPointInLeftOfEdge(InPoint)
    local _Center = (self.P1 + self.P2) * 0.5
    local _v1 = InPoint - _Center
    local _v2 = self.P1 - self.P2
    return Vector.angleClockwise(_v1, _v2) >= math.pi
end

function Edge2D:Release()
    for i = 1, #self.P1.Edges do
        if self.P1.Edges[i] == self then
            table.remove( self.P1.Edges, i )
            break
        end
    end

    for i = 1, #self.P2.Edges do
        if self.P2.Edges[i] == self then
            table.remove( self.P2.Edges, i )
            break
        end
    end
end

function Edge2D:CheckIntersectLineOrEdge2D(InObj)
    local IsIntersect = false
    local OutPoint = Point2D.new()
    if InObj.renderid == Render.EdgeId then
        IsIntersect = math.IntersectLine( self.P1, self.P2, InObj:GetP1(), InObj:GetP2(), OutPoint)
    elseif InObj.renderid == Render.LineId then
        IsIntersect = math.IntersectLine( self.P1, self.P2, InObj:StartPoint(), InObj:EndPoint(), OutPoint)
    end
    return IsIntersect, OutPoint
end

function Edge2D:GetP1()
    return self.P1
end

function Edge2D:GetP2()
    return self.P2
end

function Edge2D:GetCenter()
    return (self.P2 + self.P1) * 0.5
end

function Edge2D:draw()
    -- local r, g, b, a = love.graphics.getColor( );
    Render.RenderObject(self);
 
    -- love.graphics.setColor(r, g, b, a );
end