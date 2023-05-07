math.randomseed(os.time()%10000)

local SX = 400
local SY = 400
local Num = 400
local SelectNum = 4

local OffsetX = 200
local OffsetY = 100

local RectsGroup
local RectsGroupV 

local IsRenderv = false

local GenerateData = function()
    local vs = {}
    for i = 1, Num do
        vs[#vs + 1] = Vector3.new(math.random(1, SX), math.random(1, SY, 0))
    end

    local Colors = {}
    for i = 1, SelectNum do
        local color = LColor.new(math.random(0, 255), math.random(0, 255), math.random(0, 255), 255)
        Colors[#Colors +1] = color
    end

    local GroupData, GroupDataV = KMeans.Process(vs, SelectNum)

    RectsGroup = {}
    for i = 1, SelectNum do
        RectsGroup[i] = {}
        for j = 1, #GroupData[i] do
            local _rect = Rect.new(GroupData[i][j].x + OffsetX, GroupData[i][j].y + OffsetY, 5, 5)
            _rect:setColor(Colors[i].r, Colors[i].g, Colors[i].b, Colors[i].a)
            RectsGroup[i][#RectsGroup[i] + 1] = _rect
        end
    end

    RectsGroupV = {}
    for i = 1, SelectNum do
        RectsGroupV[i] = {}
        for j = 1, #GroupDataV[i] do
            local _rect = Rect.new(GroupDataV[i][j].x + OffsetX, GroupDataV[i][j].y + OffsetY, 5, 5)
            _rect:setColor(Colors[i].r, Colors[i].g, Colors[i].b, Colors[i].a)
            RectsGroupV[i][#RectsGroupV[i] + 1] = _rect
        end
    end
end

GenerateData{}
app.render(function(dt)
    for i = 1, SelectNum do
        if IsRenderv then
            for j = 1, #RectsGroupV[i] do
                RectsGroupV[i][j]:draw()
            end
        else
            for j = 1, #RectsGroup[i] do
                RectsGroup[i][j]:draw()
            end
        end
        
    end
end)

app.keypressed(function(key, scancode, isrepeat)
    if key == "space" then
        GenerateData()
    elseif key == "a" then
        IsRenderv = not IsRenderv
        log('IsRenderv', IsRenderv)
    end
end)