local p1 = Vector.new(0, 0)

local p2 = Vector.new(2560, 0)

local p3 = Vector.new(1045.001,  321.001)

local tri = Triangle2D.new(p1, p2, p3)

local check_FillMode = UI.CheckBox.new( 10, 10, 20, 20, "FillMode" )
check_FillMode.ChangeEvent = function(Enable)
    if Enable then
        tri.OutCircle.mode = 'fill'
    else
        tri.OutCircle.mode = 'line'
    end
end

log('aaaaa', tri.OutCircle.x, tri.OutCircle.y, tri.OutCircle.r)
app.render(function(dt)
    tri:draw()
    tri.OutCircle:draw()
end)