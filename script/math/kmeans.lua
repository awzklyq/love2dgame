_G.KMeans = {}

local CheckValueInArray = function(SelectIndexs, v)
    for i = 1, #SelectIndexs do
        if SelectIndexs[i] == v then
            return true
        end
    end
    return false
end

local CalculateCentroid = function(GroupData)
    local V = Vector3.new()
    for i = 1, #GroupData do
        V = V + GroupData[i]
    end

    V = V / #GroupData
    return V
end

local CalculateShortDistance = function(CentroidGroupData, v)
    local index = -1
    local dis = math.maxFloat
    for i = 1, #CentroidGroupData do
        local d = Vector3.distance(CentroidGroupData[i], v)
        if d < dis then
            dis = d
            index = i
        end
    end

    return index
end

KMeans.Process = function(V3Datas, GroupNumber)
    --random
    local SelectIndexs = {}

    for i = 1, GroupNumber do
        local r = math.random(1, #V3Datas)
        r = r - r % 1
        while CheckValueInArray(SelectIndexs, r) do
            r = r + 1
            if r == #V3Datas then
                r = 1
            end
        end

        SelectIndexs[i] = r
    end

    local NewV3Datas = {}
    local GroupData = {}
    for i = 1, GroupNumber do
        GroupData[i] = {}
        GroupData[i][1] = V3Datas[SelectIndexs[i]]
    end

    for i = 1, #V3Datas do
        if not CheckValueInArray(SelectIndexs, i) then
            NewV3Datas[#NewV3Datas + 1] = V3Datas[i]
        end
    end

    for i = 1, #NewV3Datas do
        KMeans.FindNearestVector(GroupData, GroupNumber, NewV3Datas[i])
    end

    return GroupData
end

KMeans.FindNearestVector = function(GroupData, GroupNumber, data)
    local Centroids = {}
    for i = 1, GroupNumber do
        Centroids[i] = CalculateCentroid(GroupData[i])
    end

    local NeedIndex = CalculateShortDistance(Centroids, data)

    GroupData[NeedIndex][#GroupData[NeedIndex] + 1] = data
end