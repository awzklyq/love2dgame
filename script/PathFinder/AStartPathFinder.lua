_G.AStartPathFinder = {}
AStartPathFinder.Meta = {__index = AStartPathFinder}

function AStartPathFinder.new(InX, InY, InW, InH, InGridX, InGridY)
    local f = setmetatable({}, AStartPathFinder.Meta)

    f._x = InX
    f._y = InY
    f._w = InW
    f._h = InH

    f._rect = Rect.new(InX, InY, InW, InH)


    f._GridX = InGridX
    f._GridY = InGridY

    f._GridSizeX = InW / InGridX
    f._GridSizeY = InH / InGridY

    f._PathGrids = PathFinderHelper.CreateGirds(InX, InY, InW, InH, InGridX, InGridY)

    f:ResetResult()

    return f
end 

function AStartPathFinder:ResetResult()
    self._ClosePaths = {}
    self._OpenPathsHelper = {}
    self._OpenPaths = {}
end

function AStartPathFinder:GetGridFromXY(InX, InY)
    if not self._rect:CheckPointInXY(InX, InY) then
        return nil
    end

    local StartX = math.ceil((InX - self._x) / self._GridSizeX)
    local StartY = math.ceil((InY - self._y) / self._GridSizeY)

    local NewI = math.clamp_min_max(StartX, 1, self._GridX)
    local NewJ = math.clamp_min_max(StartY, 1, self._GridY)

    return self._PathGrids[NewI][NewJ]
end

function AStartPathFinder:AddGridOpen(InGrid, InStartGrid, InTargeGrid, InParent)
    -- local CurCost = PathFinderHelper.CaclePathGridCost(InGrid, InTargeGrid)
    -- local NewCost = InParent and InParent.Cost + CurCost or CurCost
    local NewCost = PathFinderHelper.CaclePathGridCost(InStartGrid, InGrid) + PathFinderHelper.CaclePathGridCost(InTargeGrid, InGrid)
    self._OpenPaths[#self._OpenPaths + 1] =  {Grid = InGrid, Cost = NewCost, Parent = InParent}

    self._OpenPathsHelper[InGrid] = true
end

function AStartPathFinder:AddGridClosed(InGrid)
    self._ClosePaths[InGrid] = true
end

function AStartPathFinder:SortOpenList()
    table.sort(self._OpenPaths, function(a, b)
        return a.Cost > b.Cost
    end)
end

function AStartPathFinder:GetPathsFromOpenList()
    local LastObj = self._OpenPaths[#self._OpenPaths]

    local PathGrids = {}
    PathGrids[1] = LastObj.Grid

    while LastObj.Parent do
        LastObj = LastObj.Parent
        PathGrids[#PathGrids + 1] = LastObj.Grid
    end

    return PathGrids
end

function AStartPathFinder:FindPath(InStartGrid, InTargeGrid)
    self:ResetResult()

    self:AddGridOpen(InStartGrid, InStartGrid, InTargeGrid, nil)

    local _Result = self:CacleNeighborPaths(InStartGrid, InTargeGrid)
    local IsHasPaths = #self._OpenPaths
    while not _Result and IsHasPaths do
        _Result = self:CacleNeighborPaths(InStartGrid, InTargeGrid)
        IsHasPaths = #self._OpenPaths
    end

    if IsHasPaths and _Result then
        return self:GetPathsFromOpenList()
    else
        return nil
    end

end

function AStartPathFinder:CheckInCloseList(InGrid)
    return self._ClosePaths[InGrid]
end

function AStartPathFinder:CheckInOpenList(InGrid)
    return self._OpenPathsHelper[InGrid]
end

function AStartPathFinder:RemoveFormOpenList(InGrid, InIndex)
    table.remove(self._OpenPaths, InIndex)

    self._OpenPathsHelper[InGrid] = nil
end

function AStartPathFinder:CacleNeighborPaths(InStartGrid, InTargeGrid)
    local LastNumber = #self._OpenPaths
    if LastNumber == 0 then
        return false
    end

    local PathObj = self._OpenPaths[LastNumber]
    local TopGrid = PathObj.Grid

    local NeighborGrids =  self:GetNeighbor(TopGrid)
    if #NeighborGrids == 0 then
        self:RemoveFormOpenList(PathObj, LastNumber)
        self:AddGridClosed(TopGrid)

        self:SortOpenList()
    else
        for i, v in ipairs(NeighborGrids) do
            self:AddGridOpen(v, InStartGrid, InTargeGrid, PathObj)
            if InTargeGrid == v then
                return true
            end
        end
    
        self:SortOpenList()
    end
    return false
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
    local InI = InGrid._i
    local InJ = InGrid._j

    local NewGrids = {}
    for i = -1, 1 do
        for j = -1, 1 do
            local NewI = math.clamp_min_max(InI + i, 1, self._GridX)
            local NewJ = math.clamp_min_max(InJ + j, 1, self._GridY)

            local NewGrid = self._PathGrids[NewI][NewJ]
            if NewGrid:CanReach() and not self:CheckInOpenList(NewGrid) and not self:CheckInCloseList(NewGrid) and NewGrid ~= InGrid and not CheckInGrids(NewGrid, NewGrids)  then
                NewGrids[#NewGrids + 1] = NewGrid
            end
        end
    end

    return NewGrids
end

function AStartPathFinder:ForeachGrids(InFunc)
    for i, v in ipairs(self._PathGrids) do
        for j, p in ipairs(v) do
            InFunc(p)
        end
    end
end

function AStartPathFinder:SetOpenAndClosedColor(InColor)
    for i, v in pairs(self._ClosePaths) do
        if v then
            i:SetColor(InColor)
        end
    end

    for i, v in pairs(self._OpenPathsHelper) do
        if v then
            i:SetColor(InColor)
        end
    end
end

function AStartPathFinder:GetCenter()
    local Center = Vector.new(self._x + self._w * 0.5, self._y + self._h * 0.5)

    return Center
end

function AStartPathFinder:GenerateBlockByCircle(InCircle)
    self:ForeachGrids(function(InGrid)
        if InCircle:CheckPointIn(InGrid:GetCenter()) then
            InGrid:SetCanReach(false)
        end
    end)
end

function AStartPathFinder:draw()
    for i, v in ipairs(self._PathGrids) do
        for j, p in ipairs(v) do
            p:draw()
        end
    end
end