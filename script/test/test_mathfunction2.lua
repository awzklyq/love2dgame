local Points = {}
local Lines = {}
local GetFunctionValue = function(x)
    local num = 50
    local result = 0
    local ll = 1
    local lll = 1
    for i = 1, num do
        result = result + lll * math.sin(ll * x) /(math.pi * ll)
        ll = ll + 1
        lll = -1 * lll
    end
    return -result
end

local Range1 = -math.pi * 2
local Range2 = math.pi * 2
local Offset = math.rad(0.05)

local OffsetX = 400
local OffsetY = 200
local ScaleX = 50
local ScaleY = 100

local Linex = Line.new(0, OffsetY, 1000, OffsetY)
Linex:setColor(255, 255, 0, 255)
local Liney = Line.new(OffsetX, 0, OffsetX, 1000)
Liney:setColor(255, 255, 0, 255)
local GeneratePointsAndLines = function()
    Points = {}
    Lines = {}
    for i = Range1, Range2, Offset do
        local p = Vector.new(i * ScaleX + OffsetX, GetFunctionValue(i) * ScaleY + OffsetY)
        Points[#Points + 1] = p
    end

    for i = 1, #Points - 1 do
        local line = Line.new(Points[i].x, Points[i].y, Points[i + 1].x, Points[i].y)
        Lines[#Lines + 1] = line
    end
end

GeneratePointsAndLines()

app.render(function(dt)
    Linex:draw()
    Liney:draw()
    for i = 1, #Lines do
        Lines[i]:draw()
    end
end)