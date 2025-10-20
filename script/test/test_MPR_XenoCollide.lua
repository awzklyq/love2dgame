--Minkowski Portal Refinement Demo
local _p1 = Polygon2D.GenerateCircleData(6, 50, 100, 100)
local _p2 = Polygon2D.GenerateCircleData(10, 60, 400, 400)

local IsCollide =  XenoCollide2D.CheckCollidePolygon2D(_p1, _p2)
log('CheckResult:', IsCollide)
app.render(function(dt)
    _p1:draw()
    _p2:draw()
end)

local PIndex= 1 
app.mousepressed(function(x, y, button, istouch)
    _p1 = Polygon2D.GenerateCircleData(6, 50, x, y)

    local IsCollide =  XenoCollide2D.CheckCollidePolygon2D(_p1, _p2)
    log('CheckResult:', IsCollide)
end)

