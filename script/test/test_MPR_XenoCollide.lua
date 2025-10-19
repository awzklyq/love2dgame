--Minkowski Portal Refinement Demo
local _p1 = Polygon2D.GenerateCircleData(6, 50, 100, 100)
local _p2 = Polygon2D.GenerateCircleData(10, 60, 120, 110)

XenoCollide2D.CheckCollidePolygon2D(_p1, _p2)

app.render(function(dt)
    _p1:draw()
    _p2:draw()
end)
