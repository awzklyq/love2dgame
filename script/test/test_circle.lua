local circle = Circle.new(100,300,300)
local num = 5
local angle = 45
local PS = {} -- circle:GetDirectionPoints(Vector.new(1,1), 25, 5)
local Rects = {}

local GenerateData = function(dir)
    PS = circle:GetDirectionPoints(dir, angle, num)

    Rects = {}

    for i = 1, #PS do
        local rect = Rect.new(PS[i].x - 4, PS[i].y - 4, 8, 8)
        rect:SetColor(255,0,0)
        Rects[#Rects + 1] = rect
    end

end

local SelectRect = Rect.new(100, 100, 10, 10)
SelectRect:SetColor(0,0,255, 255)
SelectRect:SetMouseEventEable(true)

SelectRect.MouseMoveEvent = function(rect, x, y)
    rect.x = x - rect.w * 0.5
    rect.y = y - rect.h * 0.5
    GenerateData(Vector.new(rect.x - circle.x, rect.y - circle.y))
end


GenerateData(Vector.new(-1,1))
app.render(function(dt)
    circle:draw()

    for i = 1, #Rects do
        Rects[i]:draw()
    end

    SelectRect:draw()

end)

app.resizeWindow(function(w, h)
    GenerateData()
end)