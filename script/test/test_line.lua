

local TestLine = Line.new(50, 50, 200, 300)
app.render(function(dt)

    TestLine:draw()
end)

app.mousepressed(function(x, y, button, istouch)
    if button == 1 then
        TestLine.y2 = TestLine.y2 + 10
    else
        TestLine.x2 = TestLine.x2 + 10
    end
end)
