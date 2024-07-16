_G.Ray = {}

function Ray.new(orig, dir)
    local ray = setmetatable({}, {__index = Ray});

    ray.orig = orig or Vector3.new();
	ray.dir = dir or Vector3.new();

	ray.dir:normalize()

	ray.renderid = Render.RayId
    ray.name = 'ray'

    return ray
end

function Ray.BuildFromScreen(x, y)
	local xx = 2.0 * x / RenderSet.screenwidth - 1.0-- / RenderSet.screenwidth + 0.5
	local yy =  2.0 * y / RenderSet.screenheight - 1.0-- / RenderSet.screenheight + 0.5
	return Ray.BuildFromViewTransform(xx, yy,  RenderSet.getUseViewMatrix(), RenderSet.getUseProjectMatrix())
end

function Ray.BuildFromViewTransform(x, y, viewtrans, projtrans)
	local v = Matrix3D.copy(viewtrans)
	v = v:inverse()

	local temp = Vector3.new(-x / projtrans:getMatrixXY(1,1), -y / projtrans:getMatrixXY(2,2), 1.0)

	local orig = Vector3.new()
	orig.x = v:getMatrixXY(4, 1)
	orig.y = v:getMatrixXY(4, 2)
	orig.z = v:getMatrixXY(4, 3)
	-- orig:Log('orig')
	-- local camera3d = _G.getGlobalCamera3D()
	-- camera3d.eye:Log('eye')

	local dir = Vector3.new() 
	dir.x	= temp.x * v:getMatrixXY( 1, 1 ) + temp.y * v:getMatrixXY( 2, 1 ) + temp.z * v:getMatrixXY( 3, 1 );
	dir.y	= temp.x * v:getMatrixXY( 1, 2 ) + temp.y * v:getMatrixXY( 2, 2 ) + temp.z * v:getMatrixXY( 3, 2 );
	dir.z	= temp.x * v:getMatrixXY( 1, 3 ) + temp.y * v:getMatrixXY( 2, 3 ) + temp.z * v:getMatrixXY( 3, 3 );

	dir:normalize()

	dir = dir * -1;

	-- dir:Log('origdir')
	-- camera3d:GetDirction():Log('cameradir')
	return Ray.new(orig, dir)
end

function Ray:IsIntersectPlane( p )
	local dot = Vector3.dot( p:normal( ), self.dir );
	if  math.abs( dot ) < math.cEpsilon then
		return false, 0;
    end

	-- local temp = p:distance( self.orig ) / -dot;
	-- if temp < 0.0 then
	-- 	return false;
    -- end

	-- dist = temp;

    --return true
	return true, p:distance( self.orig ) / -dot;
end

function Ray:IsIntersectBox( box ) --BoundBox
	
	if box:vectorInBox(self.orig) then
		return true
	end
	
	local d3 = Vector3.new( 1.0 / self.dir.x, 1.0 / self.dir.y, 1.0 / self.dir.z)

	local VMin = Vector3.new()
	local VMax = Vector3.new()

	local SetMinMaxValue = function(v)
		
		if d3[v] > 0 then
			VMin[v] = (box.min[v] - self.orig[v]) * d3[v] 
			VMax[v] = (box.max[v] - self.orig[v]) * d3[v] 
		else
			VMin[v]= (box.max[v] - self.orig[v]) * d3[v] 
			VMax[v] = (box.min[v] - self.orig[v]) * d3[v] 
		end
	end

	SetMinMaxValue("x")
	SetMinMaxValue("y")
	SetMinMaxValue("z")
	

	local t0 = math.max(VMin.x, math.max(VMin.y, VMin.z))
	local t1 = math.min(VMax.x, math.min(VMax.y, VMax.z))
	local Epsilon = 1e-06;
	return t0 < t1 and t1 > Epsilon
end

function Ray:vectorOnRay( dist )
    return self.orig + self.dir * dist;
end

function Ray:GetMeshLine(dist, color)
	local HelpLine =  MeshLine.new(self.orig, self:vectorOnRay(dist or 1000))

	if color then
		HelpLine:setBaseColor(color)
	end

	return HelpLine

end

-- Return distance
function Ray:IntersectTriangle(triangle, backcull )
	local edge1 = triangle.P2 - triangle.P1;
	local edge2 = triangle.P3 - triangle.P1;

	local pvec = Vector3.Cross( self.dir, edge2 );

	local tvec = Vector3.new()
	local det = Vector3.Dot( edge1, pvec )

	if det >= 0.0 then
		tvec = self.orig - triangle.P1;
	else
		if  backcull then
			return -1
		end

		tvec = triangle.P1 - self.orig;
		det = -det;
	end

	if det < math.cEpsilon then
		return -1
	end


	local u = Vector3.Dot( tvec, pvec );
	if u < 0.0 or u > det then
		return -1
	end

	local qvec = Vector3.Cross( tvec, edge1 );

	local v = Vector3.Dot( self.dir, qvec );
	if v < 0.0 or u + v > det then
		return -1
	end

	local tdis = Vector3.Dot( edge2, qvec ) / det;
	if  tdis < 0.0 then
		return -1
	end

	dist = tdis;
	return dist;
end
