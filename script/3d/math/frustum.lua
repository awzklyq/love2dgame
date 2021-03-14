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

	return MeshLines.new(lines)
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
	box = self.pv:mulBoundBox(box)
	local center = (box.max + box.min) * 0.5;
    local extent = (box.max - box.min) * 0.5;

    -- This is a vertical dot-product on three vectors at once.
    local d0  = self.planeNormX[1] * center.x 
                + self.planeNormY[1] * center.y 
                + self.planeNormZ[1] * center.z
                - self.planeNormAbsX[1] * extent.x 
                - self.planeNormAbsY[1] * extent.y 
				- self.planeNormAbsZ[1] * extent.z 
				-- - extent
                - self.planeOffsetVec[1];

	if d0.x >= 0 or d0.y >= 0 or d0.z >= 0 then
		return false;
	end

    local d1  = self.planeNormX[2] * center.x 
                + self.planeNormY[2] * center.y 
                + self.planeNormZ[2] * center.z
                - self.planeNormAbsX[2] * extent.x 
                - self.planeNormAbsY[2] * extent.y 
				- self.planeNormAbsZ[2] * extent.z 
				-- -extent
                - self.planeOffsetVec[2];

	if d1.x >= 0 or d1.y >= 0 or d1.z >= 0 then
		return false;
	end

	return true;
	
	-- TODO, use sse.
	-- box = self.pv:mulBoundBox(box)

	-- local vmin = Vector3.new();

	-- for i = 1, 6 do
	-- 	-- X axis.
	-- 	vmin.x = self.ps[i].a > 0.0 and  box.min.x or box.max.x;

	-- 	-- Y axis.
	-- 	vmin.y = self.ps[i].b > 0.0 and box.min.y or box.max.y;

	-- 	-- Z axis.
	-- 	vmin.z = self.ps[i].c > 0.0 and box.min.z or box.max.z;

	-- 	if ( self.ps[i]:distance( vmin ) > 0 ) then
	-- 		return false;
	-- 	end
	-- end

	-- return  true

	-- local vmin = Vector4.new(box.min.x, box.min.y, box.min.z, 1)
	-- local vmax = Vector4.new(box.max.x, box.max.y, box.max.z, 1)

	-- vmin = vmin:mulMatrix(self.pv)
	-- vmax = vmax:mulMatrix(self.pv)

	-- local obox = OrientedBox.buildFormBoundBox(box)
	-- local rs = {}
	-- local needcull = false
	-- needcull, rs[1] = self:insidePoint(vmin)
	-- if needcull == false then
	-- 	return false
	-- end

	-- needcull, rs[2] = self:insidePoint(vmin)
	-- if needcull == false then
	-- 	return false
	-- end

	-- if rs[1] == 1 or  rs[2] == 1 

	-- local vs = {}
	-- for i = 1, 8 do
	-- 	vs[i] = Vector4.new(obox.vs[i].x, obox.vs[i].y, obox.vs[i].z, 1)	
	-- 	vs[i] = vs[i]:mulMatrix(self.pv)
	-- 	needcull, rs[i] = self:insidePoint(vs[i])
	-- 	if needcull == false then
	-- 		return false
	-- 	end
	-- end


    -- return true;
    
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

	--TODO..
	local M = RenderSet.getCameraFrustumViewMatrix()
	local P = RenderSet.getCameraFrustumProjectMatrix()
	-- local M = RenderSet.getDefaultViewMatrix()
	-- local P = RenderSet.getDefaultProjectMatrix()

	self.pv = Matrix3D.copy(P)--getCameraFrustumProjectMatrix
	self.pv:mulRight(M);

	-- -- TODO, use sse.
	-- local viewcopy = Matrix3D.copy(view)
	-- viewcopy:mulRight(proj);
	local vp = self.pv--Matrix3D.inverse( self.pv );
	-- -- vp:transposeSelf()
	self.vs[1] = vp:mulVector(Vector3.new( -1.0, -1.0, 0.0 ));
	self.vs[2] = vp:mulVector(Vector3.new( -1.0,  1.0, 0.0 ));
	self.vs[3] = vp:mulVector(Vector3.new(  1.0,  1.0, 0.0 ));
	self.vs[4] = vp:mulVector(Vector3.new(  1.0, -1.0, 0.0 ));
	self.vs[5] = vp:mulVector(Vector3.new( -1.0, -1.0, 1.0 ));
	self.vs[6] = vp:mulVector(Vector3.new( -1.0,  1.0, 1.0 ));
	self.vs[7] = vp:mulVector(Vector3.new(  1.0,  1.0, 1.0 ));
	self.vs[8] = vp:mulVector(Vector3.new(  1.0, -1.0, 1.0 ));

	self.ps[1]:buildFromThreePoints( self.vs[2], self.vs[6], self.vs[3] ); -- Top
	self.ps[2]:buildFromThreePoints( self.vs[7], self.vs[8], self.vs[3] ); -- Right
	self.ps[3]:buildFromThreePoints( self.vs[4], self.vs[5], self.vs[1] ); -- Bottom

	self.ps[4]:buildFromThreePoints( self.vs[2], self.vs[5], self.vs[6] ); -- Left
	self.ps[5]:buildFromThreePoints( self.vs[1], self.vs[2], self.vs[3] ); -- Near
	self.ps[6]:buildFromThreePoints( self.vs[6], self.vs[8], self.vs[7] ); -- Far

	-- local two = 2;
	-- local camera3d = _G.getGlobalCamera3D()

	-- local fovx = camera3d.fov
	-- local aspect = camera3d.aspectRatio
	-- local nearPlane = camera3d.nearClip
	-- local farPlane = camera3d.farClip

    -- local _right    = nearPlane * math.tan(fovx / two);
	-- local _left     = -_right;
	-- local _top      = ((_right - _left) / aspect) / two;
	-- local _bottom   = -_top;
   
    -- local _nearPlane    = nearPlane;
	-- local _farPlane     = farPlane;

	
	-- local a = M:mulVector(Vector3.new( _left,  _bottom, -_nearPlane));
    -- local b = M:mulVector(Vector3.new( _left,  _top,    -_nearPlane));
    -- local c = M:mulVector(Vector3.new( _right, _top,    -_nearPlane));
	-- local d = M:mulVector(Vector3.new( _right, _bottom, -_nearPlane));
	
	
	-- local s    = _farPlane / _nearPlane
	-- local farLeft   = s * _left
	-- local farRight  = s * _right
	-- local farTop    = s * _top
	-- local farBottom = s * _bottom
	-- local e   = M:mulVector(Vector3.new( farLeft,  farBottom, -_farPlane));
	-- local f   = M:mulVector(Vector3.new( farLeft,  farTop,    -_farPlane));
	-- local g   = M:mulVector(Vector3.new( farRight, farTop,    -_farPlane));
	-- local o   = M:mulVector(Vector3.new(0,0,0));
	-- self.ps[1]:buildFromThreePoints( o, c, b );
	-- self.ps[2]:buildFromThreePoints( o, d, c );
	-- self.ps[3]:buildFromThreePoints( o, a, d );
	-- self.ps[4]:buildFromThreePoints( o, b, a );
	-- self.ps[5]:buildFromThreePoints( a, d, c );
	-- self.ps[6]:buildFromThreePoints( e, f, g );
	
	-- local a = Vector3.new( _left,  _bottom, -_nearPlane);
	-- local b = Vector3.new( _left,  _top,    -_nearPlane);
	-- local c = Vector3.new( _right, _top,    -_nearPlane);
	-- local d = Vector3.new( _right, _bottom, -_nearPlane);
	-- local o = Vector3.new(0,0,0);

	-- self.ps[1] = Plane.buildFromPoints( o, c, b );
	-- self.ps[2] = Plane.buildFromPoints( o, d, c );
	-- self.ps[3] = Plane.buildFromPoints( o, a, d );
	-- self.ps[4] = Plane.buildFromPoints( o, b, a );
	-- self.ps[5] = Plane.new( 0, 0, 1, -_nearPlane );
	-- self.ps[6] = Plane.new( 0, 0,-1, _farPlane );

	for i = 1, 2 do
		local index = (i - 1) * 3 + 1
		self.planeNormX[i] = Vector3.new(self.ps[index].a, self.ps[index + 1].a, self.ps[index + 2].a)
		self.planeNormY[i] = Vector3.new(self.ps[index].b, self.ps[index + 1].b, self.ps[index + 2].b)
		self.planeNormZ[i] = Vector3.new(self.ps[index].c, self.ps[index + 1].c, self.ps[index + 2].c)

		self.planeNormAbsX[i] = Vector3.new(math.abs(self.ps[index].a), math.abs(self.ps[index + 1].a), math.abs(self.ps[index + 2].a))
		self.planeNormAbsY[i] = Vector3.new(math.abs(self.ps[index].b), math.abs(self.ps[index + 1].b), math.abs(self.ps[index + 2].b))
		self.planeNormAbsZ[i] = Vector3.new(math.abs(self.ps[index].c), math.abs(self.ps[index + 1].c), math.abs(self.ps[index + 2].c))

		self.planeOffsetVec[i] = Vector3.new(math.abs(self.ps[index].d), math.abs(self.ps[index + 1].d), math.abs(self.ps[index + 2].d))
	end
end