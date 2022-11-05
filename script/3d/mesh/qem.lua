--Quadric Error Metrics
_G.QEM = {}

QEM.USE_V1 = 1
QEM.USE_V2 = 2
QEM.USE_VC = 3

local CheckInPosition = function(Positions, P)
    for i = 1, #Positions do
        if Positions[i] == P then
            return i
        end 
    end
    return 0
end

local CreateFaceQMat = function(face)
    face.QMat = Matrix3D.createFromNumbers(face.a * face.a, face.a * face.b, face.a * face.c, face.a * face.d,
    face.a * face.b, face.b * face.b, face.b * face.c, face.b * face.d,
    face.a * face.c, face.b * face.c, face.c * face.c, face.c * face.d,
    face.a * face.d, face.b * face.d, face.c * face.d, face.d * face.d    
    )

    -- face.QMat:Log('aaaaaaaa')
end

local GetErrorValue = function(Qmat, v4)
    return Vector4.dot(v4 * Qmat, v4)
end

local CreateEdgesQMat = function(edge)
    edge.QMat = edge.P1.QMat + edge.P2.QMat

    local VC = (edge.P1 + edge.P2) / 2 
       local isInverse = edge.QMat:determinant( ) ~= 0
    if isInverse  then
        local error1 = GetErrorValue(edge.QMat, edge.P1:CovertVector4())
        local error2 = GetErrorValue(edge.QMat, edge.P2:CovertVector4())
        local error3 = GetErrorValue(edge.QMat, VC:CovertVector4())
        local errorvalue = math.min(math.min(error1, error2), error3)
        if errorvalue == error1 then
            edge.QV = edge.P1
        elseif errorvalue == error2 then
            edge.QV = edge.P2
        elseif errorvalue == error3 then
            edge.QV = VC
        end

        edge.IsInverse = true

    else
        edge.QV = VC
        edge.IsInverse = false
    end
end

local CreatePointsQMat = function(p)
    local qmat = Matrix3D.createFromNumbers(0, 0, 0, 0,
    0, 0, 0, 0,
    0, 0, 0, 0,
    0, 0, 0, 0);
    if p.faces then
        for fi = 1, #p.faces do
            local f = p.faces[fi]
            qmat = qmat + f.QMat
        end
        -- qmat = qmat / #p.faces
    end
    p.QMat = qmat
end


local AddFaceToPoints = function(p, f)
    if not p.faces then
        p.faces = {}
    end

    p.faces[#p.faces + 1] = f
end

local AddEdgeToFace = function(edge,  face, edges)
    if not face.Edges then
        face.Edges = {}
    end

    local needadd = true
    for i = 1, #edges do
        local e = edges[i]
        if e == edge then
            edge = e
            needadd = false
            break
        end
    end
    if needadd then
        edges[#edges + 1] =  edge
    end

    face.Edges[#face.Edges + 1] = edge
end


QEM.Process = function(mesh)
    local Positions = {}
    local UVs = {}
    local Normals = {}
    local Indexbuff = {}
    
    for i = 1, #mesh.verts do
        local v = mesh.verts[i]
        local P = Point3D.new(v[1], v[2], v[3])
        local index = CheckInPosition(Positions, P)
        if index > 0 then
            Indexbuff[#Indexbuff + 1] = index
        else
            Positions[#Positions + 1] = P
            UVs[#UVs + 1] = Vector.new(v[4], v[5])
            Normals[#Normals + 1] = Vector3.new(v[6], v[7], v[8])
            Indexbuff[#Indexbuff + 1] = #Positions
        end
        
    end

    -- Create Face Edge..
    -- Create Q Mat..
    assert(#Indexbuff % 3 == 0 )
    local Faces = {}
    local Edges = {}
    for i = 1, #Indexbuff, 3 do
        local p1 = Positions[Indexbuff[i]]
        local p2 = Positions[Indexbuff[i + 1]]
        local p3 = Positions[Indexbuff[i + 2]]

        local face = Face3D.new(p1, p2, p3)
        CreateFaceQMat(face)

        AddFaceToPoints(p1, face)
        AddFaceToPoints(p2, face)
        AddFaceToPoints(p3, face)

        local edge1 = Edge3D.new(p1, p2)
        local edge2 = Edge3D.new(p2, p3)
        local edge3 = Edge3D.new(p3, p1)

        -- face.Edges = {}
        -- face.Edges[1] = edge1
        -- face.Edges[2] = edge2
        -- face.Edges[3] = edge3

        AddEdgeToFace(edge1, face, Edges)
        AddEdgeToFace(edge2, face, Edges)
        AddEdgeToFace(edge3, face, Edges)

        -- Edges[#Edges + 1] = edge1
        -- Edges[#Edges + 1] = edge2
        -- Edges[#Edges + 1] = edge3

        Faces[#Faces + 1] = face
    end

    -- Create Points Q Mat
    for i = 1, #Positions do
        local p = Positions[i]
        CreatePointsQMat(p)
    end

    table.sort(Edges, function(a, b)
        return Vector3.distance(a.P1, a.P2) < Vector3.distance(b.P1, b.P2)
    end)
    for i = 1, #Edges do
        local e = Edges[i]
        CreateEdgesQMat(e)
    end

    for i = 1, #Edges do
        local e = Edges[i]
        if e.QV then
            e.P1.x = e.QV.x
            e.P1.y = e.QV.y
            e.P1.z = e.QV.z

            e.P2.x = e.QV.x
            e.P2.y = e.QV.y
            e.P2.z = e.QV.z

        end
    end

    local verts = {}
    for i = 1, #Faces do
        local f = Faces[i]
        -- Normal
        local v1 = f.Points[1]:CovertVector3()
        local v2 = f.Points[2]:CovertVector3()
        local v3 = f.Points[3]:CovertVector3()

        -- v1:Log('v111111')
        -- v2:Log('v222222')
        -- v3:Log('v333333')
        local v11 = v2 - v1
        local v22 = v3 - v1
        local NormalInfo = Vector3.cross(v11, v22)
        NormalInfo:normalize()
        local vert1 = {v1.x, v1.y, v1.z, 0, 0, NormalInfo.x, NormalInfo.y, NormalInfo.z}
        local vert2 = {v2.x, v2.y, v2.z, 0, 0, NormalInfo.x, NormalInfo.y, NormalInfo.z}
        local vert3 = {v3.x, v3.y, v3.z, 0, 0, NormalInfo.x, NormalInfo.y, NormalInfo.z}
        verts[#verts + 1] = vert1
        verts[#verts + 1] = vert2
        verts[#verts + 1] = vert3
    end
    return Mesh3D.createFromPoints(verts)
end