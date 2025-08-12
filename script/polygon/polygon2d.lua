_G.Polygon2D = {}

Polygon2D._Meta = {__index = Polygon2D}

function Polygon2D.new(InPoints)
    local p = setmetatable({}, Polygon2D._Meta)

    p.renderid = Render.Polygon2DId ;
    p:Init(InPoints)
    return p
end

function Polygon2D.CreateFromTriangles(InTriangles)
    local _p = Polygon2D.new({})
    _p:SetTriangles(InTriangles)
    return _p
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

    self.transform = Matrix2D.Identity()

    self._RenderMode = "Polygon2D"
    self._TriangleRenderMode = "fill"
end

function Polygon2D:SetTriangles(InTriangles)
    self._Triangles = {}
    for i = 1, #InTriangles do

        self._Triangles[#self._Triangles + 1] = InTriangles[i]
  
    end

    self._Points = {}
    self._Edges = {}
end
function Polygon2D:SetRenderMode(InRenderMode)
    self._RenderMode = InRenderMode or "Polygon2D"
end

function Polygon2D:SetTriangleRenderMode(InMode)
    if not self._Triangles then
        self:GenerateTriangles(true)
    end

    self._TriangleRenderMode = InMode
    for i = 1, #self._Triangles do
        self._Triangles[i]:SetRenderMode(InMode)
    end
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

function Polygon2D:GetPoints()
    return self._Points
end

function Polygon2D:GetLeftPointsOfEdge(InEdge)
    local _Result = {}
    for i = 1, #self._Points do
        if InEdge:CheckPointInLeftOfEdge(self._Points[i]) then
            _Result[#_Result + 1] = self._Points[i]
        end
    end

    return _Result
end

function Polygon2D:GetRightPointsOfEdge(InEdge)
    local _Result = {}
    for i = 1, #self._Points do
        if InEdge:CheckPointInLeftOfEdge(self._Points[i]) == false then
            _Result[#_Result + 1] = self._Points[i]
        end
    end

    return _Result
end

local DealTriangleIntersectByLineOrEdge = function(InPoints_Num1, InPoints_Num2, InObj)
    local P1 = InPoints_Num1[1]
    local P2 = InPoints_Num2[1]
    local P3 = InPoints_Num2[2]

    local P4, P5
    if InObj.renderid == Render.EdgeId then
        P4 = InObj:GetP1()
        P5 = InObj:GetP2()
    else
        P4 = InObj:GetStartPoint()
        P5 = InObj:GetEndPoint()
    end

    local OutP1 = Point2D.new()
    local IsIntersect1 = math.IntersectLine( P1, P2, P4, P5, OutP1)

    local OutP2 = Point2D.new()
    local IsIntersect2 = math.IntersectLine( P1, P3, P4, P5, OutP2)

    _errorAssert(IsIntersect1 and IsIntersect2)

    local t1 = Triangle2D.new(P1, OutP2, OutP1)
    local t2 = Triangle2D.new( OutP1, OutP2, P2)
    local t3 = Triangle2D.new(P2, OutP2, P3)
    local Result = {}
    Result[1] = t1
    Result[2] = t2
    Result[3] = t3

    return Result
end

function Polygon2D:IsHasData()
    if self._Triangles then
        return #self._Triangles > 0
    end

    return #self._Points > 0 or #self._Edges > 0
end

function Polygon2D:CutByLineOrEdge(InObj)
    if not self._Triangles then
        self:GenerateTriangles()
    end

    _LeftTriangles = {}
    _RightTriangles = {}

    for i = 1, #self._Triangles do
        local _tri = self._Triangles[i]:Copy()
        _tri:ApplyTransform(self.transform)
        local _LeftPoints, _RightPoints = _tri:GetPointsOnEachSidesOfLineOrEdge(InObj)
        if #_LeftPoints == 3 then 
            _LeftTriangles[#_LeftTriangles + 1] = _tri
        elseif #_RightPoints == 3 then 
            _RightTriangles[#_RightTriangles + 1] = _tri
        elseif #_LeftPoints == 1 and #_RightPoints == 2 then
            local _Result = DealTriangleIntersectByLineOrEdge(_LeftPoints, _RightPoints, InObj)
            _LeftTriangles[#_LeftTriangles + 1] = _Result[1]
            _RightTriangles[#_RightTriangles + 1] = _Result[2]
            _RightTriangles[#_RightTriangles + 1] = _Result[3]
        elseif #_LeftPoints == 2 and #_RightPoints == 1 then
            local _Result = DealTriangleIntersectByLineOrEdge(_RightPoints, _LeftPoints, InObj)
            _RightTriangles[#_RightTriangles + 1] = _Result[1]
            _LeftTriangles[#_LeftTriangles + 1] = _Result[2]
            _LeftTriangles[#_LeftTriangles + 1] = _Result[3]
        end
    end

    local _LeftP = Polygon2D.CreateFromTriangles(_LeftTriangles)

    _LeftP:SetRenderMode("Triangle")
    _LeftP:SetTriangleRenderMode(self._TriangleRenderMode)
    local _RightP = Polygon2D.CreateFromTriangles(_RightTriangles)
    _RightP:SetRenderMode("Triangle")
    _RightP:SetTriangleRenderMode(self._TriangleRenderMode)
    return _LeftP, _RightP
end

--目前只支持凸多边形
function Polygon2D:CheckPointIn(InPoint)
    local _IsLeft = -1
    for i = 1, #self._Edges do
        if self._Edges[i]:CheckPointInLeftOfEdge(InPoint) then
            if _IsLeft == 0 then
                return false
            end
            _IsLeft = 1 
        else
            if _IsLeft == 1 then
                return false
            end
            _IsLeft = 0
        end
    end

    return true
end
function Polygon2D:UseEarClipGenerateTriangles()
    local _Result = {}
    for i = 1, #self._Points do
        local p = Vector.new(self._Points[i].x, self._Points[i].y)
        p.Order = i

        _Result[#_Result + 1] = p
    end

    _Result[#_Result].IsEnd = true
    _Result[1].IsStart = true

    for i = 1, #_Result - 1 do
        Edge2D.new(_Result[i], _Result[i + 1])
    end
    
    Edge2D.new(_Result[#_Result], _Result[1])
    self._Triangles = EarClip.Process(_Result)

    for i = 1, #self._Triangles do
        self._Triangles[i]:SetRenderMode(self._TriangleRenderMode)
    end
    return self._Triangles
end

function Polygon2D:GetTriangles(InForce)
    if not self._Triangles or InForce == true then
        self:UseEarClipGenerateTriangles()
    end

    return self._Triangles
end

function Polygon2D:GetSurfaceArea(InForce)
    if not self._Triangles or InForce == true then
        self:GenerateTriangles(InForce)
    end

    local _Surface = 0
    for i = 1, #self._Triangles do
        _Surface = _Surface + self._Triangles[i]:GetSurfaceArea()
    end

    return _Surface
end

function Polygon2D:GenerateTriangles(InForce)
    self._Triangles = self:GetTriangles(InForce)
    
    local _AllSurface = self:GetSurfaceArea()
    local _Centroids = {}
    for i = 1, #self._Triangles do
        _Centroids[i] = self._Triangles[i]:GetCenter() * ( self._Triangles[i]:GetSurfaceArea() / _AllSurface )
    end

    self._Centroid = Point2D.new(0, 0)

    for i = 1, #_Centroids do
        self._Centroid = self._Centroid + _Centroids[i]
    end
end

function Polygon2D:GetCenter(InForce)
    if not self._Centroid or InForce == true then
        self:GenerateTriangles(InForce)
    end

    return self._Centroid
end

function Polygon2D:GetSurfaceArea(InForce)
    if not self._Triangles or InForce == true then
        self:GenerateTriangles(InForce)
    end

    local _Surface = 0
    for i = 1, #self._Triangles do
        _Surface = _Surface + self._Triangles[i]:GetSurfaceArea()
    end

    return _Surface
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

function Polygon2D:SetRenderPoints(InValue)
    self._IsRenderPoints = InValue
end

function Polygon2D:SetRenderEdges(InValue)
    self._IsRenderEdges = InValue
end

function Polygon2D:draw()
    --  log('sssssssssss', self._RenderMode, self._RenderMode == "Polygon2D")
    if self._RenderMode == "Polygon2D" then
        Render.RenderObject(self);

        RenderSet.PusMatrix2D(self.transform)
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
        RenderSet.PopMatrix2D()
    else
        RenderSet.PusMatrix2D(self.transform)
        if not self._Triangles then
            self:GenerateTriangles(true)
        end

        for i = 1, #self._Triangles do
            self._Triangles[i]:draw()
        end
        RenderSet.PopMatrix2D()
    end
end