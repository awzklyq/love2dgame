
local Rect1s = {}
local Rect2s = {}
local gamma = 2.2;

for i = 0, 10 do
    local offset = 50
    local v = i * 0.1
    local c1 = v * 255

    local c2 = math.pow(v, 1.0 / gamma) * 255

    local rect1 = Rect.new(i * offset, 0, offset, offset)
    rect1:setColor(c1, c1, c1, 255)
    Rect1s[i + 1] = rect1

    local rect2 = Rect.new(i * offset, offset, offset, offset)
    rect2:setColor(c2, c2, c2, 255)
    Rect2s[i + 1] = rect2

end

app.render(function(dt)
    
    for i = 0, 10 do
        Rect1s[i + 1]:draw()
        Rect2s[i + 1]:draw()
    end

end)