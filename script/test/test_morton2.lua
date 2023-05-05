math.randomseed(os.time()%10000)


local Rects = {}
local Colors = {}
local Rect1 = Rect.new(0, 0, 0, 0)
local Rect2 = Rect.new(0, 0, 0, 0)
local Rect3 = Rect.new(0, 0, 0, 0)

local GenerateRects = function()
    Rect1 = Rect.new(0, 0, 100, 100)
   -- local color1 = LColor.new(math.random() * 255, math.random() * 255 , math.random() * 255, 255)
   local color1 = LColor.new(1, 1, 1, 255)
    Rect1:setColor(color1.r, color1.g, color1.b, 255)

    Rect3 = Rect.new(200, 0, 100, 100)
    -- local color3 = LColor.new(math.random() * 255, math.random() * 255 , math.random() * 255, 255)
    local color3 = LColor.new(255, 255 , 255, 255)
    Rect3:setColor(color3.r, color3.g, color3.b, 255)

    local morton1 = color1:GetMortonCodeRGB()
    local morton3 = color3:GetMortonCodeRGB()

    local color2 = LColor.new()
    color2:GetReverseMortonCodeRGB((morton1 + morton3) * 0.5)

    Rect2 = Rect.new(100, 0, 100, 100)
    Rect2:setColor(color2.r, color2.g, color2.b, 255)
    log(color2.r, color2.g, color2.b)
end

app.render(function(dt)
    Rect1:draw()

    Rect2:draw()

    Rect3:draw()
end)

GenerateRects()
app.keypressed(function(key, scancode, isrepeat)
    if key == "space" then
        GenerateRects()
    elseif key == "a" then
    elseif key == "s" then
    end
end)