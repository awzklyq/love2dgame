_G.AStartPathFinder = {}
AStartPathFinder.Meta = {__index = AStartPathFinder}

function AStartPathFinder.new(InX, InY, InW, InH, InGridX, InGridY)
    local f = setmetatable({}, AStartPathFinder.Meta)

    f._x = InX
    f._y = InY
    f._w = InW
    f._h = InH


    f._GridX = InGridX
    f._GridY = InGridY

    f._PathGrids = PathFinderHelper.CreateGirds(InX, InY, InW, InH, InGridX, InGridY)
    return f
end 

function CheckInGrids(InGrid, InGrids)
    for i = 1, #InGrids do
        if InGrid == InGrids then
            return true
        end
    end

    return false
end

function AStartPathFinder:GetNeighbor(InGrid)
    local i = InGrid._i
    local j = InGrid._j

    local NewGrids = {}
    for i = -1, 1 do
        for j = -1, 1 do
            local NewI = math.clamp_min_max(i, 1, self._GridX)
            local NewJ = math.clamp_min_max(i, 1, self._GridY)

            local NewGrid = self._PathGrids[NewI][NewJ]
            if NewGrid ~= InGrid and not CheckInGrids(NewGrid, NewGrids) then
                NewGrids[#NewGrids + 1] = NewGrid
            end
        end
    end

    return NewGrids
end

function AStartPathFinder:draw()
    for i, v in ipairs(self._PathGrids) do
        for j, p in ipairs(v) do
            p:draw()
        end
    end
end