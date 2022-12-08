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

function Ray:IsIntersectPlane( p )
	local dot = Vector3.dot( p:normal( ), self.dir );
	if  math.abs( dot ) < math.cEpsilon then
		return false;
    end

	-- local temp = p:distance( self.orig ) / -dot;
	-- if temp < 0.0 then
	-- 	return false;
    -- end

	-- dist = temp;

    --return true
	return p:distance( self.orig ) / -dot;
end

function Ray:IsIntersectBox( box ) --BoundBox
	
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
