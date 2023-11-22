math.randomseed(os.time()%10000)

local SX = 400
local SY = 400
local Num = 400
local SelectNum = 4

local OffsetX = 200
local OffsetY = 100

local RectsGroup
local RectsGroupV 
local RectsGroupM 

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

    RectsGroupM = {}
    local v3 = {}
    local m3 = {}
    for i = 1, Num do
        v3[i] = Vector3.new(vs[i].x, vs[i].y, 0)
        m3[i] = v3[i]:GetMortonCode3()
    end

    table.sort(m3, function(a, b)
        return a < b
    end)

    local ON = Num / SelectNum
    for i = 1, SelectNum do
        RectsGroupM[i] = {}
        for j = 1 + (i - 1) * ON, ON * i  do
            local v = Vector3.GetReverseMortonCodeRGB(m3[j])
            local _rect = Rect.new(v.x + OffsetX, v.y + OffsetY, 5, 5)
            _rect:setColor(Colors[i].r, Colors[i].g, Colors[i].b, Colors[i].a)
            RectsGroupM[i][#RectsGroupM[i] + 1] = _rect
        end
    end
end

GenerateData()


local btn = UI.Button.new( 10, 10, 100, 30, 'GenerateData', 'btn' )
btn:setPressedColor(LColor.new(125, 125, 125))

btn.ClickEvent = function()
    GenerateData()
end

local checkb = UI.CheckBox.new( 10, 40, 20, 20, "IsRenderv" )

checkb.Value = IsRenderv
checkb.ChangeEvent = function(Enable)
    IsRenderv = Enable
end

app.render(function(dt)
    for i = 1, SelectNum do
        if IsRenderv then
            for j = 1, #RectsGroupM[i] do
                RectsGroupM[i][j]:draw()
            end
        else
            for j = 1, #RectsGroup[i] do
                RectsGroup[i][j]:draw()
            end
        end
        
    end
end)