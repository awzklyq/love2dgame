_G.Frustum = {}
function Frustum.new()
    local frustum = setmetatable({}, {__index = Frustum});

	frustum.vs = {}
	for i = 1, 8 do
		frustum.vs[i] = Vector3.new(0 ,0, 0)
	end

	frustum.ps = {}
	for i = 1, 6 do
		frustum.ps[i] = Plane.new()
	end

	frustum.pv = Matrix3D.new()--TODO..

	frustum.planeNormX = {}
	frustum.planeNormY = {}
	frustum.planeNormZ = {}

	frustum.planeNormAbsX = {}
	frustum.planeNormAbsY = {}
	frustum.planeNormAbsZ = {}

	frustum.planeOffsetVec = {}

	for i = 1, 2 do
		frustum.planeNormX[i] = Vector3.new()
		frustum.planeNormY[i] = Vector3.new()
		frustum.planeNormZ[i] = Vector3.new()

		frustum.planeNormAbsX[i] = Vector3.new()
		frustum.planeNormAbsY[i] = Vector3.new()
		frustum.planeNormAbsZ[i] = Vector3.new()

		frustum.planeOffsetVec[i] = Vector3.new()
	end

	frustum.renderid = Render.FrustumId
    return frustum
end

function Frustum.copy(frustum)
	local f = Frustum.new()
	for i = 1, 8 do
		local v = frustum.vs[i]
		f.vs[i] = Vector3.new(v.x , v.y, v.z)
	end

	for i = 1, 6 do
		local p = frustum.ps[i]
		f.ps[i] = Plane.new(p.a, p.b, p.c, p.d)
	end

	f.pv = Matrix3D.copy(frustum.pv)
	return f
end

function Frustum:draw()
	if not self.meshlines then
		self.meshlines = {}
		for i = 1, 8 do
			self.meshlines[i] = MeshLine.new(Vector3.new(), Vector3.new())
		end
	end

	for i = 1, 7 do
		local meshline = self.meshlines[i]
		meshline:setStart(self.vs[i].x, self.vs[i].y, self.vs[i].z)
		meshline:setEnd(self.vs[i + 1].x, self.vs[i + 1].y, self.vs[i + 1].z)
	end

	RenderSet.pushViewMatrix(Matrix3D.inverse(RenderSet.getDefaultProjectMatrix()))
	RenderSet.pushProjectMatrix(Matrix3D.inverse(RenderSet.getDefaultViewMatrix()))
	self.meshlines[8]:setStart(self.vs[8].x, self.vs[8].y, self.vs[8].z)
	self.meshlines[8]:setEnd(self.vs[1].x, self.vs[1].y, self.vs[1].z)
	RenderSet.popViewMatrix()
	RenderSet.popProjectMatrix()

	for i = 1, 8 do
		self.meshlines[i]:draw()
	end

end

function Frustum:buildDrawLinesFromFrustum()

	local lines = {}
	lines[#lines +1] = self.vs[1]
	lines[#lines +1] = self.vs[2]

	lines[#lines +1] = self.vs[1]
	lines[#lines +1] = self.vs[4]

	lines[#lines +1] = self.vs[3]
	lines[#lines +1] = self.vs[4]

	lines[#lines +1] = self.vs[3]
	lines[#lines +1] = self.vs[2]

	lines[#lines +1] = self.vs[1]
	lines[#lines +1] = self.vs[5]

	lines[#lines +1] = self.vs[2]
	lines[#lines +1] = self.vs[6]

	lines[#lines +1] = self.vs[7]
	lines[#lines +1] = self.vs[3]

	lines[#lines +1] = self.vs[4]
	lines[#lines +1] = self.vs[8]

	lines[#lines +1] = self.vs[5]
	lines[#lines +1] = self.vs[6]

	lines[#lines +1] = self.vs[5]
	lines[#lines +1] = self.vs[8]

	lines[#lines +1] = self.vs[7]
	lines[#lines +1] = self.vs[6]

	lines[#lines +1] = self.vs[7]
	lines[#lines +1] = self.vs[8]
	

	local meshlines = MeshLines.new(lines);
	meshlines:setBGColor(LColor.new(255, 0, 0, 255))
	return meshlines
end

function Frustum.buildDrawLines(camera3d)

	local FrustumAngle = camera3d.fov
	local FrustumAspectRatio = camera3d.aspectRatio
	local FrustumStartDist = camera3d.nearClip
	local FrustumEndDist = camera3d.farClip

	local Direction = Vector3.sub(camera3d.look, camera3d.eye):normalize()--Vector3.new(1,0,0);--Vector3.sub(camera3d.look,camera3d.eye):normalize()
	
	local UpVector = Vector3.new(-camera3d.up.x, -camera3d.up.y, -camera3d.up.z):normalize()--Vector3.new(0,0,1);--camera3d.up
	local LeftVector = Vector3.cross(Direction, UpVector):normalize();

	local Verts = {}
	for i = 1, 8 do
		Verts[i] = Vector3.new()
	end
	
	-- FOVAngle controls the horizontal angle.
	local HozHalfAngleInRadians = FrustumAngle * 0.5--math.rad(FrustumAngle * 0.5);

	local HozLength = 0.0;
	local VertLength = 0.0;
		
	if (FrustumAngle > 0.0) then
		HozLength = FrustumStartDist * math.tan(HozHalfAngleInRadians);
		VertLength = HozLength / FrustumAspectRatio;
	else
		local OrthoWidth = (FrustumAngle == 0.0) and 1000.0 or -FrustumAngle;
		HozLength = OrthoWidth * 0.5;
		VertLength = HozLength / FrustumAspectRatio;
	end
 
	-- near plane verts
	-- Verts[1] = Vector3.add(Vector3.add(Vector3.mul(Direction, FrustumStartDist), Vector3.mul(UpVector, VertLength)) ,Vector3.mul(LeftVector ,HozLength));
	-- Verts[2] = Vector3.sub(Vector3.add(Vector3.mul(Direction, FrustumStartDist) , Vector3.mul(UpVector, VertLength)) , Vector3.mul(LeftVector , HozLength));
	-- Verts[3] = Vector3.sub(Vector3.sub(Vector3.mul(Direction, FrustumStartDist), Vector3.mul(UpVector, VertLength)) , Vector3.mul(LeftVector , HozLength));
	-- Verts[4] =   Vector3.add(Vector3.sub(Vector3.mul(Direction, FrustumStartDist) , Vector3.mul(UpVector, VertLength)) , Vector3.mul(LeftVector , HozLength));

	-- // near plane verts
	Verts[1] = (Direction * FrustumStartDist) + (UpVector * VertLength) + (LeftVector * HozLength);
	Verts[2] = (Direction * FrustumStartDist) + (UpVector * VertLength) - (LeftVector * HozLength);
	Verts[3] = (Direction * FrustumStartDist) - (UpVector * VertLength) - (LeftVector * HozLength);
	Verts[4] = (Direction * FrustumStartDist) - (UpVector * VertLength) + (LeftVector * HozLength);

	if FrustumAngle > 0.0 then
		HozLength = FrustumEndDist * math.tan(HozHalfAngleInRadians);
		VertLength = HozLength / FrustumAspectRatio;
	end

	-- far plane verts
	-- Verts[5] = Vector3.add(Vector3.add(Vector3.mul(Direction , FrustumEndDist) , Vector3.mul(UpVector , VertLength)) ,Vector3.mul(LeftVector , HozLength));
	-- Verts[6] = Vector3.sub(Vector3.add(Vector3.mul(Direction , FrustumEndDist), Vector3.mul(UpVector , VertLength)) , Vector3.mul(LeftVector , HozLength));
	-- Verts[7] = Vector3.sub(Vector3.sub(Vector3.mul(Direction , FrustumEndDist), Vector3.mul(UpVector , VertLength)), Vector3.mul(LeftVector , HozLength))
	-- Verts[8] =Vector3.add(Vector3.sub( Vector3.mul(Direction , FrustumEndDist), Vector3.mul(UpVector , VertLength)), Vector3.mul(LeftVector , HozLength))

	-- far plane verts
	Verts[5] = (Direction * FrustumEndDist) + (UpVector * VertLength) + (LeftVector * HozLength);
	Verts[6] = (Direction * FrustumEndDist) + (UpVector * VertLength) - (LeftVector * HozLength);
	Verts[7] = (Direction * FrustumEndDist) - (UpVector * VertLength) - (LeftVector * HozLength);
	Verts[8] = (Direction * FrustumEndDist) - (UpVector * VertLength) + (LeftVector * HozLength);

	-- local mat = Matrix3D.createLookAtLH( camera3d.eye, camera3d.look, Vector3.negative(camera3d.up) )
	-- mat = Matrix3D.transpose(mat)
	for i = 1, 8 do
		-- Verts[i] = mat:mulVector(Verts[i])
		Verts[i] = Vector3.add(Verts[i], camera3d.eye)
	end

	local lines = {}
	lines[#lines +1] = Verts[1]
	lines[#lines +1] = Verts[2]

	lines[#lines +1] = Verts[1]
	lines[#lines +1] = Verts[4]

	lines[#lines +1] = Verts[3]
	lines[#lines +1] = Verts[4]

	lines[#lines +1] = Verts[3]
	lines[#lines +1] = Verts[2]

	lines[#lines +1] = Verts[1]
	lines[#lines +1] = Verts[5]

	lines[#lines +1] = Verts[2]
	lines[#lines +1] = Verts[6]

	lines[#lines +1] = Verts[7]
	lines[#lines +1] = Verts[3]

	lines[#lines +1] = Verts[4]
	lines[#lines +1] = Verts[8]

	lines[#lines +1] = Verts[5]
	lines[#lines +1] = Verts[6]

	lines[#lines +1] = Verts[5]
	lines[#lines +1] = Verts[8]

	lines[#lines +1] = Verts[7]
	lines[#lines +1] = Verts[6]

	lines[#lines +1] = Verts[7]
	lines[#lines +1] = Verts[8]
	

	local meshlines = MeshLines.new(lines);
	meshlines:setBGColor(LColor.new(255, 0, 0, 255))
	return meshlines
end

function Frustum:insidePosition(pos)
	local pp = Vector4.new(pos.x, pos.y, pos.z, 1)
	pp:mulMatrix(self.pv)

	local resuilt = {0,0,0,0,0,0}
	local needcull = false
	if pp.x < -pp.w then
		resuilt[1] = 1
		needcull = true
	end

	if pp.x > pp.w then
		resuilt[2] = 1
		needcull = true
	end

	if pp.y < -pp.w then
		resuilt[3] = 1
		needcull = true
	end

	if pp.y > pp.w then
		resuilt[4] = 1
		needcull = true
	end

	if pp.z < -pp.w then
		resuilt[5] = 1
		needcull = true
	end

	if pp.z > pp.w then
		resuilt[6] = 1
		needcull = true
	end

	return needcull, resuilt
end

function Frustum:insidePoint(pp)
	-- local pp = Vector4.new(p.x, p.y, p.z, 1)
	-- pp:mulMatrix(self.pv)

	local resuilt = {0,0,0,0,0,0}
	local needcull = false
	if pp.x < -pp.w then
		resuilt[1] = 1
		needcull = true
	end

	if pp.x > pp.w then
		resuilt[2] = 1
		needcull = true
	end

	if pp.y < -pp.w then
		resuilt[3] = 1
		needcull = true
	end

	if pp.y > pp.w then
		resuilt[4] = 1
		needcull = true
	end

	if pp.z < -pp.w then
		resuilt[5] = 1
		needcull = true
	end

	if pp.z > pp.w then
		resuilt[6] = 1
		needcull = true
	end

	return needcull, resuilt
end

function Frustum:insideBox( box )

	if RenderSet.isNeedFrustum == false then
		return true
	end
	-- box = self.pv:mulBoundBox(box)
	local center = (box.max + box.min) * 0.5;
    local extent = (box.max - box.min) * 0.5;

	-- TODO, use sse.
	local vmin = Vector3.new();

	for i = 1, 6 do
		-- X axis.
		vmin.x = self.ps[i].a > 0.0 and  box.min.x or box.max.x;

		-- Y axis.
		vmin.y = self.ps[i].b > 0.0 and box.min.y or box.max.y;

		-- Z axis.
		vmin.z = self.ps[i].c > 0.0 and box.min.z or box.max.z;

		if ( self.ps[i]:distance( vmin ) > 0 ) then
			return false;
		end
	end

	return  true
end

function Frustum:insideOrientedBox(box )
	local result = {0, 0, 0, 0, 0, 0, 0, 0}

	for i = 1, 8 do
		local isinside = true
		for j = 1, 6 do
			
			if ( self.ps[j]:distance( box.vs[i] ) > 0.0 ) then

			-- log('aaaaaaaaaaaaaaaaa', i, self.ps[j]:getName(), self.ps[j]:distance( box.vs[i] ) > 0.0 ,self.ps[j]:distance( box.vs[i] ), self.ps[j].d)
			-- 	log('bbbbbbbbbbbbb', "plane", self.ps[j].a, self.ps[j].b, self.ps[j].c)
			-- 	log('ccccccccccccccc', box.vs[i].x, box.vs[i].y, box.vs[i].z )
				result[i] = result[i] + 1;
				isinside = false
			end
		
		end

		if isinside then
			return true
		end
	end

	for i = 1, 8 do
		if result[i]  == 6 then
			return false
		end
	end
	return true
end

function Frustum:buildFromViewAndProject( view, proj )

	--TODO..
	local V = RenderSet.getCameraFrustumViewMatrix()
	local P = RenderSet.getCameraFrustumProjectMatrix()
	-- local V = RenderSet.getDefaultViewMatrix()
	-- local P = RenderSet.getDefaultProjectMatrix()

	self.pv = Matrix3D.copy(V)--getCameraFrustumProjectMatrix
	self.pv:mulRight(P);

	-- -- TODO, use sse.
	-- local viewcopy = Matrix3D.copy(view)
	-- viewcopy:mulRight(proj);
	local vp = Matrix3D.inverse( self.pv );
	-- vp:transposeSelf()
	self.vs[1] = vp:mulVector(Vector3.new( -1.0, -1.0, 0.0 ));
	self.vs[2] = vp:mulVector(Vector3.new( -1.0,  1.0, 0.0 ));
	self.vs[3] = vp:mulVector(Vector3.new(  1.0,  1.0, 0.0 ));
	self.vs[4] = vp:mulVector(Vector3.new(  1.0, -1.0, 0.0 ));
	self.vs[5] = vp:mulVector(Vector3.new( -1.0, -1.0, 1.0 ));
	self.vs[6] = vp:mulVector(Vector3.new( -1.0,  1.0, 1.0 ));
	self.vs[7] = vp:mulVector(Vector3.new(  1.0,  1.0, 1.0 ));
	self.vs[8] = vp:mulVector(Vector3.new(  1.0, -1.0, 1.0 ));

	-- for i = 1, 8 do
	-- 	log('box i', i, self.vs[i].x, self.vs[i].y, self.vs[i].z)
	-- end

	-- log("box 1-4 distance", Vector3.distance(self.vs[1], self.vs[2]), Vector3.distance(self.vs[1], self.vs[3]), Vector3.distance(self.vs[1], self.vs[4]))

	-- log("box 5-6 distance", Vector3.distance(self.vs[5], self.vs[6]), Vector3.distance(self.vs[5], self.vs[7]), Vector3.distance(self.vs[5], self.vs[8]))

	-- log("box 1-5 distance", Vector3.distance((self.vs[1] + self.vs[2] +self.vs[3] + self.vs[4]) / 4, (self.vs[5] + self.vs[6] + self.vs[7] + self.vs[8]) / 4), Vector3.distance(self.vs[1], self.vs[5]))

	-- local camera3d = _G.getGlobalCamera3D()
	-- log("eye:", camera3d.eye.x, camera3d.eye.y, camera3d.eye.z)
	-- log("look:", camera3d.look.x, camera3d.look.y, camera3d.look.z)
	-- log("fov: ", camera3d.fov, "aspectRatio:",camera3d.aspectRatio, "nearClip", camera3d.nearClip, "farClip:", camera3d.farClip)

	-- self.vs[1] = (Vector3.new( -300.0, -300.0, -300.0 ));
	-- self.vs[2] = (Vector3.new( 300.0,  -300.0, -300.0 ));
	-- self.vs[3] = (Vector3.new(  300.0,  300.0, -300.0 ));
	-- self.vs[4] = (Vector3.new(  -300.0, 300.0, -300.0 ));
	-- self.vs[5] = (Vector3.new( -300.0, -300.0, 300.0 ));
	-- self.vs[6] = (Vector3.new( 300.0,  -300.0, 300.0 ));
	-- self.vs[7] = (Vector3.new(  300.0,  300.0, 300.0 ));
	-- self.vs[8] = (Vector3.new(  -300.0, 300.0, 300.0 ));

	self.ps[1].name = 'Near'
	self.ps[2].name = 'Far'
	self.ps[3].name = 'Left'
	self.ps[4].name = 'Right'
	self.ps[5].name = 'Top'
	self.ps[6].name = 'Bottom'

	self.ps[1]:buildFromThreePoints( self.vs[1], self.vs[2], self.vs[3] ); -- Near
	self.ps[2]:buildFromThreePoints( self.vs[6], self.vs[8], self.vs[7] ); -- Far
	self.ps[3]:buildFromThreePoints( self.vs[2], self.vs[5], self.vs[6] ); -- Left

	self.ps[4]:buildFromThreePoints( self.vs[7], self.vs[8], self.vs[3] ); -- Right	
	self.ps[5]:buildFromThreePoints( self.vs[2], self.vs[6], self.vs[3] ); -- Top
	self.ps[6]:buildFromThreePoints( self.vs[4], self.vs[5], self.vs[1] ); -- Bottom


end

function Frustum:buildFromOrientedBox(box )
	for  i = 1, 8 do
		self.vs[i] = box.vs[i];
		log("box i :", i, self.vs[i].x, self.vs[i].y, self.vs[i].z)
	end

	self.ps[1].name = 'Near'
	self.ps[2].name = 'Far'
	self.ps[3].name = 'Left'
	self.ps[4].name = 'Right'
	self.ps[5].name = 'Top'
	self.ps[6].name = 'Bottom'

	self.ps[1]:buildFromThreePoints( self.vs[1], self.vs[2], self.vs[3] ); -- Near

	self.ps[2]:buildFromThreePoints( self.vs[6], self.vs[8], self.vs[7] ); -- Far

	self.ps[3]:buildFromThreePoints( self.vs[2], self.vs[5], self.vs[6] ); -- Left

	self.ps[4]:buildFromThreePoints( self.vs[7], self.vs[8], self.vs[3] ); -- Right	

	self.ps[5]:buildFromThreePoints( self.vs[2], self.vs[6], self.vs[3] ); -- Top
	self.ps[6]:buildFromThreePoints( self.vs[4], self.vs[5], self.vs[1] ); -- Bottom

	return self;
end
