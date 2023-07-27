local OffsetX = 764
local OffsetY = 256
local VS = {}
VS[#VS + 1] = Vector.new(764 - OffsetX, 633 - OffsetY)
VS[#VS + 1] = Vector.new(1049 - OffsetX, 861 - OffsetY)
VS[#VS + 1] = Vector.new(1318 - OffsetX, 620 - OffsetY)
VS[#VS + 1] = Vector.new(1541 - OffsetX, 763 - OffsetY)
-- VS[#VS + 1] = Vector.new(1755 - OffsetX, 464 - OffsetY)
VS[#VS + 1] = Vector.new(1504 - OffsetX, 491 - OffsetY)
VS[#VS + 1] = Vector.new(1390 - OffsetX, 256 - OffsetY)
VS[#VS + 1] = Vector.new(1165 - OffsetX, 661 - OffsetY)
VS[#VS + 1] = Vector.new(897 - OffsetX, 587 - OffsetY)
VS[#VS + 1] = Vector.new(914 - OffsetX, 331 - OffsetY)

local Lines = {}
local EdgeOris = {}
for i = 1, #VS - 1 do
    VS[i].Order = i
    EdgeOris[#EdgeOris + 1] = Edge2D.new(VS[i], VS[i + 1])
    Lines[#Lines + 1] = Line.new(VS[i].x, VS[i].y, VS[i + 1].x, VS[i + 1].y)
end

VS[#VS].Order = #VS
VS[#VS].IsEnd = true
VS[1].IsStart = true
EdgeOris[#EdgeOris + 1] = Edge2D.new(VS[#VS], VS[1])
Lines[#Lines + 1] = Line.new(VS[#VS].x, VS[#VS].y, VS[1].x, VS[1].y)

local tri = Triangle2D.new(VS[8], VS[9], VS[2], false)
tri:SetColor(255, 0, 0, 255)

local Tris = EarClip.Process(VS)
--log('ssssssss', #Tris)
local RenderEdge = true
app.render(function(dt)
    if RenderEdge then
        for i = 1, #Lines do
            Lines[i]:draw()
        end
    else
        for i = 1, #Tris do
            Tris[i]:draw()
        end
    end

    -- tri:draw()
end)


app.mousepressed(function(x, y, button, istouch)
    if tri:CheckPointIn(Vector.new(x, y)) then
        log('AAAAA Is In')
    else
        log('BBBBB Is Mot In')
    end
end)

app.keypressed(function(key, scancode, isrepeat)
    if key == "space" then
        RenderEdge = not RenderEdge
    end
end)



