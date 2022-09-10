local Num = 1000
local Scale = 10
local OffsetY = 100
local XT = {}
local YT = {}
for i = 1, Num do
    XT[#XT + 1] = i * Scale
    YT[#YT + 1] = PerLinNoise1.GetValue(i * 0.1) + OffsetY
end

local LinesDatas = {}
for i = 1, Num - 1 do
    LinesDatas[#LinesDatas + 1] = Line.new(XT[i], YT[i], XT[i + 1], YT[i + 1])
    -- log(XT[i], YT[i], XT[i + 1], YT[i + 1])
end



app.render(function(dt)
    for i = 1, Num - 1 do
        LinesDatas[i]:draw()
    end
end)