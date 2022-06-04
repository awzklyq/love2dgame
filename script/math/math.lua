math.lerp = function(v1, v2, t)
    t  = math.clamp(t, 0, 1);
    return (1-t)*v1 + t *v2;
end

math.clamp = function(v, v1, v2)
    local min = math.min(v1, v2);
    local max = math.max(v1, v2);

    if v < min then
        return min;
    end

    if v > max then
        return max;
    end

    return v;
end

math.noise = function(...)
    local value = love.math.noise( ... )
    return value--2 * value - 1
end

local GetCross = function(p1, p2, p)
	return (p2.x - p1.x) * (p.y - p1.y) - (p.x - p1.x) * (p2.y - p1.y);
end

math.IsPointInRect = function(p, a, b, c, d)
	return GetCross(a, b, p) * GetCross(c, d, p) >= 0 and GetCross(b, c, p) * GetCross(d, a, p) >= 0;
end

math.IntersectLine = function( a, b, c, d, intersect_p) --out intersect_p

    if(a.x - b.x == 0) then
        if (c.x > a.x and d.x > a.x ) or (c.x < a.x and d.x < a.x ) then
            return false;
        end

        local miny = math.min(a.y, b.y)
        local maxy = math.max(a.y, b.y)

        if (c.y > maxy and d.y > maxy ) or (c.y < miny and d.y < miny) then
            return false;
        end
    else
        local k = (b.y - a.y) / (b.x - a.x)
        local cv = a.y - a.x * k

        local rc = k * c.x + cv
        local rd = k * d.x + cv

        if (c.y > rc and d.y > rd) or (c.y < rc and d.y < rd) then
            return false
        end
    end

    if(c.x - d.x == 0) then
        if (a.x > c.x and b.x > c.x ) or (a.x < c.x and b.x < c.x ) then
            return false;
        end

        local miny = math.min(c.y, d.y)
        local maxy = math.max(c.y, d.y)

        if (a.y > maxy and b.y > maxy ) or (a.y < miny and b.y < miny) then
            return false;
        end
    else
        local k = (d.y - c.y) / (d.x - c.x)
        local cv = c.y - c.x * k

        local ra = k * a.x + cv
        local rb = k * b.x + cv

        if (a.y > ra and b.y > rb) or (a.y < ra and b.y < rb) then
            return false
        end
    end
    
	local area_abc = (a.x - c.x) * (b.y - c.y) - (a.y - c.y) * (b.x - c.x);
	local area_abd = (a.x - d.x) * (b.y - d.y) - (a.y - d.y) * (b.x - d.x);

	if (area_abc * area_abd >= 0)  then return false end

	local area_cda = (c.x - a.x) * (d.y - a.y) - (c.y - a.y) * (d.x - a.x);
	local area_cdb = (c.x - b.x)* (d.y - b.y) - (c.y - b.y) * (d.x - b.x);

	if (area_cda * area_cdb >= 0) then return false end

	local t = area_cda / (area_abd - area_abc);
	local dx = t * (b.x - a.x);
	local dy = t * (b.y - a.y);
	intersect_p.x = a.x + dx;
	intersect_p.y = a.y + dy;

	return true;
end

math.IntersectLine11 = function( a, b, c, d, intersect_p) --out intersect_p

    if(a.x - b.x == 0) then
        if (c.x > a.x and d.x > a.x ) or (c.x < a.x and d.x < a.x ) then
            return false;
        end

        local miny = math.min(a.y, b.y)
        local maxy = math.max(a.y, b.y)

        if (c.y > maxy and d.y > maxy ) or (c.y < miny and d.y < miny) then
            return false;
        end
    else
        local k = (b.y - a.y) / (b.x - a.x)
        local cv = a.y - a.x * k

        local rc = k * c.x + cv
        local rd = k * d.x + cv

        if (c.y > rc and d.y > rd) or (c.y < rc and d.y < rd) then
            return false
        end
    end

    if(c.x - d.x == 0) then
        if (a.x > c.x and b.x > c.x ) or (a.x < c.x and b.x < c.x ) then
            return false;
        end

        local miny = math.min(c.y, d.y)
        local maxy = math.max(c.y, d.y)

        if (a.y > maxy and b.y > maxy ) or (a.y < miny and b.y < miny) then
            return false;
        end
    else
        local k = (d.y - c.y) / (d.x - c.x)
        local cv = c.y - c.x * k

        local ra = k * a.x + cv
        local rb = k * b.x + cv

        if (a.y > ra and b.y > rb) or (a.y < ra and b.y < rb) then
            return false
        end
    end

	local area_abc = (a.x - c.x) * (b.y - c.y) - (a.y - c.y) * (b.x - c.x);
	local area_abd = (a.x - d.x) * (b.y - d.y) - (a.y - d.y) * (b.x - d.x);

    log('tttttt111111', area_abc, area_abd)
	if (area_abc * area_abd >= 0)  then return false end

    
	local area_cda = (c.x - a.x) * (d.y - a.y) - (c.y - a.y) * (d.x - a.x);
	local area_cdb = (c.x - b.x)* (d.y - b.y) - (c.y - b.y) * (d.x - b.x);

    log('tttttt22222', area_cda, area_cdb)
	if (area_cda * area_cdb >= 0) then return false end

	local t = area_cda / (area_abd - area_abc);
	local dx = t * (b.x - a.x);
	local dy = t * (b.y - a.y);
	intersect_p.x = a.x + dx;
	intersect_p.y = a.y + dy;

	return true;
end

math.CheckLineAndRectCollision = function(StartPos, EndPos, BA, BB, IntersecPoint) -- out IntersecPoint
	--IntersecPoint = Vector3.new(-1, -1, -1);
	local point1 = Vector.new(math.min(BA.x, BB.x), math.min(BA.y, BB.y))
	local point3 = Vector.new(math.max(BA.x, BB.x), math.max(BA.y, BB.y))

    local point2 = Vector.new(point3.x, point1.y);
	
	local point4 = Vector.new(point1.x, point3.y);

    log('rrrrrrrrrrrrrr point1', point1.x, point1.y)
    log('rrrrrrrrrrrrrr point2', point2.x, point2.y)
    log('rrrrrrrrrrrrrr point3', point3.x, point3.y)
    log('rrrrrrrrrrrrrr point4', point4.x, point4.y)

    -- local MinPos = Vector.new(math.min(StartPos.x, EndPos.x), math.min(StartPos.y, EndPos.y))
	-- local MaxPos = Vector.new(math.max(StartPos.x, EndPos.x), math.max(StartPos.y, EndPos.y))

	local intersec = Vector.new();
	local minintersec = Vector.new()

	local IsIntersec = 0;
	if math.IntersectLine(StartPos, EndPos, point1, point2, intersec) then
		IsIntersec = IsIntersec + 1
		minintersec = intersec;
    end

	if (math.IntersectLine(StartPos, EndPos, point2, point3, intersec)) then
		IsIntersec = IsIntersec + 1
		if IsIntersec > 1 then
            if (intersec - StartPos):length() < (minintersec - StartPos):length() then
                minintersec = intersec;
            end
        else
            minintersec = intersec;
        end
	end

	if (IsIntersec < 2 and math.IntersectLine(StartPos, EndPos, point3, point4, intersec)) then
	
		IsIntersec = IsIntersec + 1
		if IsIntersec > 1 then
            if (intersec - StartPos):length() < (minintersec - StartPos):length() then
                minintersec = intersec;
            end
        else
            minintersec = intersec;
        end
	end

	if (IsIntersec < 2 and math.IntersectLine11(StartPos, EndPos, point4, point1, intersec)) then
	
		IsIntersec = IsIntersec + 1
		if IsIntersec > 1 then
            if (intersec - StartPos):length() < (minintersec - StartPos):length() then
                minintersec = intersec;
            end
        else
            minintersec = intersec;
        end
	end
	
	if (IsIntersec > 0) then
		IntersecPoint.x = minintersec.x;
        IntersecPoint.y = minintersec.y;
		IntersecPoint.z = 1;
		return true;
    end

	if (math.IsPointInRect(StartPos, point1, point2, point3, point4)) then
	
		return true;
    end

	
	return false;
end


math.defaulttransform =  love.math.newTransform( );
math.MinNumber = 0.000001;
math.MaxNumber = 999999.0;
math.cEpsilon = 0.000001;

math.maxFloat	=  3.402823466e+38;
math.minFloat	= -3.402823466e+38;

math.c2pi = math.pi * 2
-- math.ARC = math.PI * 2;