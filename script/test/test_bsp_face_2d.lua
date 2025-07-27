
local p1 = Point2D.new(50, 50)
local p2 = Point2D.new(150, 50)
local p3 = Point2D.new(50, 150)

local _p = Polygon2D.new({p1, p2, p3})
_p:SetRenderPoints(true)
_p:SetRenderEdges(true)
app.render(function(dt)

    -- _t1:draw()

    _p:draw()
end)

local p = Point2D.new(0, 0)
app.mousepressed(function(x, y, button, istouch)
    if button == 1 then
        p = Point2D.new(x, y)
        _p:AddPoint(Point2D.new(x, y))
    elseif button == 2 then
        _p:RemovePoint(p)
    end
end)