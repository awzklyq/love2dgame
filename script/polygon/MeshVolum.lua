_G.MeshVolumNode = {}

MeshVolumNode.SliceX = 10 
MeshVolumNode.SliceY = 10
MeshVolumNode.SliceZ = 10

local GenerateBoxs = function(_MeshBox)
    local _Size = _MeshBox.max - _MeshBox.min
    local SizeX = _Size.x / MeshVolumNode.SliceX
    local SizeY = _Size.y / MeshVolumNode.SliceY
    local SizeZ = _Size.z / MeshVolumNode.SliceZ

    local Boxs = {}
    for xi = 0, MeshVolumNode.SliceX - 1 do
        for yi = 0, MeshVolumNode.SliceY - 1 do
            for zi = 0, MeshVolumNode.SliceZ - 1 do
                local StartX = SizeX * xi
                local StartY = SizeY * yi
                local StartZ = SizeZ * zi

                local StartV = _MeshBox.min + Vector3.new(StartX, StartY, StartZ)
                local EndV = Vector3.new(StartV.x + SizeX, StartV.y + SizeY, StartV.z + SizeZ)

                local box = BoundBox.buildFromMinMax(StartV, EndV)
                Boxs[#Boxs + 1] = box
            end
        end
    end

    return Boxs
end

local PickMeshFromSingleBox = function(mesh, SliceBox)
    if mesh:IntersectFaceAndBVHByBox(SliceBox) then
        return 6
    end

    local _Rays = {}
    local Oris = {}
    Oris[#Oris + 1] = SliceBox.center
    _Rays[#_Rays + 1] = Ray.new(SliceBox.center, Vector3.new(0, 0, 1))
    _Rays[#_Rays + 1] = Ray.new(SliceBox.center, Vector3.new(0, 0, -1))

    _Rays[#_Rays + 1] = Ray.new(SliceBox.center, Vector3.new(0, 1, 0))
    _Rays[#_Rays + 1] = Ray.new(SliceBox.center, Vector3.new(0, -1, 0))

    _Rays[#_Rays + 1] = Ray.new(SliceBox.center, Vector3.new(1, 0, 0))
    _Rays[#_Rays + 1] = Ray.new(SliceBox.center, Vector3.new(-1, 0, 0))

    local PickNum = 0;
    for i = 1, #_Rays do
        if mesh:PickFaceAndBVHByRay(_Rays[i], false) > 0 then
            PickNum = PickNum + 1
        end
    end

    return PickNum
end

local PickMeshFromBoxs = function(mesh, SliceBoxs)
    local InnerBoxs = {}
    local LimitNum = 4
    for i = 1, #SliceBoxs do
        local num = PickMeshFromSingleBox(mesh, SliceBoxs[i])

        if num >= LimitNum then
            InnerBoxs[#InnerBoxs + 1] = SliceBoxs[i]
        end
        coroutine.yield(i / #SliceBoxs)
    end
    return InnerBoxs
end

local CurrentMesh = nil
local CurrentFunc = nil
local FinalFunc = nil
MeshVolumNode.Process = function(mesh)
    local _MeshBox = mesh.box
    local _Boxs = GenerateBoxs(_MeshBox)

    local _InnerBoxs = PickMeshFromBoxs(mesh, _Boxs)

    local AllBoxsNumber = MeshVolumNode.SliceX * MeshVolumNode.SliceY * MeshVolumNode.SliceZ

    local InnerNum = #_InnerBoxs
    _InnerBoxs.VolumPro =  InnerNum / AllBoxsNumber
    if FinalFunc then
        FinalFunc(_InnerBoxs)
    end
    return _InnerBoxs
end

local CoroutineObj = nil
MeshVolumNode.ProcessCoroutine = function(mesh, _finalfunc, func)
    if CoroutineObj then
        _errorAssert(false, "MeshVolumNode CoroutineObj is not nil")  
    end

    CurrentFunc = func
    CurrentMesh = mesh
    FinalFunc = _finalfunc
    CoroutineObj = coroutine.create(MeshVolumNode.Process)
end

app.update(function(dt)
    if CoroutineObj then
        if "dead" ~= coroutine.status(CoroutineObj) then
        
            local _, result = coroutine.resume(CoroutineObj, CurrentMesh)
            if type(result) == 'number' then
                CurrentFunc(result)
            end
        else
            CoroutineObj = nil
        end
    end
end)