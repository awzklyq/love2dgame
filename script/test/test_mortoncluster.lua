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
local DebugLindes = {}

local GenerateMortonData
GenerateMortonData = function(vs, MNum, Colors)
    if MNum <= 1 then
        local index = #RectsGroupM + 1
        RectsGroupM[index] = {}
        for i = 1, #vs  do
            local v = vs[i]
            local _rect = Rect.new(v.x + OffsetX, v.y + OffsetY, 5, 5)
            if i == 1 then
                _rect:setColor(255, 0, 0, Colors[index].a)
            else
                _rect:setColor(Colors[index].r, Colors[index].g, Colors[index].b, Colors[index].a)
            end
            
            RectsGroupM[index][#RectsGroupM[index] + 1] = _rect
        end
        return
    end
    local RectsGroupM1 = {}
    local RectsGroupM2 = {}
    local v3 = {}
    local m3 = {}
    for i = 1, #vs do
        v3[i] = Vector3.new(vs[i].x, vs[i].y, 0)
        m3[i] = v3[i]:GetMortonCode3()
    end

    table.sort(m3, function(a, b)
        return a < b
    end)

    local index = 1
    local maxdis = 0
    for i = 1, #vs - 1 do
        local v1 = Vector3.GetReverseMortonCode(m3[i])
        local v2 = Vector3.GetReverseMortonCode(m3[i + 1])
        local dis = Vector3.distance(v1, v2)
        if maxdis < dis then
            maxdis = dis
            index = i
        end
    end

    _errorAssert(maxdis > 0, "maxdis == 0 #vs is :" .. tostring(#vs))

    RectsGroupM1[1] = Vector3.GetReverseMortonCode(m3[index])
    RectsGroupM2[1] = Vector3.GetReverseMortonCode(m3[index + 1])
    
    for i = 1, #m3 do
        if i ~= index and  i ~= index + 1 then
            local v = Vector3.GetReverseMortonCode(m3[i])
            local d1 = Vector3.distance(v, RectsGroupM1[1])
            local d2 = Vector3.distance(v, RectsGroupM2[1])
           
            if d1 >= d2 then
                RectsGroupM2[#RectsGroupM2 + 1] = v
            else
                RectsGroupM1[#RectsGroupM1 + 1] = v
            end
        end
    end

    GenerateMortonData(RectsGroupM1, MNum / 2, Colors)
    GenerateMortonData(RectsGroupM2, MNum / 2, Colors)
end

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
    DebugLindes = {}
    local v3 = {}
    local m3 = {}
    for i = 1, #vs do
        v3[i] = Vector3.new(vs[i].x, vs[i].y, 1)
        m3[i] = v3[i]:GetMortonCode3()
    end

    table.sort(m3, function(a, b)
        return a < b
    end)

    for i = 1, #m3 - 1 do
        local v1 = Vector3.GetReverseMortonCode(m3[i])
        local v2 = Vector3.GetReverseMortonCode(m3[i + 1])
        local line = Line.new(v1.x + OffsetX, v1.y + OffsetY, v2.x + OffsetX, v2.y + OffsetY, 1)
        DebugLindes[#DebugLindes + 1] = line
    end

    local MortonClusterDatas  = MortonClusterNode.ProcessVector3(v3, SelectNum)

    for i = 1, #MortonClusterDatas do
        RectsGroupM[i] = {}
        for j = 1, #MortonClusterDatas[i].IndexArray  do
            local _Index = MortonClusterDatas[i].IndexArray[j]
            local v = vs[_Index]
            local _rect = Rect.new(v.x + OffsetX, v.y + OffsetY, 5, 5)
            _rect:setColor(Colors[i].r, Colors[i].g, Colors[i].b, Colors[i].a)
            RectsGroupM[i][#RectsGroupM[i] + 1] = _rect
        end
    end

    -- GenerateMortonData(vs, SelectNum, Colors)
end

GenerateData()


local btn = UI.Button.new( 10, 10, 100, 30, 'GenerateData', 'btn' )
btn:setPressedColor(LColor.new(125, 125, 125))

btn.ClickEvent = function()
    GenerateData()
end

local checkb = UI.CheckBox.new( 10, 40, 20, 20, "IsRenderMorton" )

local IsRenderMorton = false
checkb.Value = IsRenderMorton
checkb.ChangeEvent = function(Enable)
    IsRenderMorton = Enable
end

local checkb2 = UI.CheckBox.new( 10, 70, 20, 20, "IsRenderMortonDebugline" )
local IsRenderMortonDebugline = false
checkb2.Value = IsRenderMortonDebugline
checkb2.ChangeEvent = function(Enable)
    IsRenderMortonDebugline = Enable
end

app.render(function(dt)
    if IsRenderMortonDebugline then
        for i = 1, #DebugLindes do
            DebugLindes[i]:draw()
        end
    end
    
    if IsRenderMorton then
        for i = 1, #RectsGroupM do
            for j = 1, #RectsGroupM[i] do
                RectsGroupM[i][j]:draw()
            end
        end
    else
        for i = 1, #RectsGroup do
            for j = 1, #RectsGroup[i] do
                RectsGroup[i][j]:draw()
            end
            
        end
    end
end)


local scrollbar2 = UI.ScrollBar.new( 'Cluster Number: ', 10, 120, 200, 40, 3, 8, 1)
scrollbar2.Value = SelectNum
scrollbar2.ChangeEvent = function(v)
    SelectNum = v
end