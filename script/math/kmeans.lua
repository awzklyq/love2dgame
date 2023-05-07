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
    local NewV3DatasVariance = {}

    local GroupData = {}
    local GroupDataVariance = {}
    for i = 1, GroupNumber do
        GroupData[i] = {}
        GroupData[i][1] = V3Datas[SelectIndexs[i]]

        GroupDataVariance[i] = {}
        GroupDataVariance[i][1] = V3Datas[SelectIndexs[i]]
    end

    for i = 1, #V3Datas do
        if not CheckValueInArray(SelectIndexs, i) then
            NewV3Datas[#NewV3Datas + 1] = V3Datas[i]
            NewV3DatasVariance[#NewV3DatasVariance + 1] = V3Datas[i]
        end
    end

    for i = 1, #NewV3Datas do
        KMeans.FindNearestVector(GroupData, GroupNumber, NewV3Datas[i])
        KMeans.FindNearestVectorByVariance(GroupDataVariance, GroupNumber, NewV3Datas[i])
    end

    return GroupData, GroupDataVariance
end

KMeans.FindNearestVector = function(GroupData, GroupNumber, data)
    local Centroids = {}
    for i = 1, GroupNumber do
        Centroids[i] = CalculateCentroid(GroupData[i])
    end

    local NeedIndex = CalculateShortDistance(Centroids, data)

    GroupData[NeedIndex][#GroupData[NeedIndex] + 1] = data
end

KMeans.FindNearestVectorByVariance = function(GroupData, GroupNumber, data)
    local vari = math.maxFloat
    local NeedIndex = -1
    for i = 1, GroupNumber do
        local Variance = KMeans.CalculateVariance(GroupData[i], data)
        if vari > Variance then
            vari = Variance
            NeedIndex = i
        end
    end

    GroupData[NeedIndex][#GroupData[NeedIndex] + 1] = data
end

KMeans.CalculateVariance = function(GroupData, data)
    local NewDatas = {}
    for i = 1, #GroupData do
        NewDatas[#NewDatas + 1] = GroupData[i]
    end

    NewDatas[#NewDatas + 1] = data

    local vx = 0
    local vy = 0
    for i = 1, #NewDatas do
        vx = vx + NewDatas[i].x
        vy = vy + NewDatas[i].y
    end 

    vx = vx / #NewDatas
    vy = vy / #NewDatas

    local Variance = 0
    for i = 1, #NewDatas do
        Variance = math.pow(NewDatas[i].x - vx, 2) + math.pow(NewDatas[i].y - vy, 2)
    end 

    Variance = Variance / #NewDatas

    return Variance
end