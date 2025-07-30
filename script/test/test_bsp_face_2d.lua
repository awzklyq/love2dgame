
local p1 = Point2D.new(150, 150)
local p2 = Point2D.new(250, 150)
local p3 = Point2D.new(150, 250)

local _p = Polygon2D.new({p1, p2, p3})
_p:SetRenderPoints(true)
_p:SetRenderEdges(true)

local _Edge = Edge2D.new((p1 + p2) * 0.5, (p1 + p3) * 0.5)
_Edge:SetColor(255,255,0,255)

local _Triangles = {}
local IsDrawTri = false
app.render(function(dt)

    -- _t1:draw()

    if IsDrawTri then
        for i = 1, #_Triangles do
            _Triangles[i]:draw()
        end
    else
        _p:draw()
        _Edge:draw()
    end
end)

local SetPointColorTest = function(InP, InEdge)
    local _LeftPoints = InP:GetLeftPointsOfEdge(InEdge)
    for i = 1, #_LeftPoints do
        _LeftPoints[i]:SetColor(255, 0, 0, 255)
    end

    local _RightPoints = InP:GetRightPointsOfEdge(InEdge)
    for i = 1, #_RightPoints do
        _RightPoints[i]:SetColor(0, 0, 255, 255)
    end
end
local PIndex= 1 
app.mousepressed(function(x, y, button, istouch)
    if button == 1 then
       if PIndex % 2 == 0 then
            _Edge.P1 = Point2D.new(x, y)
       else
            _Edge.P2 = Point2D.new(x, y)
       end

       PIndex = PIndex + 1

       SetPointColorTest(_p, _Edge)
    elseif button == 2 then
        _p:AddPoint(Point2D.new(x, y))
    else
        log('aaaaaaaaa', tostring(_p:CheckPointIn(Point2D.new(x, y))))
    end
end)


local btn = UI.Button.new( 10, 10, 100, 50, 'Gnerate Triangles', 'btn' )

local IsDrawLine = true
btn.ClickEvent = function()
    _Triangles = _p:GetTriangles()

    for i = 1, #_Triangles do
        _Triangles[i]:SetRenderMode(IsDrawLine and 'line' or 'fill')
    end
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
