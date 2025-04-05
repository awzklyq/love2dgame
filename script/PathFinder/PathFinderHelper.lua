_G.PathFinderHelper = {}

function PathFinderHelper.CreateGirds(InX, InY, InW, InH, InGridX, InGridY)
    local SizeX = InW / InGridX
    local SizeY = InH / InGridY

    local NewGrids = {}
    for i = 1, InGridX do

        NewGrids[i] = {}
        local StartX = InX + (i - 1) * SizeX
        for j = 1, InGridY do
            local StartY = InY + (j - 1) * SizeY
            local g = PathGridData.new(i, j, StartX, StartY, SizeX, SizeY)
            NewGrids[i][j] = g
        end
    end

    return NewGrids
end

function PathFinderHelper.CaclePathGridCost(InGrid1, InGrid2)
    return math.abs(InGrid1._i - InGrid2._i) + math.abs(InGrid1._j - InGrid2._j)
end