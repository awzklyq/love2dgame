FileManager.addAllPath("assert")

dofile('script/demo/VelocityObstacles/demo_VOMoveObject.lua')

local mo1 = DemoVOMoveObject.new(200, 200, 50, Vector.new(1, 0))

app.update(function(dt)
end)


app.render(function(dt)
    mo1:draw()
end)

app.mousepressed(function(x, y, button, istouch)
    if button == 1 then
        mo1:MoveToXY(x, y)
    end
end)