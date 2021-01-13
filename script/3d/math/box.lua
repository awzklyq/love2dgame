_G.BoundBox = {}
function BoundBox.new()
    local box = setmetatable({}, {__index = BoundBox});

    box.min = Vector3.new(0,0,0)
    box.max = Vector3.new(1,1,1)

    return box
end

BoundBox.buildFromMesh3D = function(mesh)
    assert(mesh.verts)
    local box = BoundBox.new()
    box.min = Vector3.new(mesh.verts[1][1], mesh.verts[1][2], mesh.verts[1][3])
    box.max = Vector3.new(mesh.verts[1][1], mesh.verts[1][2], mesh.verts[1][3])
    for i = 2, #mesh.verts do
        local vert = mesh.verts[i]
        box.min.x = math.min(mesh.verts[i][1], box.min.x)
        box.min.y = math.min(mesh.verts[i][2], box.min.y)
        box.min.z = math.min(mesh.verts[i][3], box.min.z)

        box.max.x = math.max(mesh.verts[i][1], box.max.x)
        box.max.y = math.max(mesh.verts[i][2], box.max.y)
        box.max.z = math.max(mesh.verts[i][3], box.max.z)
    end

    return box
end

_G.OrientedBox = {}
function OrientedBox.new()
    local box = setmetatable({}, {__index = OrientedBox});

    box.vs = {}
    for i = 1, 8 do
        vs[i] = Vector3.new()
    end
    return box
end

OrientedBox.buildFormBoundBox = function( vmin, vmax )
    local box = OrientedBox.new()
	box.vs[1] = Vector3.new( vmin.x, vmin.y, vmin.z );
	box.vs[2] = Vector3.new( vmax.x, vmin.y, vmin.z );
	box.vs[3] = Vector3.new( vmin.x, vmax.y, vmin.z );
	box.vs[4] = Vector3.new( vmax.x, vmax.y, vmin.z );
	box.vs[5] = Vector3.new( vmin.x, vmin.y, vmax.z );
	box.vs[6] = Vector3.new( vmax.x, vmin.y, vmax.z );
	box.vs[7] = Vector3.new( vmin.x, vmax.y, vmax.z );
	box.vs[8] = Vector3.new( vmax.x, vmax.y, vmax.z );

	return box;
end