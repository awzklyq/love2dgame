_G.MeshGenusGenerateNode = {}

local InsertEdge = function(InEdges, InNewEdge)
    local IsNeed = true
    for i = 1, #InEdges do
        if InEdges[i] == InNewEdge then
            IsNeed = false
            break
        end
    end

    if IsNeed then
        InEdges[#InEdges + 1] = InNewEdge
    end
end


local InsertVerts = function(InVerts, InNewVert)
    local IsNeed = true
    for i = 1, #InVerts do
        if InVerts[i] == InNewVert then
            IsNeed = false
            break
        end
    end

    if IsNeed then
        InVerts[#InVerts + 1] = InNewVert
    end
end

MeshGenusGenerateNode.Process = function(InMesh)
    local MeshVerts = InMesh.verts
    local VertPosTable = {} 
    for i = 1, #MeshVerts do
        VertPosTable[i] = Vector3.new(MeshVerts[i][1], MeshVerts[i][2], MeshVerts[i][3])
    end
    
    _errorAssert(#VertPosTable % 3 == 0, "MeshGenusGenerateNode VertPosTable Number is not Multiple of 3")

    local Triangles = {}
    local Edges = {}
    local Verts = {}
    for i = 1, #VertPosTable, 3 do
        Triangles[#Triangles + 1] = Triangle3D.new(VertPosTable[i], VertPosTable[i + 1], VertPosTable[i + 2])
        InsertVerts(Verts, VertPosTable[i])
        InsertVerts(Verts, VertPosTable[i + 1])
        InsertVerts(Verts, VertPosTable[i + 2])
    end

    for i = 1, #Triangles do
        InsertEdge(Edges, Triangles[i].Edge1)
        InsertEdge(Edges, Triangles[i].Edge2)
        InsertEdge(Edges, Triangles[i].Edge3)
    end

    log('aaaaaaaaa', #Verts,  #Edges, #Triangles)
    local X = #Verts - #Edges + #Triangles

    local G = (2 - X) / 2
    return G
end