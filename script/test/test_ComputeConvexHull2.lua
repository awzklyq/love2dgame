math.randomseed(os.time()%10000)

local NumberRects = 1000
local Shrink = 80
local rsize = 8 * 0.5
local Rects = {}
local Points = {}
local Lines = {}
local GenerateRects = function()
    Rects = {}
    Points = {}
    local w = RenderSet.screenwidth
    local h = RenderSet.screenheight

    local sx = Shrink
    local sy = Shrink

    local sizex = w - sx * 2
    local sizey = h - sy * 2
    for i = 1, NumberRects do
        local x = sx + math.random(0, sizex)
        local y = sy +  math.random(0, sizey)

        Points[#Points + 1] = Vector.new(x, y)
        
        local r = Rect.new(x - rsize, y - rsize, rsize, rsize)
        r:SetColor(255,255,0,255)
        Rects[#Rects + 1] = r
    end
end

local GenerateLines = function()
    Lines = {}
    if #Points <= 2 then
        return
    end

    local OutIndices = {}
    math.ComputeConvexHull2(Points, OutIndices)

    if #OutIndices <= 1 then
        return
    end
    
    for i = 1, #OutIndices do
        local i1 = i
        local i2 = i + 1
        if i2 > #OutIndices then
            i2 = 1
        end

        local l = Line.new(Points[OutIndices[i1]].x, Points[OutIndices[i1]].y, Points[OutIndices[i2]].x, Points[OutIndices[i2]].y)
        l:SetColor(255, 0, 255, 255)
        Lines[#Lines + 1] = l
    end
end

app.render(function(dt)
    for i = 1, #Lines do
        Lines[i]:draw()
    end

    for i = 1, #Rects do
        Rects[i]:draw()
    end
end)

local btn = UI.Button.new( 10, 10, 100, 50, 'Reset', 'btn' )
btn:setPressedColor(LColor.new(125, 125, 125))
btn.ClickEvent = function()
    GenerateRects()
    GenerateLines()
end

local scrollbar = UI.ScrollBar.new( 'test', 10, 80, 200, 40, 10, 1000, 5)
scrollbar.Value = NumberRects
scrollbar.ChangeEvent = function(v)
    NumberRects = v
end
