local c2d = Cone2D.new(Vector.new(0,0), Vector.new(1,-1):normalize(), 100, 45)


local c = Circle.new(100, 300 ,300)
local rect = Rect.new(200, 200, 8, 8, 'fill')
rect:SetColor(255, 0, 0, 255)

function CacleCone(InRect, InCircle, OutC2d)
    local Pos = Vector.new(InRect.x, InRect.y)
    local CPos = Vector.new(InCircle.x, InCircle.y)
    local R = InCircle.r

    local dis = Vector.Distance(Pos, CPos)
    local sina = math.asin(R / dis)

    OutC2d.pos = Pos
    OutC2d.angle = sina * 2
    OutC2d.dir = (CPos - Pos):normalize()
    OutC2d.r = R + dis
end

c2d:SetColor(255,255,0,255)
app.render(function(dt)
    c:draw()
    c2d:draw()
    rect:draw()
end)

app.mousepressed(function(x, y, button, istouch)
    if button == 1 then
        rect.x = x
        rect.y = y
        CacleCone(rect, c, c2d)
    end
end)