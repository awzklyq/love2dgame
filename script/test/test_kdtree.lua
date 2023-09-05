local Num = 10
local Results = {}

local CheckData
CheckData = function(Data, Value)
    if Data.Value == Value then
        log('rrr', Data.Value, Data.Index)
    end

    if Data.Left then
        CheckData(Data.Left, Value)
    end 

    if Data.Right then
        CheckData(Data.Right, Value)
    end 
end

local FindMed = function(Tabs, i, j)
    local index = i
    if (i + j) % 2 == 0 then
        index = (i + j) / 2
    else
        index = math.clamp((i + j - 1) / 2, i, j)
    end 
    return Tabs[index], index
end

local DealKdTreeData
DealKdTreeData = function(Data, Tabs, start, endx)
    local MedData, Index = FindMed(Tabs, start, endx)
    Data.Value = MedData
    Data.Index = Index
    if start < Index - 1 then
        Data.Left = {}
        DealKdTreeData(Data.Left, Tabs, start, Index - 1)
    else
        Data.Left = {}
        Data.Left.Value = Tabs[start]
        Data.Left.Index = start
    end

    if Index < endx - 1 then
        Data.Right = {}
        DealKdTreeData(Data.Right, Tabs, Index + 1, endx)
    else
        Data.Right = {}
        Data.Right.Value = Tabs[endx]
        Data.Right.Index = endx
    end
end

local OF = {V = 10}
local LogInfo

local LogData = function(Data, Offset, OF)
    LogInfo(Data.Left, Offset - OF.V, Data.Right, Offset + OF.V, OF)
end


LogInfo = function(DataLeft, OffsetLeft, DataRight, OffsetRight, OF)
    local str = ""
    if DataLeft then
        for i = 1, OffsetLeft do
            str = str .. "  "
        end
        str = str .. tostring(DataLeft.Value)
    end

    if DataRight then
        str = str .. "  "
        for i = OffsetLeft, OffsetRight do
            str = str .. "  "
        end

        str = str .. tostring(DataRight.Value)
    end

    log(str)

    OF.V = math.clamp(OF.V - 1, 1, 50)
    if DataLeft then
        LogData(DataLeft, OffsetLeft, OF)
    end

    if DataRight then
        LogData(DataRight, OffsetRight, OF)
    end
end

local ResetNum = function()
    local Tabs = {}
    for i = 1, Num do
        Tabs[#Tabs +1] = math.random(1 , 10000) 
    end

    table.sort(Tabs, function(a, b)
        return a < b
    end)

    local str = ""
    for i = 1, Num do
        str = str .. tostring(Tabs[i]) .. " "
    end

    log(str)
    Results = {}
    DealKdTreeData(Results, Tabs, 1, Num)

    LogInfo(Results, 15, nil, nil, OF)

    CheckData(Results.Right, 5686)
end

ResetNum()

app.render(function(dt)
 
end)

app.keypressed(function(key, scancode, isrepeat)
    if key == "space" then
  
    end
end)