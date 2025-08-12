
local p1 = Point2D.new(150, 150)
local p2 = Point2D.new(250, 150)
local p3 = Point2D.new(150, 250)

local _p = Polygon2D.new({p1, p2, p3})
_p:SetRenderPoints(true)
_p:SetRenderEdges(true)

local _Triangles = {}
local IsDrawTri = false
local _CenterPoint = Point2D.new()
_CenterPoint:SetColor(255, 0, 0, 255)

FloatageManager.IsDrawWaterLine = true

app.render(function(dt)

    -- _t1:draw()

    _p:draw()

    _CenterPoint:draw()
end)

app.mousepressed(function(x, y, button, istouch)
    if button == 1 then
        -- _p.transform:MulTranslationRight(20,20)
    elseif button == 2 then
        _p:AddPoint(Point2D.new(x, y))
    else
        log('aaaaaaaaa', tostring(_p:CheckPointIn(Point2D.new(x, y))))
    end
end)


local btn = UI.Button.new( 10, 10, 120, 50, 'Begin', 'btn' )

btn.ClickEvent = function()

    _p.transform:SetTranslation(0, 0)
    FloatageManager.AddPolygon2d(_p)
end


local checkb = UI.CheckBox.new( 10, 60, 20, 20, "IsDrawTri" )
checkb.IsSelect = IsDrawTri
checkb.ChangeEvent = function(Enable)
    IsDrawTri = Enable
    _p:SetRenderMode(IsDrawTri and "Triangle" or "Polygon2D")
end

local checkc = UI.CheckBox.new( 10, 90, 20, 20, "IsDrawLine" )
checkc.IsSelect = IsDrawLine
checkc.ChangeEvent = function(Enable)
    IsDrawLine = Enable

    _p:SetTriangleRenderMode(IsDrawLine and 'line' or 'fill')
    -- for i = 1, #_Triangles do
    --     _Triangles[i]:SetRenderMode(IsDrawLine and 'line' or 'fill')
    -- end
end

local _Text = UI.Text.new( "Press Right Button Test", 200, 10, 200, 20 )
_Text:SetNormalColor(0,0,255,255)

local scrollbar = UI.ScrollBar.new( '_Brake Parame', 0, 140, 200, 40, 0.1, 10, 0.1)
scrollbar.Value = FloatageManager._Brake
scrollbar.ChangeEvent = function(v)
    FloatageManager._Brake = v
end