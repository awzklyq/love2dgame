local SliceX = 16.0
local SliceY = 16.0
local SliceZ = 16.0

local BoxMortons = {}
local MeshBox = BoundBox.buildFromMinMax(Vector3.new(0, 0, 0), Vector3.new(1.0, 1.0, 1.0))
local BoxSize = MeshBox.max - MeshBox.min
local SliceBoxSize = Vector3.new(BoxSize.x / SliceX, BoxSize.y / SliceY, BoxSize.z / SliceZ)
for IndexX = 0, SliceX - 1 do
    for IndexY = 0, SliceY - 1 do
        for IndexZ = 0, SliceZ - 1 do
            local SliceBoxMin = MeshBox.min + SliceBoxSize * Vector3.new(IndexX , IndexY, IndexZ)
            local SliceBoxMax = SliceBoxMin + SliceBoxSize
            local CenterPos = ((SliceBoxMax + SliceBoxMin) * 0.5) / BoxSize * 1023
            -- log('aaaaaaaa', IndexX, IndexY, IndexZ, CenterPos.x, CenterPos.y, CenterPos.z)
            local Code = CenterPos:GetMortonCode3()
            local BM = {}
            -- _G.logbit(Code, 32)
           
            BM.Code = math.BitAnd(Code, 0x3ffc0000) --math.RightMove(Code, 12)\
            BM.Code = math.RightMove(BM.Code, 18)
            -- _G.logbit(math.RightMove(BM.Code, 24), 6)
            BM.IndexX = IndexX
            BM.IndexY = IndexY
            BM.IndexZ = IndexZ

            BM.x = CenterPos.x
            BM.y = CenterPos.y
            BM.z = CenterPos.z
            BoxMortons[#BoxMortons + 1] = BM
        end
    end
end

table.sort( BoxMortons, function(a, b)
    return a.Code > b.Code
end )

local Count = 0
for i = 1, #BoxMortons - 1 do
    if BoxMortons[i].Code == BoxMortons[i + 1].Code then
        Count = Count + 1
        log('aaaaaaa', BoxMortons[i].Code, BoxMortons[i].IndexX,  BoxMortons[i].IndexX,  BoxMortons[i].IndexY,  BoxMortons[i].IndexZ,  BoxMortons[i].x,  BoxMortons[i].y, BoxMortons[i].z)
        _G.logbit(BoxMortons[i].Code, 32)

        log('bbbbb', BoxMortons[i + 1].Code, BoxMortons[i + 1].IndexX,  BoxMortons[i + 1].IndexX,  BoxMortons[i + 1].IndexY,  BoxMortons[i + 1].IndexZ,  BoxMortons[i + 1].x,  BoxMortons[i + 1].y, BoxMortons[i + 1].z)
        _G.logbit(BoxMortons[i + 1].Code, 32)
    end

    if math.abs(BoxMortons[i].Code - BoxMortons[i + 1].Code) ~= 1 then
        log('ssssssss', BoxMortons[i + 1].Code, BoxMortons[i].Code)
    end
end


log('bbbbbbb',BoxMortons[1].Code, BoxMortons[#BoxMortons].Code, #BoxMortons)

