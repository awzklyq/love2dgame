_G.Polygon2D = {}

Polygon2D._Meta = {__index = Polygon2D}

function Polygon2D.new(InPoints)
    local p = setmetatable({}, Polygon2D._Meta)

    p.renderid = Render.Polygon2DId ;
    p:Init(InPoints)
    return p
end

function Polygon2D:Init(InPoints)
    self._PointsColor = LColor.new(255, 0, 0,255)
    self._EdgesColor = LColor.new(0, 0, 255,255)
    self._Points = {}
    if InPoints then
        for i = 1, #InPoints do
            self._Points[i] = InPoints[i]
            self._Points[i]:SetColor(self._PointsColor)
        end
    end

    self.Color = LColor.new(255,255,255,255)

    self.LineWidth = 2

    self:ReGenerateRenderData()
    self:ReGenerateEdges()

    self._IsRenderPoints = false
    self._IsRenderEdges = false
end

function Polygon2D:SetPointsColor(...)
    for i = 1, #self._Points do
        self._Points[i]:SetColor(...)
    end

    self._PointsColor:Set(...)
end

function Polygon2D:SetEdgesColor(...)
    for i = 1, #self._Edges do
        self._Edges[i]:SetColor(...)
    end

    self._EdgesColor:Set(...)
end

function Polygon2D:ReGenerateEdges()
    self._Edges = {}
   if #self._Points > 1 then
        for i = 2, #self._Points do
            self._Edges[#self._Edges + 1] = Edge2D.new(self._Points[i - 1], self._Points[i])
        end

         if #self._Points > 2 then
             self._Edges[#self._Edges + 1] = Edge2D.new(self._Points[#self._Points], self._Points[1])
         end

         for i = 1, #self._Edges do
            self._Edges[i]:SetColor(self._EdgesColor)
         end
    end
end

function Polygon2D:AddPoint(InPoint)
    -- self._Edges = {}
    if #self._Points < 3 then
        self._Points[#self._Points  + 1] = InPoint
        self:ReGenerateEdges()
        self:ReGenerateRenderData()
        return
    end

    local Results = {}
    for i = 1, #self._Points do
        local edge = Edge2D.new(InPoint, self._Points[i])
        if self:IsIntersectEdgesToEdge(edge) == false then
            Results[#Results + 1] = i
        end
    end

    _errorAssert(#Results > 1)

    local _Index = _NoneIndex
    for i = 2, #Results do
        if math.abs(Results[i] - Results[i -1]) == 1 then
            _Index = math.max(Results[i], Results[i -1])
        end
    end

    -- if _Index == _NoneIndex then
    --     log("Polygon2D AddPoint：")
    --     logArray(Results)
    -- end
    _errorAssert(_Index ~= _NoneIndex)

    table.insert(self._Points, _Index, InPoint) 
    InPoint:SetColor(self._PointsColor)
    

    self:ReGenerateEdges()
    self:ReGenerateRenderData()
end

function Polygon2D:RemovePoint(InPoint)
    if #self._Points == 0 then
        return 
    end

    for i = 1, #self._Points do
        if self._Points[i] == InPoint then
            table.remove(self._Points, i)
            break
        end
    end

    self:ReGenerateEdges()
    self:ReGenerateRenderData()
end

function Polygon2D:IsIntersectEdgesToEdge(InEdge)
    -- self._Edges = {}

    if #self._Edges == 0 then
        return false
    end

    local Results = {}
    for i = 1, #self._Edges  do
        local edge = self._Edges[i]
        local OutIntersect_p = nil
        if math.IntersectLine(InEdge.P1, InEdge.P2, edge.P1, edge.P2, OutIntersect_p) then
            Results[#Results + 1] = {Edge = edge, Position = OutIntersect_p}
        end
    end

    return #Results > 0
end

function Polygon2D:SetLineWidth(InValue)
    self.LineWidth = InValue
end

function Polygon2D:ReGenerateRenderData()
    self.vertices = {}
    for i = 1, #self._Points do
        self.vertices[#self.vertices + 1] = self._Points[i].x
        self.vertices[#self.vertices + 1] = self._Points[i].y
    end
end

function Polygon2D:SetRenderMode(InMode)
    self.mode = InMode
end

function Polygon2D:SetRenderPoints(InValue)
    self._IsRenderPoints = InValue
end

function Polygon2D:SetRenderEdges(InValue)
    self._IsRenderEdges = InValue
end

function Polygon2D:draw()
    Render.RenderObject(self);

    if self._IsRenderPoints then
        for i = 1, #self._Points do
            self._Points[i]:draw()
        end
    end

    if self._IsRenderEdges then
        for i = 1, #self._Edges do
            self._Edges[i]:draw()
        end
    end
end