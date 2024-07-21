
local GenerateRects = function(Rects, x, y, w, h, Str)
    local SizeX = w * 0.5
    local SizeY = h * 0.5
    Rects[#Rects + 1] = Rect.new(x, y, SizeX, SizeY, 'line')
    Rects[#Rects].PickName = Str .. "00"

    local StartIndex = #Rects

    Rects[#Rects + 1] = Rect.new(x + SizeX, y, SizeX, SizeY, 'line')
    Rects[#Rects].PickName = Str .. "01"

    Rects[#Rects + 1] = Rect.new(x, y + SizeY, SizeX, SizeY, 'line')
    Rects[#Rects].PickName = Str .. "10"

    Rects[#Rects + 1] = Rect.new(x + SizeX, y + SizeY, SizeX, SizeY, 'line')
    Rects[#Rects].PickName = Str .. "11"

    local EndIndex = #Rects

    for i = StartIndex, EndIndex do
        Rects[i].Center = Vector.new(Rects[i].x +  Rects[i].w * 0.5, Rects[i].y +  Rects[i].h * 0.5)
        Rects[i]:SetMouseEventEable(true)

        Rects[i].MouseDownEvent = function(rect, x, y)
            log('bbbbbbb', rect.PickName)
        end
    end
end

local Rects = {}
local w = RenderSet.screenwidth * 0.5
local h = RenderSet.screenheight * 0.5
GenerateRects(Rects, 0, 0, w, h, "00")
GenerateRects(Rects, w, 0, w, h, "01")
GenerateRects(Rects, 0, h, w, h, "10")
GenerateRects(Rects, w, h, w, h, "11")

app.render(function(dt)
    for i = 1, #Rects do
        Rects[i]:draw()
    end
end)
app.mousepressed(function(x, y, button, istouch)
    local Pos = Vector.new(x, y)
    -- log('aaa', Pos.x, Pos.y, RenderSet.screenwidth, RenderSet.screenheight)
    Pos.x = Pos.x / RenderSet.screenwidth
    Pos.y = Pos.y / RenderSet.screenheight

    Pos= Pos * math.pow(2, 16)
    logbit(Pos:GetMortonCode2(), 32)
end)