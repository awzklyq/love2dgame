math.randomseed(os.time()%10000)


local Rects = {}
local Colors = {}
local NumRectsX = 20
local NumRectsY = 20
local RectSize = 40

local GenerateRects = function()
    Rects = {}
    for y = 0, NumRectsY do
        for x = 0, NumRectsX do
            local rect = Rect.new(x * RectSize, y * RectSize, RectSize, RectSize)
            local color = LColor.new(math.random() * 255, math.random() * 255 , math.random() * 255, 255)
            Colors[#Colors +1] = color
            rect:setColor(Colors[#Colors].r, Colors[#Colors].g, Colors[#Colors].b, 255)
            Rects[#Rects + 1] = rect
        end
    end

end

local SortRects = function()
    table.sort(Colors, function(a, b)
        return a:GetMortonCodeRGB() > b:GetMortonCodeRGB()
    end)
    
    Rects = {}
    local index = 1
    for y = 0, NumRectsY do
        for x = 0, NumRectsX do
            local rect = Rect.new(x * RectSize, y * RectSize, RectSize, RectSize)
            rect:setColor(Colors[index].r, Colors[index].g, Colors[index].b, 255)
            Rects[#Rects + 1] = rect
            index = index + 1
        end
    end
end

local SortRects2 = function()
    table.sort(Colors, function(a, b)
        return a:GetLuminance() > b:GetLuminance()
    end)
    
    Rects = {}
    local index = 1
    for y = 0, NumRectsY do
        for x = 0, NumRectsX do
            local rect = Rect.new(x * RectSize, y * RectSize, RectSize, RectSize)
            rect:setColor(Colors[index].r, Colors[index].g, Colors[index].b, 255)
            Rects[#Rects + 1] = rect
            index = index + 1
        end
    end
end

app.render(function(dt)
    for i = 1, #Rects do
        Rects[i]:draw()
    end
end)

GenerateRects()
app.keypressed(function(key, scancode, isrepeat)
    if key == "space" then
        GenerateRects()
    elseif key == "a" then
        SortRects()
    elseif key == "s" then
        SortRects2()
    end
end)