_G.Ray = {}

function Ray.new(orig, dir)
    local ray = setmetatable({}, {__index = Ray});

    ray.orig = orig or Vector3.new();
	ray.dir = dir or Vector3.new();
    ray.name = 'ray'

    return ray
end

function Ray:isIntersectPlane( p )
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

function Ray:vectorOnRay( dist )
    return self.orig + self.dir * dist;
end
