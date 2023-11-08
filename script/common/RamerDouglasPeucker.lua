_G.RamerDouglasPeucker = {}
RamerDouglasPeucker.ThresholdDistance = 10
RamerDouglasPeucker.FindRedundanceData = function(Points, StartPointIndex, EndPointIndex, NeedDeleteTab)
    if StartPointIndex + 1 >= EndPointIndex then
        return false
    end

    local StartPoint = Points[StartPointIndex]
    local EndPoint = Points[EndPointIndex]

    local SelectIndex = -1
    local MaxDistance = -1
    for i = StartPointIndex + 1, EndPointIndex - 1 do
        local p = Points[i]
        local dis = math.PointToLineDistanceXY2D(p, StartPoint.x, StartPoint.y, EndPoint.x, EndPoint.y)

        if dis > RamerDouglasPeucker.ThresholdDistance then
            if MaxDistance == -1 then
                SelectIndex = i
                MaxDistance = dis
            elseif dis > MaxDistance then
                SelectIndex = i
                MaxDistance = dis
            end
        end
    end

    if SelectIndex == -1 then
        for i = StartPointIndex + 1, EndPointIndex - 1 do
            if NeedDeleteTab[i] ~= nil then
                errorAssert(false, "NeedDeleteTab is not nil")
            end

            NeedDeleteTab[i] = i
        end
        return false
    end

    RamerDouglasPeucker.FindRedundanceData(Points, StartPointIndex, SelectIndex, NeedDeleteTab)
    RamerDouglasPeucker.FindRedundanceData(Points, SelectIndex + 1, EndPointIndex, NeedDeleteTab)
end

RamerDouglasPeucker.Process2D = function(Points)
    if #Points < 3 then
        return Points
    end

    local NewPoints = {}
    local NeedDeleteTab = {}
    RamerDouglasPeucker.FindRedundanceData(Points, 1, #Points, NeedDeleteTab)
    for i = 1, #Points do
        if NeedDeleteTab[i] == nil then
            NewPoints[#NewPoints + 1] = Vector.copy(Points[i])
        end
    end

    return NewPoints
end