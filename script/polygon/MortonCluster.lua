_G.MortonClusterNode = {}
local MergeApproximateCodeByGrid = function(InOriData, InVector3Array)
    local SliceX = 20
    local SliceY = 20
    local SliceZ = 10

    local _Size = Vector3.new(1 / SliceX, 1 / SliceY, 1 / SliceZ)
 
    local GridMortonDatas = {}
    for i = 0, SliceX - 1 do
        for j = 0, SliceY -1 do
            for k = 0, SliceZ - 1 do
                local StartV = Vector3.new(i, j, k) * _Size
                local EndV = StartV + _Size

                local Center = (StartV + EndV) * 0.5
                Center = Center * 1023
                GridMortonDatas[#GridMortonDatas + 1] = {Code = Center:GetMortonCode3(), IndexArray = {}, Pos = Center}
            end
        end
    end

    for i = 1, #InOriData do
        local _BitNumber = -1
        local _Index = -1
        for j = 1, #GridMortonDatas do
            local LeftNum = math.BitEquationRightNumber(GridMortonDatas[j].Code,  InOriData[i].Code)
            if LeftNum > _BitNumber then
                _BitNumber = LeftNum
                _Index = j
            end
        end

        if _Index > 0 then
            math.AppendArray(GridMortonDatas[_Index].IndexArray, InOriData[i].IndexArray)
        end
    end

    local NumTemp = 0;
    local CombieApproximateData = {}
    for i = 1, #GridMortonDatas do
        -- log('ssssss', GridMortonDatas[i].Pos.x, GridMortonDatas[i].Pos.y, GridMortonDatas[i].Pos.z, GridMortonDatas[i].Code)
        -- logbit(GridMortonDatas[i].Code)
        if #GridMortonDatas[i].IndexArray > 0 then
            local _IndexArray = {}
            local _box = BoundBox.new()
            for j = 1, #GridMortonDatas[i].IndexArray do
                local _index = GridMortonDatas[i].IndexArray[j]
                local InPos = InVector3Array[_index]
                _box = _box + InPos
                _IndexArray[#_IndexArray + 1] = _index

                -- log('ssssss', GridMortonDatas[i].Pos.x, GridMortonDatas[i].Pos.y, GridMortonDatas[i].Pos.z, GridMortonDatas[i].Code)
                -- logbit(GridMortonDatas[i].Code)
            end
            NumTemp = NumTemp + #_IndexArray

            CombieApproximateData[#CombieApproximateData + 1] = {Box = _box, IndexArray = _IndexArray, Code = GridMortonDatas[i].Code}
        end
    end

    math.SortLargeArray(CombieApproximateData, function(v1,v2)
        if v1.Code > v2.Code then
            return true
        end
        return false
    end)

    return CombieApproximateData
end

local MergeApproximateCode = function(InOriData)
    _errorAssert(#InOriData > 2, "MortonClusterNode. MergeApproximateCode InOriData Lenght less then 2. ")

    local _IndexArray = {}
    local _box = BoundBox.new()
    local CombieApproximateData = {}
    local LeftNum = -1;
    local RightNum = -1;
    for i = 1, #InOriData - 1 do
        if i == 1 then
            _box = _box + _AndOr(InOriData[i].Box, InOriData[i].Pos)
            math.AppendArray( _IndexArray, InOriData[i].IndexArray)
        else
            LeftNum = math.BitEquationRightNumber(InOriData[i].Code,  InOriData[i-1].Code)
            RightNum = math.BitEquationRightNumber(InOriData[i].Code,  InOriData[i+1].Code)
            if LeftNum >= RightNum then
                _box = _box + _AndOr(InOriData[i].Box, InOriData[i].Pos)
                math.AppendArray( _IndexArray, InOriData[i].IndexArray)
            else
                CombieApproximateData[#CombieApproximateData + 1] = {Box = _box, IndexArray = _IndexArray, Code = _box.center:GetMortonCode3()}
                _IndexArray = {}
                _box = BoundBox.new()

                _box = _box + _AndOr(InOriData[i].Box, InOriData[i].Pos)
                math.AppendArray( _IndexArray, InOriData[i].IndexArray)
            end 
        end
    end

    _errorAssert(LeftNum > 0 and RightNum > 0, "MortonClusterNode. MergeApproximateCode LeftNum or RightNum less then 0. ")
    local NeedProcessLastData = true
    -- Process last data..
    CombieApproximateData[#CombieApproximateData + 1] = {Box = _box, IndexArray = _IndexArray,  Code = _box.center:GetMortonCode3()}

    if NeedProcessLastData then
        local _Index = -1
        local _MaxBitNum = -1
        for i = 1, #CombieApproximateData do
            local BitNum =  math.BitEquationRightNumber(CombieApproximateData[i].Code,  InOriData[#InOriData].Code)
            if BitNum > _MaxBitNum then
                _Index = i
                _MaxBitNum = BitNum
            end
        end

        _errorAssert(_Index ~= -1, "MortonClusterNode. MergeApproximateCode_Index less then 0. ")
        local CurData = CombieApproximateData[_Index]
        CurData.Box =  CurData.Box + _AndOr(InOriData[#InOriData].Box, InOriData[#InOriData].Pos)
        CurData.Code =  CurData.Box.center:GetMortonCode3()
        math.AppendArray( CurData.IndexArray, InOriData[#InOriData].IndexArray)
    end

    
    math.SortLargeArray(CombieApproximateData, function(v1,v2)
        if v1.Code > v2.Code then
            return true
        end
        return false
    end)

    return CombieApproximateData
end

MortonClusterNode.ProcessVector3 = function(InVector3Array, LimitNum)
    _errorAssert(#InVector3Array > 2 and LimitNum >= 2, "MortonClusterNode. InVector3Array Lenght less then 2. ")

    local _MeshBox = BoundBox.new()
    for i = 1, #InVector3Array do
        _MeshBox = _MeshBox + InVector3Array[i]
    end

    local Vector3MortonCodes = {}
    for i = 1, #InVector3Array do
        local v = {}
        v.Pos = ((InVector3Array[i] - _MeshBox.min) / (_MeshBox.max - _MeshBox.min)) * 1023
        if _MeshBox.max.z == _MeshBox.min.z then
            v.Pos.z = 0
        end
        
        v.Code = v.Pos:GetMortonCode3()

        v.IndexArray = {}
        v.IndexArray[1] = i
        Vector3MortonCodes[#Vector3MortonCodes + 1] = v
    end

    math.SortLargeArray(Vector3MortonCodes, function(v1,v2)
        if v1.Code > v2.Code then
            return true
        end
        return false
    end)

    local ResultDatas = MergeApproximateCodeByGrid(Vector3MortonCodes, InVector3Array)
    -- local ResultDatas =  MergeApproximateCode(Vector3MortonCodes)
    while #ResultDatas > LimitNum do
        ResultDatas = MergeApproximateCode(ResultDatas)
    end
    return ResultDatas
end