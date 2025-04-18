local c2d = Cone2D.new(Vector.new(0,0), Vector.new(1,-1):normalize(), 100, 45)


local c = Circle.new(100, 300 ,300)
local rect = Rect.new(200, 200, 8, 8, 'fill')
rect:SetColor(255, 0, 0, 255)

local rect1 = Rect.new(200, 200, 4, 4, 'fill')
rect1:SetColor(0, 0, 255, 255)

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

    rect1:draw()
end)

app.mousepressed(function(x, y, button, istouch)
    if button == 1 then
        rect:SetCenterPosition(x, y)
        -- CacleCone(rect, c, c2d)
        c2d = math.GetTangentCone2D(Vector.new(x, y), c)
        c2d:SetColor(255,255,0,255)
    elseif button == 2 then
        rect1:SetCenterPosition(x, y)
        if c2d:CheckPointInXY(x, y) then
            log('In Cone2D!')
        end
    end
end)