
local p1 = Point2D.new(-100,-100)
local p2 = Point2D.new(-100, 100)
local p3 = Point2D.new(100, 100)

local _p = Polygon2D.new({p1, p2, p3})
_p:SetRenderPoints(true)
_p:SetRenderEdges(true)

_p.transform:SetTranslation(300, 300)

local _Triangles = {}
local IsDrawTri = false
local _CenterPoint = Point2D.new()
_CenterPoint:SetColor(255, 0, 0, 255)
app.render(function(dt)

    -- _t1:draw()

    _p:draw()

    _CenterPoint:draw()
end)

app.mousepressed(function(x, y, button, istouch)
    if button == 1 then
    elseif button == 2 then
        _p:AddPoint(Point2D.new(x, y))
    else
    end
end)


local btn = UI.Button.new( 10, 10, 150, 30, 'Rotation Matrix2D')

btn.ClickEvent = function()
    _p.transform:MulRotationLeft(10)
end

local btn2 = UI.Button.new( 10, 50, 150, 30, 'Rotation Complex')

local _Complex = Complex.CreateFromAngle(-10)
local _TempComplex = Complex.CreateFromAngle(-10)
btn2.ClickEvent = function()
    _p.transform:RotationComplex(_Complex)
    _Complex = _Complex * _TempComplex
end