_G.BoundBox = {}
function BoundBox.new()
    local box = setmetatable({}, {__index = BoundBox});

    box.min = Vector3.new(0,0,0)
    box.max = Vector3.new(1,1,1)

    box.center = Vector3.new(0.5, 0.5, 0.5)
    return box
end

function BoundBox:addSelf(bb)
    self.min.x = math.min(self.min.x, bb.min.x)
    self.min.y = math.min(self.min.y, bb.min.y)
    self.min.z = math.min(self.min.z, bb.min.z)

    self.max.x = math.max(self.max.x, bb.max.x)
    self.max.y = math.max(self.max.y, bb.max.y)
    self.max.z = math.max(self.max.z, bb.max.z)

    self.center = Vector3.new((self.min.x + self.max.x) * 0.5, (self.min.y + self.max.y) * 0.5, (self.min.z + self.max.z) * 0.5)
end

function BoundBox.add(bb1, bb2)
    local box = BoundBox.new()
    box.min.x = math.min(bb1.min.x, bb2.min.x)
    box.min.y = math.min(bb1.min.y, bb2.min.y)
    box.min.z = math.min(bb1.min.z, bb2.min.z)

    box.max.x = math.max(bb1.max.x, bb2.max.x)
    box.max.y = math.max(bb1.max.y, bb2.max.y)
    box.max.z = math.max(bb1.max.z, bb2.max.z)

    box.center = Vector3.new((box.min.x + box.max.x) * 0.5, (box.min.y + box.max.y) * 0.5, (box.min.z + box.max.z) * 0.5)
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

    box.center = Vector3.new((box.min.x + box.max.x) * 0.5, (box.min.y + box.max.y) * 0.5, (box.min.z + box.max.z) * 0.5)
    return box
end

BoundBox.buildFromMinMax = function(min, max)
    local box = BoundBox.new()
    box.min = min
    box.max = max
    box.center = Vector3.new((box.min.x + box.max.x) * 0.5, (box.min.y + box.max.y) * 0.5, (box.min.z + box.max.z) * 0.5)
    return box
end

function BoundBox:buildMesh()
    local verts = {}
    local center = Vector3.new(self.center.x, self.center.y, self.center.z)
    local weidth = Vector3.new(self.max.x - self.min.x, 0, 0)
    local height = Vector3.new(0, self.max.y - self.min.y, 0)
    local depth = Vector3.new(0, 0, self.max.z - self.min.z)

    -- Bottom ol 1
    local position = Vector3.sub(Vector3.sub(Vector3.sub(center, weidth),height),depth)
	-- vb->mPosition = pm.mCenter - pm.mWidth - pm.mHeight - pm.mDepth;

    verts[#verts + 1] = {position.x, position.y, position.z}

    position = Vector3.sub(Vector3.sub(Vector3.add(center, weidth),height),depth)
    -- vb->mPosition	= pm.mCenter + pm.mWidth - pm.mHeight - pm.mDepth;
    verts[#verts + 1] = {position.x, position.y, position.z}

    -- Bottom ol 2
    position = Vector3.sub(Vector3.sub(Vector3.add(center, weidth),height),depth)
	-- vb->mPosition	= pm.mCenter + pm.mWidth - pm.mHeight - pm.mDepth;
    verts[#verts + 1] = {position.x, position.y, position.z}

    position = Vector3.sub(Vector3.add(Vector3.add(center, weidth),height),depth)
	-- vb->mPosition	= pm.mCenter + pm.mWidth + pm.mHeight - pm.mDepth;
    verts[#verts + 1] = {position.x, position.y, position.z}

    -- Bottom ol 3
    position = Vector3.sub(Vector3.add(Vector3.add(center, weidth),height),depth)
	-- vb->mPosition	= pm.mCenter + pm.mWidth + pm.mHeight - pm.mDepth;
    verts[#verts + 1] = {position.x, position.y, position.z}
    
    position = Vector3.sub(Vector3.add(Vector3.sub(center, weidth),height),depth)
	-- vb->mPosition	= pm.mCenter - pm.mWidth + pm.mHeight - pm.mDepth;
    verts[#verts + 1] = {position.x, position.y, position.z}

	-- Bottom ol 4
    position = Vector3.sub(Vector3.add(Vector3.sub(center, weidth),height),depth)
    -- vb->mPosition	= pm.mCenter - pm.mWidth + pm.mHeight - pm.mDepth;
    verts[#verts + 1] = {position.x, position.y, position.z}
    
    position = Vector3.sub(Vector3.sub(Vector3.sub(center, weidth),height),depth)
	-- vb->mPosition	= pm.mCenter - pm.mWidth - pm.mHeight - pm.mDepth;
    verts[#verts + 1] = {position.x, position.y, position.z}
    
	-- Top ol 1
    position = Vector3.add(Vector3.sub(Vector3.sub(center, weidth),height),depth)
    -- vb->mPosition	= pm.mCenter - pm.mWidth - pm.mHeight + pm.mDepth;
    verts[#verts + 1] = {position.x, position.y, position.z}

    position = Vector3.add(Vector3.sub(Vector3.add(center, weidth),height),depth)
	-- vb->mPosition	= pm.mCenter + pm.mWidth - pm.mHeight + pm.mDepth;
    verts[#verts + 1] = {position.x, position.y, position.z}
    
	-- Top ol 2
    position = Vector3.add(Vector3.sub(Vector3.add(center, weidth),height),depth)
    -- vb->mPosition	= pm.mCenter + pm.mWidth - pm.mHeight + pm.mDepth;
    verts[#verts + 1] = {position.x, position.y, position.z}

    position = Vector3.add(Vector3.sub(Vector3.add(center, weidth),height),depth)
	-- vb->mPosition	= pm.mCenter + pm.mWidth + pm.mHeight + pm.mDepth;
    verts[#verts + 1] = {position.x, position.y, position.z}

	-- Top ol 3
    position = Vector3.add(Vector3.add(Vector3.add(center, weidth),height),depth)
    -- vb->mPosition	= pm.mCenter + pm.mWidth + pm.mHeight + pm.mDepth;
    verts[#verts + 1] = {position.x, position.y, position.z}

    position = Vector3.add(Vector3.add(Vector3.sub(center, weidth),height),depth)
    -- vb->mPosition	= pm.mCenter - pm.mWidth + pm.mHeight + pm.mDepth;
    verts[#verts + 1] = {position.x, position.y, position.z}

	-- Top ol 4
    position = Vector3.add(Vector3.add(Vector3.sub(center, weidth),height),depth)
    -- vb->mPosition	= pm.mCenter - pm.mWidth + pm.mHeight + pm.mDepth;
    verts[#verts + 1] = {position.x, position.y, position.z}

    position = Vector3.add(Vector3.sub(Vector3.sub(center, weidth),height),depth)
	-- vb->mPosition	= pm.mCenter - pm.mWidth - pm.mHeight + pm.mDepth;
    verts[#verts + 1] = {position.x, position.y, position.z}

	-- Side ol 1
    position = Vector3.sub(Vector3.sub(Vector3.sub(center, weidth),height),depth)
    -- vb->mPosition	= pm.mCenter - pm.mWidth - pm.mHeight - pm.mDepth;
    verts[#verts + 1] = {position.x, position.y, position.z}

    position = Vector3.sub(Vector3.sub(Vector3.add(center, weidth),height),depth)
	-- vb->mPosition	= pm.mCenter - pm.mWidth - pm.mHeight + pm.mDepth;
    verts[#verts + 1] = {position.x, position.y, position.z}

	-- Side ol 2
    position = Vector3.sub(Vector3.sub(Vector3.add(center, weidth),height),depth)
    -- vb->mPosition	= pm.mCenter + pm.mWidth - pm.mHeight - pm.mDepth;
    verts[#verts + 1] = {position.x, position.y, position.z}

    position = Vector3.add(Vector3.sub(Vector3.add(center, weidth),height),depth)
	-- vb->mPosition	= pm.mCenter + pm.mWidth - pm.mHeight + pm.mDepth;
    verts[#verts + 1] = {position.x, position.y, position.z}

	-- Side ol 3
    position = Vector3.sub(Vector3.add(Vector3.add(center, weidth),height),depth)
    -- vb->mPosition	= pm.mCenter + pm.mWidth + pm.mHeight - pm.mDepth;
    verts[#verts + 1] = {position.x, position.y, position.z}

    position = Vector3.add(Vector3.add(Vector3.add(center, weidth),height),depth)
	-- vb->mPosition	= pm.mCenter + pm.mWidth + pm.mHeight + pm.mDepth;
    verts[#verts + 1] = {position.x, position.y, position.z}

	-- Side ol 4
    position = Vector3.sub(Vector3.add(Vector3.sub(center, weidth),height),depth)
    -- vb->mPosition	= pm.mCenter - pm.mWidth + pm.mHeight - pm.mDepth;
    verts[#verts + 1] = {position.x, position.y, position.z}

    position = Vector3.add(Vector3.add(Vector3.sub(center, weidth),height),depth)
	-- vb->mPosition	= pm.mCenter - pm.mWidth + pm.mHeight + pm.mDepth;
    verts[#verts + 1] = {position.x, position.y, position.z}

    return Mesh3D.createFromPoints(verts)
end

BoundBox.getIntersectBox = function(box1, box2)
    local box = BoundBox.new()

    box.min.x = math.max( box1.min.x, box2.min.x );
	box.min.y = math.max( box1.min.y, box2.min.y );
	box.min.z = math.max( box1.min.z, box2.min.z );

	box.max.x = math.min( box1.max.x, box2.max.x );
	box.max.y = math.min( box1.max.y, box2.max.y );
    box.max.z = math.min( box1.max.z, box2.max.z );
    
    if box.min.x > box.max.x or box.min.y > box.max.y or box.min.z > box.max.z then
        return BoundBox.new()
    end

    box.center = Vector3.new((box.min.x + box.max.x) * 0.5, (box.min.y + box.max.y) * 0.5, (box.min.z + box.max.z) * 0.5)
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