_G.SpaceSplit = {}

SpaceSplit.TypeBySurface = 1
SpaceSplit.TypeByAix = 2
SpaceSplit.TypeByHalf = 2

SpaceSplit.Type = SpaceSplit.TypeByAix
_G.SpaceSplit.SplitBatchBySurface = function(VertsAABB, targetSize, splitGranularity)
    local bestCost = math.maxFloat
    local bestAxis = -1;
    local bestIndex = -1;

    local numv = #VertsAABB
    for splitAxis = 1, 3 do
        table.sort(VertsAABB, function(a, b)
            if splitAxis == 1 then
                return a.center.x < b.center.x
            elseif splitAxis == 2 then
                return a.center.y < b.center.y
            elseif splitAxis == 3 then
                return a.center.z < b.center.z
            else
                assert(false)
                return false
            end
        end)

        local LeftBoxs = {}      
        local LeftBoundBox = BoundBox.new()
        for i = 1, numv, 1 do
            LeftBoundBox = LeftBoundBox + VertsAABB[i]
            LeftBoxs[#LeftBoxs + 1] = LeftBoundBox
        end

        local RightBoxs = {}
        local RightBoundBox = BoundBox.new()
        for i = numv, 1, -1 do
            RightBoundBox = RightBoundBox + VertsAABB[i]
            RightBoxs[i] = RightBoundBox
        end

        for i = splitGranularity, numv - splitGranularity, splitGranularity do
            local countLeft = i
			local countRight = numv - i;

            local areaLeft = LeftBoxs[i]:GetSurfaceArea() * countLeft
            local areaRight = RightBoxs[i + 1]:GetSurfaceArea() * countRight

            local cost = areaLeft + areaRight
            if cost < bestCost then
                bestCost = cost;
                bestAxis = splitAxis;
                bestIndex = i
            end
        end
    end


    
    if bestIndex == -1 then
        bestIndex = numv;
    else
        table.sort(VertsAABB, function(a, b)
            if bestAxis == 1 then
                return a.center.x < b.center.x
            elseif bestAxis == 2 then
                return a.center.y < b.center.y
            elseif bestAxis == 3 then
                return a.center.z < b.center.z
            else
                assert(false)
                return false
            end
        end)
    end
    return bestIndex
end


_G.SpaceSplit.SplitBatchByAix = function(VertsAABB, targetSize, splitGranularity)
    local bestCost = math.maxFloat
    local bestAxis = -1;
    local bestIndex = -1;

    local numv = #VertsAABB

    local aabb = BoundBox.new()
    for i = 1, numv do
        aabb = aabb + VertsAABB[i]
    end

    bestAxis = 1
    local AxiBoxExt = aabb.max - aabb.min
    local TheBestAix = AxiBoxExt.x

    if AxiBoxExt.y > TheBestAix then
        TheBestAix = AxiBoxExt.y
        bestAxis = 2
    end

    if AxiBoxExt.z > TheBestAix then
        TheBestAix = AxiBoxExt.z
        bestAxis = 3
    end 

    table.sort(VertsAABB, function(a, b)
        if bestAxis == 1 then
            return a.center.x < b.center.x
        elseif bestAxis == 2 then
            return a.center.y < b.center.y
        elseif bestAxis == 3 then
            return a.center.z < b.center.z
        else
            assert(false)
            return false
        end
    end)

    local LeftBoxs = {}      
    local LeftBoundBox = BoundBox.new()
    for i = 1, numv, 1 do
        LeftBoundBox = LeftBoundBox + VertsAABB[i]
        LeftBoxs[#LeftBoxs + 1] = LeftBoundBox
    end

    local RightBoxs = {}
    local RightBoundBox = BoundBox.new()
    for i = numv, 1, -1 do
        RightBoundBox = RightBoundBox + VertsAABB[i]
        RightBoxs[i] = RightBoundBox
    end

    for i = splitGranularity, numv - splitGranularity, splitGranularity do
        local countLeft = i
        local countRight = numv - i;

        local areaLeft = LeftBoxs[i]:GetSurfaceArea() * countLeft
        local areaRight = RightBoxs[i + 1]:GetSurfaceArea() * countRight

        local cost = areaLeft + areaRight
        if cost < bestCost then
            bestCost = cost;
            bestIndex = i
        end
    end


    
    if bestIndex == -1 then
        bestIndex = numv;
    end

    return bestIndex
end

_G.SpaceSplit.SplitBatchByAixHalf = function(VertsAABB, targetSize, splitGranularity)
    local numv = #VertsAABB
    if numv < targetSize or umv < splitGranularity then
        return numv
    end

    local bestAxis = -1;
    local bestIndex = -1;

    local aabb = BoundBox.new()
    for i = 1, numv do
        aabb = aabb + VertsAABB[i]
    end

    bestAxis = 1
    local AxiBoxExt = aabb.max - aabb.min
    local TheBestAix = AxiBoxExt.x

    if AxiBoxExt.y > TheBestAix then
        TheBestAix = AxiBoxExt.y
        bestAxis = 2
    end

    if AxiBoxExt.z > TheBestAix then
        TheBestAix = AxiBoxExt.z
        bestAxis = 3
    end 

    table.sort(VertsAABB, function(a, b)
        if bestAxis == 1 then
            return a.center.x < b.center.x
        elseif bestAxis == 2 then
            return a.center.y < b.center.y
        elseif bestAxis == 3 then
            return a.center.z < b.center.z
        else
            assert(false)
            return false
        end
    end)
    
    bestIndex = math.floor(numv / 2)
    
    return bestIndex
end



_G.SpaceSplit.SplitTable = function(VertsAABB, index1, index2)
    assert(index1 > 0 and index2 <= #VertsAABB)
    local result = {}
    for i = index1, index2 do
        result[#result +1 ] = VertsAABB[i]
    end
    return result
end

_G.SpaceSplit.GenerateBatchesRecursive = function(VertsAABB, targetSize, splitGranularity, Results)
    local SplitIndex

    if SpaceSplit.Type == SpaceSplit.TypeBySurface then
        SplitIndex = SpaceSplit.SplitBatchBySurface(VertsAABB, targetSize, splitGranularity)
    elseif  SpaceSplit.Type == SpaceSplit.TypeByAix then
        SplitIndex = SpaceSplit.SplitBatchByAix(VertsAABB, targetSize, splitGranularity)
    elseif  SpaceSplit.Type == SpaceSplit.TypeByHalf then
        SplitIndex =  SpaceSplit.SplitBatchByAixHalf(VertsAABB, targetSize, splitGranularity)
    else
        SplitIndex = SpaceSplit.SplitBatchBySurface(VertsAABB, targetSize, splitGranularity)
    end
    if SplitIndex == #VertsAABB then
        -- Results[#Results + 1] = VertsAABB
        return
    end

    local Table1 = _G.SpaceSplit.SplitTable(VertsAABB, 1, SplitIndex)
    
    if SplitIndex + 1 <= targetSize then
        Results[#Results + 1] = Table1
    else
        SpaceSplit.GenerateBatchesRecursive(Table1, targetSize, splitGranularity, Results)
    end

    local Table2 = _G.SpaceSplit.SplitTable(VertsAABB, SplitIndex + 1, #VertsAABB)
    if #VertsAABB - SplitIndex <= targetSize then
        Results[#Results + 1] = Table2
    else
        SpaceSplit.GenerateBatchesRecursive(Table2, targetSize, splitGranularity, Results)
    end
end

_G.SpaceSplit.GenerateBatches = function(VertsAABB, targetSize, splitGranularity)
    local Results = {}
    SpaceSplit.GenerateBatchesRecursive(VertsAABB, targetSize, splitGranularity, Results)
    return Results
end