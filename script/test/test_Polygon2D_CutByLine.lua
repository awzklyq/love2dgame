
local p1 = Point2D.new(150, 150)
local p2 = Point2D.new(250, 150)
local p3 = Point2D.new(150, 250)

local _p = Polygon2D.new({p1, p2, p3})
_p:SetRenderPoints(true)
_p:SetRenderEdges(true)

local _P1, _P2 = nil, nil

local _Edge = Edge2D.new((p1 + p2) * 0.5, (p1 + p3) * 0.5)
_Edge:SetColor(255,255,0,255)

local _Triangles = {}
local IsDrawTri = false
local _CenterPoint = Point2D.new()
_CenterPoint:SetColor(255, 0, 0, 255)

local IsDrawSubPolygon = false
local IsDrawCutEdge = true
app.render(function(dt)

    -- _t1:draw()

    if IsDrawSubPolygon then
        if _P1 then
            _P1:draw()
        end

        if _P2 then
            _P2:draw()
        end
    else
    if IsDrawTri then
        for i = 1, #_Triangles do
            _Triangles[i]:draw()
        end
    else
        _p:draw()
    end
end
    _CenterPoint:draw()

    if IsDrawCutEdge then
        _Edge:draw()
    end
end)

local PIndex= 1 
app.mousepressed(function(x, y, button, istouch)
    if button == 1 then
        if PIndex % 2 == 0 then
            _Edge.P1 = Point2D.new(x, y)
       else
            _Edge.P2 = Point2D.new(x, y)
       end

       PIndex = PIndex + 1
    elseif button == 2 then
        _p:AddPoint(Point2D.new(x, y))
    else
       _p.transform:MulTranslationRight(50, 50)
       _p.transform:MulRotationLeft(45)
    end
end)


local btn = UI.Button.new( 10, 10, 120, 50, 'Gnerate Triangles Data', 'btn' )

btn.ClickEvent = function()
    _p:GenerateTriangles(true)

    _Triangles = _p:GetTriangles()
    for i = 1, #_Triangles do
        _Triangles[i]:SetRenderMode('line' )
        _Triangles[i]:ApplyTransform(_p.transform)

    end

    _CenterPoint = _p:GetCenter()
    _CenterPoint:SetColor(255, 0, 0, 255)
end

local btn2 = UI.Button.new( 150, 10, 120, 50, 'Cut Polygons', 'btn' )

btn2.ClickEvent = function()
    _P1, _P2 = _p:CutByLineOrEdge(_Edge)

    _P1:SetTriangleRenderMode("line")
    _P2:SetTriangleRenderMode("line")
end


local checkb = UI.CheckBox.new( 10, 60, 20, 20, "IsDrawTri" )
checkb.IsSelect = IsDrawTri
checkb.ChangeEvent = function(Enable)
    IsDrawTri = Enable
end

local checkc = UI.CheckBox.new( 10, 90, 20, 20, "IsDrawLine" )
checkc.IsSelect = IsDrawLine
checkc.ChangeEvent = function(Enable)
    IsDrawLine = Enable

    for i = 1, #_Triangles do
        _Triangles[i]:SetRenderMode(IsDrawLine and 'line' or 'fill')
    end
end

local checkd = UI.CheckBox.new( 10, 110, 20, 20, "IsDrawSubPolygon" )
checkd.IsSelect = IsDrawSubPolygon
checkd.ChangeEvent = function(Enable)
    IsDrawSubPolygon = Enable
end

local checkd = UI.CheckBox.new( 10, 160, 20, 20, "IsDrawCutEdge" )
checkd.IsSelect = IsDrawCutEdge
checkd.ChangeEvent = function(Enable)
    IsDrawCutEdge = Enable
end
