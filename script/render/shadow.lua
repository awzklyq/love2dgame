_G.Shadow = {}

local function checkInIndexs(indexdatas, vert)
    for i = 1, #indexdatas do
        local indexdata = indexdatas[i]
        if math.abs(vert[1] - indexdata[1]) <= math.cEpsilon and math.abs(vert[2] - indexdata[2]) <= math.cEpsilon and math.abs(vert[3] - indexdata[3]) <= math.cEpsilon then
            return i
        end
    end

    return 0
end

local function checkAndAddInIndexs(indexdatas, vert)
    local index = checkInIndexs(indexdatas, vert)
    if index > 0 then
        return index
    end

    table.insert(indexdatas, vert)
    return #indexdatas
end

Shadow.buildShadowVolume = function(mesh3d, lightdir)
    assert(mesh3d.renderid == Render.Mesh3DId)

    assert(lightdir.renderid == Render.Vector3Id)
    -- not indexs hahahaha....

    local verts = mesh3d.verts
    
    --find common verts
    local indexdatas = {}
    for i = 1, #verts do
        local index =  checkInIndexs(indexdatas, verts[i])
        if index == 0 then
            table.insert(indexdatas, verts[i])
        end
    end
    
    local faces = {}
    for i = 1, #verts, 3 do
        local face = {}
        face.vert1 = checkInIndexs(indexdatas, {verts[i][1], verts[i][2], verts[i][3]})
        face.vert2 = checkInIndexs(indexdatas, {verts[i + 1][1], verts[i + 1][2], verts[i + 1][3]})
        face.vert3 = checkInIndexs(indexdatas, {verts[i + 2][1], verts[i + 2][2], verts[i + 2][3]})
        face.normal = Vector3.new(verts[i][6], verts[i][7], verts[i][8])
        face.needmove = false
        table.insert(faces, face)
    end

    local dis = math.MaxNumber
    local movedis = Vector3.mul(lightdir, dis)
    for i = 1, #faces do
        local face = faces[i]
        if Vector3.dot(face.normal, lightdir) < 0 then
            face.needmove = true;

            local vert1 = indexdatas[face.vert1]
            local newvert1 = {movedis.x + vert1[1], movedis.y + vert1[2], movedis.z + vert1[3]}
            face.newvert1 = checkAndAddInIndexs(indexdatas, newvert1)
            
            local vert2 = indexdatas[face.vert2]
            local newvert2 = {movedis.x + vert2[1], movedis.y + vert2[2], movedis.z + vert2[3]}
            face.newvert2 = checkAndAddInIndexs(indexdatas, newvert2)

            local vert3 = indexdatas[face.vert3]
            local newvert3 = {movedis.x + vert3[1], movedis.y + vert3[2], movedis.z + vert3[3]}
            face.newvert3 = checkAndAddInIndexs(indexdatas, newvert3)

        end
    end


    -- local newfaces = {}
    for i = 1, #faces do
        local oface = faces[i]
        if oface.needmove then
            local face1 = {}
            face1.vert1 = oface.vert1
            face1.vert2 = oface.vert2
            face1.vert3 = oface.newvert1
            face1.normal = oface.normal
            table.insert(faces, face1)
            -- table.insert(newfaces, face1)

            local face2 = {}
            face2.vert1 = oface.vert1
            face2.vert2 = oface.newvert1
            face2.vert3 = oface.vert3
            face2.normal = oface.normal
            table.insert(faces, face2)

            oface.vert1 = oface.newvert1
            oface.vert2 = oface.newvert2
            oface.vert3 = oface.newvert3
            -- table.insert(newfaces, face2)
        end
    end

    local vertexs = {}
    for i = 1, #faces do
        local face = faces[i]
        local data = indexdatas[face.vert1]
        local vertex1 = {data[1], data[2], data[3], 0, 0, face.normal.x, face.normal.y, face.normal.z}

        data = indexdatas[face.vert2]
        local vertex2 = {data[1], data[2], data[3], 0, 0, face.normal.x, face.normal.y, face.normal.z}

        data = indexdatas[face.vert3]
        local vertex3 = {data[1], data[2], data[3], 0, 0, face.normal.x, face.normal.y, face.normal.z}

        table.insert(vertexs, vertex1)
        table.insert(vertexs, vertex2)
        table.insert(vertexs, vertex3)
    end

    return Mesh3D.createFromPoints(vertexs)
end