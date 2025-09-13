_G.BoundBox = {}

local metatable_BoundBox = {}
metatable_BoundBox.__index = BoundBox

metatable_BoundBox.__add = function(myvalue, v)
    if v.renderid then
        if v.renderid == Render.Vector3Id then
            local box = BoundBox.new()
            box.min.x = math.min( myvalue.min.x, v.x );
            box.min.y = math.min( myvalue.min.y, v.y );
            box.min.z = math.min( myvalue.min.z, v.z );
            box.max.x = math.max( myvalue.max.x, v.x );
            box.max.y = math.max( myvalue.max.y, v.y );
            box.max.z = math.max( myvalue.max.z, v.z );
            box.center = Vector3.new((box.min.x + box.max.x) * 0.5, (box.min.y + box.max.y) * 0.5, (box.min.z + box.max.z) * 0.5)
            return box
        elseif  v.renderid == Render.BoundBoxId then
            return BoundBox.add(myvalue, v)
        end
    end
    return  BoundBox.add(myvalue, v)
end


function BoundBox.new()
    local box = setmetatable({}, metatable_BoundBox);

    box.min = Vector3.new(math.maxFloat, math.maxFloat, math.maxFloat)
    box.max = Vector3.new(-math.maxFloat, -math.maxFloat, -math.maxFloat)

    box.center = Vector3.new(0.0, 0.0, 0.0)

    BoundBox.renderid = Render.BoundBoxId
    return box
end

function BoundBox:AddVector3(InVec)
    self.min.x = math.min(self.min.x, InVec.x)
    self.min.y = math.min(self.min.y, InVec.y)
    self.min.z = math.min(self.min.z, InVec.z)

    self.max.x = math.max(self.max.x, InVec.x)
    self.max.y = math.max(self.max.y, InVec.y)
    self.max.z = math.max(self.max.z, InVec.z)

    self.center = Vector3.new((self.min.x + self.max.x) * 0.5, (self.min.y + self.max.y) * 0.5, (self.min.z + self.max.z) * 0.5)
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

function BoundBox:GetCenter()
    return Vector3.Copy(self.center)
end

function BoundBox:GetSurfaceArea()
    local extendSize =  self.max - self.min

    return extendSize.x * extendSize.y + extendSize.x * extendSize.z + extendSize.z * extendSize.y
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

    box.center = Vector3.new((box.min.x + box.max.x) * 0.5, (box.min.y + box.max.y) * 0.5, (box.min.z + box.max.z) * 0.5)
    return box
end

BoundBox.buildFromPoints = function(InPoints)
    assert(#InPoints > 0)
    local box = BoundBox.new()
    box.min = Vector3.new(InPoints[1].x, InPoints[1].y, InPoints[1].z)
    box.max = Vector3.new(InPoints[1].x, InPoints[1].y, InPoints[1].z)
    for i = 2, #InPoints do
        local P = InPoints[i]
        box.min.x = math.min(P.x, box.min.x)
        box.min.y = math.min(P.y, box.min.y)
        box.min.z = math.min(P.z, box.min.z)

        box.max.x = math.max(P.x, box.max.x)
        box.max.y = math.max(P.y, box.max.y)
        box.max.z = math.max(P.z, box.max.z)
    end

    box.center = Vector3.new((box.min.x + box.max.x) * 0.5, (box.min.y + box.max.y) * 0.5, (box.min.z + box.max.z) * 0.5)
    return box
end
BoundBox.buildFromMinMax = function(min, max)
    local box = BoundBox.new()
    box.min = Vector3.copy(min)
    box.max = Vector3.copy(max)
    box.center = Vector3.new((box.min.x + box.max.x) * 0.5, (box.min.y + box.max.y) * 0.5, (box.min.z + box.max.z) * 0.5)
    return box
end


BoundBox.BuildFromPointAndSize = function(InPoint, InSize)
    return BoundBox.buildFromMinMax(InPoint - (InSize * 0.5), InPoint + (InSize * 0.5))
end

function BoundBox:buildMeshLines(InFormMatrix)
    local xsize = self.max.x - self.min.x
    local ysize = self.max.y - self.min.y
    local zsize = self.max.z - self.min.z

    local points = {}
    points[#points + 1] = Vector3.new(self.min.x, self.min.y, self.min.z)
    points[#points + 1] = Vector3.new(self.min.x + xsize, self.min.y, self.min.z)

    points[#points + 1] = Vector3.new(self.min.x, self.min.y, self.min.z)
    points[#points + 1] = Vector3.new(self.min.x, self.min.y + ysize, self.min.z)

    points[#points + 1] = Vector3.new(self.min.x + xsize, self.min.y, self.min.z)
    points[#points + 1] = Vector3.new(self.min.x + xsize, self.min.y + ysize, self.min.z)

    points[#points + 1] = Vector3.new(self.min.x, self.min.y + ysize, self.min.z)
    points[#points + 1] = Vector3.new(self.min.x+ xsize, self.min.y + ysize, self.min.z)

    points[#points + 1] = Vector3.new(self.min.x, self.min.y, self.min.z)
    points[#points + 1] = Vector3.new(self.min.x, self.min.y, self.min.z + zsize)

    points[#points + 1] = Vector3.new(self.min.x + xsize, self.min.y, self.min.z)
    points[#points + 1] = Vector3.new(self.min.x + xsize, self.min.y, self.min.z+ zsize)

    points[#points + 1] = Vector3.new(self.min.x, self.min.y + ysize, self.min.z)
    points[#points + 1] = Vector3.new(self.min.x, self.min.y + ysize, self.min.z+ zsize)

    points[#points + 1] = Vector3.new(self.min.x+ xsize, self.min.y + ysize, self.min.z)
    points[#points + 1] = Vector3.new(self.min.x+ xsize, self.min.y + ysize, self.min.z+ zsize)

    points[#points + 1] = Vector3.new(self.min.x, self.min.y, self.min.z+ zsize)
    points[#points + 1] = Vector3.new(self.min.x + xsize, self.min.y, self.min.z+ zsize)

    points[#points + 1] = Vector3.new(self.min.x, self.min.y, self.min.z+ zsize)
    points[#points + 1] = Vector3.new(self.min.x, self.min.y + ysize, self.min.z+ zsize)

    points[#points + 1] = Vector3.new(self.min.x + xsize, self.min.y, self.min.z+ zsize)
    points[#points + 1] = Vector3.new(self.min.x+ xsize, self.min.y + ysize, self.min.z+ zsize)

    points[#points + 1] = Vector3.new(self.min.x, self.min.y + ysize, self.min.z+ zsize)
    points[#points + 1] = Vector3.new(self.min.x+ xsize, self.min.y + ysize, self.min.z+ zsize)

    if InFormMatrix then 
        for i = 1, #points do
            points[i] = InFormMatrix * points[i]
        end
    end
    return MeshLines.new(points)
end

function BoundBox:BuildRenderMesh()
    local xsize = self.max.x - self.min.x
    local ysize = self.max.y - self.min.y
    local zsize = self.max.z - self.min.z

    local StartV = Vector3.Copy(self.min)
    local EndV = Vector3.Copy(self.max)

    local Data = {}

    --A +
    Data[#Data + 1] = {StartV.x, StartV.y, StartV.z, 0, 0, 0, 0, 1}
    Data[#Data + 1] = {StartV.x, StartV.y + ysize, StartV.z, 0, 0, 0, 0, 1}
    Data[#Data + 1] = {StartV.x, StartV.y + ysize, StartV.z + zsize, 0, 0, 0, 0, 1}

    Data[#Data + 1] = {StartV.x, StartV.y, StartV.z, 0, 0, 0, 0, 1}
    Data[#Data + 1] = {StartV.x, StartV.y, StartV.z + zsize, 0, 0, 0, 0, 1}
    Data[#Data + 1] = {StartV.x, StartV.y + ysize, StartV.z + zsize, 0, 0, 0, 0, 1}

     --A -
     Data[#Data + 1] = {StartV.x + xsize, StartV.y, StartV.z, 0, 0, 0, 0, 1}
     Data[#Data + 1] = {StartV.x + xsize, StartV.y + ysize, StartV.z, 0, 0, 0, 0, 1}
     Data[#Data + 1] = {StartV.x + xsize, StartV.y + ysize, StartV.z + zsize, 0, 0, 0, 0, 1}
 
     Data[#Data + 1] = {StartV.x + xsize, StartV.y, StartV.z, 0, 0, 0, 0, 1}
     Data[#Data + 1] = {StartV.x + xsize, StartV.y + ysize, StartV.z + zsize, 0, 0, 0, 0, 1}
     Data[#Data + 1] = {StartV.x + xsize, StartV.y, StartV.z + zsize, 0, 0, 0, 0, 1}


    --B +
    Data[#Data + 1] = {StartV.x, StartV.y, StartV.z, 0, 0, 0, 0, 1}
    Data[#Data + 1] = {StartV.x + xsize, StartV.y, StartV.z, 0, 0, 0, 0, 1}
    Data[#Data + 1] = {StartV.x + xsize, StartV.y, StartV.z + zsize, 0, 0, 0, 0, 1}

    Data[#Data + 1] = {StartV.x, StartV.y, StartV.z, 0, 0, 0, 0, 1}
    Data[#Data + 1] = {StartV.x + xsize, StartV.y, StartV.z + zsize, 0, 0, 0, 0, 1}
    Data[#Data + 1] = {StartV.x, StartV.y, StartV.z + zsize, 0, 0, 0, 0, 1}

    --B -
    Data[#Data + 1] = {StartV.x, StartV.y + ysize, StartV.z, 0, 0, 0, 0, 1}
    Data[#Data + 1] = {StartV.x + xsize, StartV.y + ysize, StartV.z, 0, 0, 0, 0, 1}
    Data[#Data + 1] = {StartV.x + xsize, StartV.y + ysize, StartV.z + zsize, 0, 0, 0, 0, 1}

    Data[#Data + 1] = {StartV.x, StartV.y + ysize, StartV.z, 0, 0, 0, 0, 1}
    Data[#Data + 1] = {StartV.x + xsize, StartV.y + ysize, StartV.z + zsize, 0, 0, 0, 0, 1}
    Data[#Data + 1] = {StartV.x, StartV.y + ysize, StartV.z + zsize, 0, 0, 0, 0, 1}

    --C +
    Data[#Data + 1] = {StartV.x, StartV.y, StartV.z, 0, 0, 0, 0, 1}
    Data[#Data + 1] = {StartV.x + xsize, StartV.y, StartV.z, 0, 0, 0, 0, 1}
    Data[#Data + 1] = {StartV.x + xsize, StartV.y + ysize, StartV.z, 0, 0, 0, 0, 1}
    Data[#Data + 1] = {StartV.x, StartV.y, StartV.z, 0, 0, 0, 0, 1}
    Data[#Data + 1] = {StartV.x + xsize, StartV.y + ysize, StartV.z, 0, 0, 0, 0, 1}
    Data[#Data + 1] = {StartV.x , StartV.y + ysize, StartV.z, 0, 0, 0, 0, 1}

    --C -
    Data[#Data + 1] = {StartV.x, StartV.y, StartV.z + zsize, 0, 0, 0, 0, 1}
    Data[#Data + 1] = {StartV.x + xsize, StartV.y, StartV.z + zsize, 0, 0, 0, 0, 1}
    Data[#Data + 1] = {StartV.x + xsize, StartV.y + ysize, StartV.z + zsize, 0, 0, 0, 0, 1}
    Data[#Data + 1] = {StartV.x, StartV.y, StartV.z + zsize, 0, 0, 0, 0, 1}
    Data[#Data + 1] = {StartV.x + xsize, StartV.y + ysize, StartV.z + zsize, 0, 0, 0, 0, 1}
    Data[#Data + 1] = {StartV.x , StartV.y + ysize, StartV.z + zsize, 0, 0, 0, 0, 1}



    return Mesh3D.createFromPoints(Data)
end

function BoundBox:vectorInBox(v )
    return v.x >= self.min.x and v.x <= self.max.x and v.y >= self.min.y and v.y <= self.max.y and v.z >= self.min.z and v.z <= self.max.z;
end

BoundBox.VectorInBox = BoundBox.vectorInBox

function BoundBox:TriangleInBox(triangle )
    return self:VectorInBox(triangle.P1) and self:VectorInBox(triangle.P2) and self:VectorInBox(triangle.P3)
end

function BoundBox:IntersectTriangleSimilar(triangle )
    if self:VectorInBox(triangle.P1) or self:VectorInBox(triangle.P2) or self:VectorInBox(triangle.P3) then
        return true
    end

    local cc = (triangle.P1 + triangle.P2 + triangle.P3) / 3.0
    if self:VectorInBox(triangle.P1) then
        return true
    end

    local c1 = (cc + triangle.P2 + triangle.P3) / 3.0
    local c2 = (cc + triangle.P1 + triangle.P3) / 3.0
    local c3 = (cc + triangle.P1 + triangle.P2) / 3.0

    if self:VectorInBox(c1) or self:VectorInBox(c2) or self:VectorInBox(c3) then
        return true
    end

    return false
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

BoundBox.checkIntersectBox = function(box1, box2)
    local box = BoundBox.new()

    box.min.x = math.max( box1.min.x, box2.min.x );
	box.min.y = math.max( box1.min.y, box2.min.y );
	box.min.z = math.max( box1.min.z, box2.min.z );

	box.max.x = math.min( box1.max.x, box2.max.x );
	box.max.y = math.min( box1.max.y, box2.max.y );
    box.max.z = math.min( box1.max.z, box2.max.z );
    
    if box.min.x > box.max.x or box.min.y > box.max.y or box.min.z > box.max.z then

       return false
    end

    return true
end

BoundBox.copy = function(data)
    local result = BoundBox.new()
    result.min = Vector3.copy(data.min)
    result.max = Vector3.copy(data.max)
    result.center = Vector3.copy(data.center)
    return result
end

function BoundBox:logValueMin(info)
	log('BoundBox min: ' .. tostring(info), self.min.x, self.min.y, self.min.z)
end

function BoundBox:logValueMax(info)
	log('BoundBox max: ' .. tostring(info), self.max.x, self.max.y, self.max.z)
end

_G.OrientedBox = {}
function OrientedBox.new()
    local box = setmetatable({}, {__index = OrientedBox});

    box.vs = {}
    for i = 1, 8 do
        box.vs[i] = Vector3.new()
    end
    return box
end

function OrientedBox:getBoundBox()
    local min = Vector3.new(self.vs[1].x, self.vs[1].y, self.vs[1].z)
    local max = Vector3.new(self.vs[1].x, self.vs[1].y, self.vs[1].z)

    for i = 1, 8 do
        min.x = math.min(self.vs[i].x, min.x)
        min.y = math.min(self.vs[i].y, min.y)
        min.z = math.min(self.vs[i].z, min.z)

        max.x = math.max(self.vs[i].x, max.x)
        max.y = math.max(self.vs[i].y, max.y)
        max.z = math.max(self.vs[i].z, max.z)
    end

    return BoundBox.buildFromMinMax(min, max)
end

function OrientedBox:logCenter(info)
    local center = Vector3.new()
	for i = 1, 8 do
		center.x = center.x +  self.vs[i].x

		center.y = center.y +  self.vs[i].y

		center.z = center.z +  self.vs[i].z
	end
	
	center.x = center.x / 8

	center.y = center.y / 8

	center.z = center.z / 8

	log('OrientedBox center: ' .. tostring(info), center.x, center.y, center.z)
end

function OrientedBox:logValue(info)
    local center = Vector3.new()
	for i = 1, 8 do
		center.x = center.x +  self.vs[i].x

		center.y = center.y +  self.vs[i].y

		center.z = center.z +  self.vs[i].z
        log('OrientedBox value: '.. tostring(i) .. " " .. tostring(info), self.vs[i].x, self.vs[i].y, self.vs[i].z)
	end
	
	center.x = center.x / 8

	center.y = center.y / 8

	center.z = center.z / 8

	log('OrientedBox center: ' .. tostring(info), center.x, center.y, center.z)
end

function OrientedBox:logMaxMin(info)
    local min = self:getMin()
    local max = self:getMax()

    log('OrientedBox max: ' .. tostring(info), max.x, max.y, max.z)
    log('OrientedBox min: ' .. tostring(info), min.x, min.y, min.z)
end

OrientedBox.buildFormMinMax = function( vmin, vmax )
    local box = OrientedBox.new()
	box.vs[1] = Vector3.new( vmin.x, vmin.y, vmin.z );
	box.vs[2] = Vector3.new( vmax.x, vmin.y, vmin.z );
	box.vs[3] = Vector3.new( vmax.x, vmax.y, vmin.z );
	box.vs[4] = Vector3.new( vmin.x, vmax.y, vmin.z  );
	box.vs[5] = Vector3.new( vmin.x, vmin.y, vmax.z );
	box.vs[6] = Vector3.new( vmax.x, vmin.y, vmax.z );
	box.vs[7] = Vector3.new( vmax.x, vmax.y, vmax.z );
	box.vs[8] = Vector3.new( vmin.x, vmax.y, vmax.z );

	return box;
end

OrientedBox.buildFormBoundBox = function( box )
    return OrientedBox.buildFormMinMax(box.min, box.max)
end

function OrientedBox:getMin()
    local value = Vector3.new(self.vs[1].x, self.vs[1].y, self.vs[1].z)
    for i = 1, 8 do
        value.x = math.min(value.x, self.vs[i].x)
        value.y = math.min(value.y, self.vs[i].y)
        value.z = math.min(value.z, self.vs[i].z)
    end
    return value
end

function OrientedBox:getMax()
    local value = Vector3.new(self.vs[1].x, self.vs[1].y, self.vs[1].z)
    for i = 1, 8 do
        value.x = math.max(value.x, self.vs[i].x)
        value.y = math.max(value.y, self.vs[i].y)
        value.z = math.max(value.z, self.vs[i].z)
    end
    return value
end

function OrientedBox.BuildFromCenter_Extents_Aixs(InCenter, InExtents, InAixsX, InAixsY, InAixsZ)
    local obb = OrientedBox.new()
    obb.vs[1] = InCenter + (InAixsX * InExtents.x + InAixsY * InExtents.y + InAixsZ * InExtents.z)
    obb.vs[2] = InCenter + (InAixsX * InExtents.x + InAixsY * -InExtents.y + InAixsZ * InExtents.z)
    obb.vs[3] = InCenter + (InAixsX * -InExtents.x + InAixsY * -InExtents.y + InAixsZ * InExtents.z)
    obb.vs[4] = InCenter + (InAixsX * -InExtents.x + InAixsY * InExtents.y + InAixsZ * InExtents.z)

    obb.vs[5] = InCenter + (InAixsX * InExtents.x + InAixsY * InExtents.y + InAixsZ * -InExtents.z)
    obb.vs[6] = InCenter + (InAixsX * InExtents.x + InAixsY * -InExtents.y + InAixsZ * -InExtents.z)
    obb.vs[7] = InCenter + (InAixsX * -InExtents.x + InAixsY * -InExtents.y + InAixsZ * -InExtents.z)
    obb.vs[8] = InCenter + (InAixsX * -InExtents.x + InAixsY * InExtents.y + InAixsZ * -InExtents.z)

    return obb
end
function OrientedBox:buildMeshLines()
    local _VS = self.vs

    local points = {}
    points[#points + 1] = _VS[1]
    points[#points + 1] = _VS[2]

    points[#points + 1] = _VS[2]
    points[#points + 1] = _VS[3]

    points[#points + 1] = _VS[3]
    points[#points + 1] = _VS[4]

    points[#points + 1] = _VS[4]
    points[#points + 1] = _VS[1]

    points[#points + 1] = _VS[5]
    points[#points + 1] = _VS[6]

    points[#points + 1] = _VS[6]
    points[#points + 1] = _VS[7]

    points[#points + 1] = _VS[7]
    points[#points + 1] = _VS[8]

    points[#points + 1] = _VS[8]
    points[#points + 1] = _VS[5]

    points[#points + 1] = _VS[1]
    points[#points + 1] = _VS[5]

    points[#points + 1] = _VS[2]
    points[#points + 1] = _VS[6]

    points[#points + 1] = _VS[3]
    points[#points + 1] = _VS[7]

    points[#points + 1] = _VS[4]
    points[#points + 1] = _VS[8]

    return MeshLines.new(points)
end
