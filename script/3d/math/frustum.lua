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
	Verts[1] = Vector3.add(Vector3.add(Vector3.mul(Direction, FrustumStartDist), Vector3.mul(UpVector, VertLength)) ,Vector3.mul(LeftVector ,HozLength));
	Verts[2] = Vector3.sub(Vector3.add(Vector3.mul(Direction, FrustumStartDist) , Vector3.mul(UpVector, VertLength)) , Vector3.mul(LeftVector , HozLength));
	Verts[3] = Vector3.sub(Vector3.sub(Vector3.mul(Direction, FrustumStartDist), Vector3.mul(UpVector, VertLength)) , Vector3.mul(LeftVector , HozLength));
	Verts[4] =   Vector3.add(Vector3.sub(Vector3.mul(Direction, FrustumStartDist) , Vector3.mul(UpVector, VertLength)) , Vector3.mul(LeftVector , HozLength));

	-- // near plane verts
	-- Verts[0] = (Direction * FrustumStartDist) + (UpVector * VertLength) + (LeftVector * HozLength);
	-- Verts[1] = (Direction * FrustumStartDist) + (UpVector * VertLength) - (LeftVector * HozLength);
	-- Verts[2] = (Direction * FrustumStartDist) - (UpVector * VertLength) - (LeftVector * HozLength);
	-- Verts[3] = (Direction * FrustumStartDist) - (UpVector * VertLength) + (LeftVector * HozLength);

	if FrustumAngle > 0.0 then
		HozLength = FrustumEndDist * math.tan(HozHalfAngleInRadians);
		VertLength = HozLength / FrustumAspectRatio;
	end

	-- far plane verts
	Verts[5] = Vector3.add(Vector3.add(Vector3.mul(Direction , FrustumEndDist) , Vector3.mul(UpVector , VertLength)) ,Vector3.mul(LeftVector , HozLength));
	Verts[6] = Vector3.sub(Vector3.add(Vector3.mul(Direction , FrustumEndDist), Vector3.mul(UpVector , VertLength)) , Vector3.mul(LeftVector , HozLength));
	Verts[7] = Vector3.sub(Vector3.sub(Vector3.mul(Direction , FrustumEndDist), Vector3.mul(UpVector , VertLength)), Vector3.mul(LeftVector , HozLength))
	Verts[8] =Vector3.add(Vector3.sub( Vector3.mul(Direction , FrustumEndDist), Vector3.mul(UpVector , VertLength)), Vector3.mul(LeftVector , HozLength))

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
	lines[#lines +1] = Verts[2]

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

	return MeshLines.new(lines)
end

function Frustum:insideBox( box )

	-- TODO, use sse.

	local vmin = Vector3.new();

	for i = 1, 6 do
		-- X axis.
		vmin.x = self.ps[i].a > 0.0 and  box.min.x or box.max.x;

		-- Y axis.
		vmin.y = self.ps[i].b > 0.0 and box.min.y or box.max.y;

		-- Z axis.
		vmin.z = self.ps[i].c > 0.0 and box.min.z or box.max.z;

		if ( self.ps[i]:distance( vmin ) > 0.0 ) then
			return false;
		end
	end
    return true;
    
    -- Vector3 vmin;

	-- for ( _dword i = 0; i < 6; i ++ )
	-- {
	-- 	-- X axis.
	-- 	vmin.x = ps[i].a > 0.0f ? box.vmin.x : box.vmax.x;

	-- 	-- Y axis.
	-- 	vmin.y = ps[i].b > 0.0f ? box.vmin.y : box.vmax.y;

	-- 	-- Z axis.
	-- 	vmin.z = ps[i].c > 0.0f ? box.vmin.z : box.vmax.z;

	-- 	if ( ps[i].Distance( vmin ) > 0.0f )
	-- 		return _false;
	-- }

	-- return _true;
end

function Frustum:buildFromViewAndProject( view, proj )
	-- TODO, use sse.
	local viewcopy = Matrix3D.copy(view)
	viewcopy:mulRight(proj);
	vp = Matrix3D.inverse( viewcopy );
	-- vp:transposeSelf()
	self.vs[1] = vp:mulVector(Vector3.new( -1.0, -1.0, 0.0 ));
	self.vs[2] = vp:mulVector(Vector3.new( -1.0,  1.0, 0.0 ));
	self.vs[3] = vp:mulVector(Vector3.new(  1.0,  1.0, 0.0 ));
	self.vs[4] = vp:mulVector(Vector3.new(  1.0, -1.0, 0.0 ));
	self.vs[5] = vp:mulVector(Vector3.new( -1.0, -1.0, 1.0 ));
	self.vs[6] = vp:mulVector(Vector3.new( -1.0,  1.0, 1.0 ));
	self.vs[7] = vp:mulVector(Vector3.new(  1.0,  1.0, 1.0 ));
	self.vs[8] = vp:mulVector(Vector3.new(  1.0, -1.0, 1.0 ));

	self.ps[1]:buildFromThreePoints( self.vs[1], self.vs[2], self.vs[3] ); -- Near
	self.ps[2]:buildFromThreePoints( self.vs[6], self.vs[8], self.vs[7] ); -- Far
	self.ps[3]:buildFromThreePoints( self.vs[2], self.vs[5], self.vs[6] ); -- Left
	self.ps[4]:buildFromThreePoints( self.vs[7], self.vs[8], self.vs[3] ); -- Right
	self.ps[5]:buildFromThreePoints( self.vs[2], self.vs[6], self.vs[3] ); -- Top
	self.ps[6]:buildFromThreePoints( self.vs[4], self.vs[5], self.vs[1] ); -- Bottom

	-- Matrix4 vp = view * proj;
	-- vp.Inverse( );

	-- vs[0] = Vector3( -1.0f, -1.0f, 0.0f ) * vp;
	-- vs[1] = Vector3( -1.0f,  1.0f, 0.0f ) * vp;
	-- vs[2] = Vector3(  1.0f,  1.0f, 0.0f ) * vp;
	-- vs[3] = Vector3(  1.0f, -1.0f, 0.0f ) * vp;
	-- vs[4] = Vector3( -1.0f, -1.0f, 1.0f ) * vp;
	-- vs[5] = Vector3( -1.0f,  1.0f, 1.0f ) * vp;
	-- vs[6] = Vector3(  1.0f,  1.0f, 1.0f ) * vp;
	-- vs[7] = Vector3(  1.0f, -1.0f, 1.0f ) * vp;

	-- ps[0] = Plane( vs[0], vs[1], vs[2] ); // Near
	-- ps[1] = Plane( vs[5], vs[7], vs[6] ); // Far
	-- ps[2] = Plane( vs[1], vs[4], vs[5] ); // Left
	-- ps[3] = Plane( vs[6], vs[7], vs[2] ); // Right
	-- ps[4] = Plane( vs[1], vs[5], vs[2] ); // Top
	-- ps[5] = Plane( vs[3], vs[4], vs[0] ); // Bottom
end