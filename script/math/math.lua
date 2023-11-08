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
    if intersect_p then
        intersect_p.x = a.x + dx;
        intersect_p.y = a.y + dy;
    end

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

math.CheckLineAndRectCollision = function(StartPos, EndPos, BA, BB, IntersecPoint) -- out IntersecPoint
	--IntersecPoint = Vector3.new(-1, -1, -1);
	local point1 = Vector.new(math.min(BA.x, BB.x), math.min(BA.y, BB.y))
	local point3 = Vector.new(math.max(BA.x, BB.x), math.max(BA.y, BB.y))

    local point2 = Vector.new(point3.x, point1.y);
	
	local point4 = Vector.new(point1.x, point3.y);

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


math.LeftMove = function(x, offset)
    assert(offset)
    if offset < 1 then
        return x
    end

    local v, _ = math.modf(x)

    return v * math.pow(2, offset)
end

math.RightMove = function(x, offset)
    assert(offset)
    if offset < 1 then
        return x
    end

    local v, _ = math.modf(x)
    
    local r, _ =  math.modf(v / math.pow(2, offset))
    return r
end

math.BitXor = function(v1, v2, type)
    local Step = 0
    local result = 0

    v1 = math.modf(v1)
    v2 = math.modf(v2)
    while (v1 ~= 0 or  v2 ~= 0) do
        local r1 = v1 % 2
        local r2 = v2 % 2
        if r1 ~= r2 then
            result = result + math.pow(2, Step)
        else
            result = result + 0
        end

        Step = Step + 1
        v1 = math.RightMove(v1, 1)
        v2 = math.RightMove(v2, 1)
    end
    return result
end

math.BitAnd = function(v1, v2, type)
    local Step = 0
    local result = 0

    v1 = math.modf(v1)
    v2 = math.modf(v2)
    while (v1 ~= 0 or  v2 ~= 0) do
        local r1 = v1 % 2
        local r2 = v2 % 2
        if r1 == 1 and r2 == 1 then
            result = result + math.pow(2, Step)
        else
            result = result + 0
        end

        Step = Step + 1
        v1 = math.RightMove(v1, 1)
        v2 = math.RightMove(v2, 1)
    end
    return result
end

math.BitOr = function(v1, v2, type)
    local Step = 0
    local result = 0

    v1 = math.modf(v1)
    v2 = math.modf(v2)
    while (v1 ~= 0 or  v2 ~= 0) do
        local r1 = v1 % 2
        local r2 = v2 % 2
        if r1 == 1 or r2 == 1 then
            result = result + math.pow(2, Step)
        else
            result = result + 0
        end

        Step = Step + 1
        v1 = math.RightMove(v1, 1)
        v2 = math.RightMove(v2, 1)
    end
    return result
end

math.MortonCode3 = function(x)
    x = math.BitAnd(0x000003ff, x);

    x = math.BitAnd(math.BitXor(x, math.LeftMove(x, 16)), 0xff0000ff);
   
    x = math.BitAnd(math.BitXor(x, math.LeftMove(x, 8)), 0x0300f00f);
    x = math.BitAnd(math.BitXor(x, math.LeftMove(x, 4)), 0x030c30c3);
    x = math.BitAnd(math.BitXor(x, math.LeftMove(x, 2)), 0x09249249);

    return x
end

math.ReverseMortonCode3 = function( x )
    x = math.BitAnd(0x09249249, x);

    x = math.BitAnd(math.BitXor(x, math.RightMove(x, 2)), 0x030c30c3)
    x = math.BitAnd(math.BitXor(x, math.RightMove(x, 4)), 0x0300f00f)
    x = math.BitAnd(math.BitXor(x, math.RightMove(x, 8)), 0xff0000ff)
    x = math.BitAnd(math.BitXor(x, math.RightMove(x, 16)), 0x000003ff)

    return x
end

math.RadixSort32 = function(Src, SortKey)
    local Histogram0 = {}
	local Histogram1 = {}
	local Histogram2 = {}

    local Num = #Src
    for i = 1, 1024 do
        Histogram0[i] = 0

        Histogram1[i] = 0
        Histogram1[i + 1024] = 0

        Histogram2[i] = 0
        Histogram2[i + 1024] = 0
    end

    -- Parallel histogram generation pass
    for i = 1, Num do
        local Key = SortKey( Src[i] );

        local key1 =  math.BitAnd(math.RightMove( Key,  0 ), 1023) + 1
        local key2 =  math.BitAnd(math.RightMove( Key,  10 ), 2047) + 1
        local key3 =  math.BitAnd(math.RightMove( Key,  21 ), 2047) + 1

        Histogram0[key1] = Histogram0[key1] + 1
        Histogram1[key2] = Histogram1[key2] + 1
        Histogram2[key3] = Histogram2[key3] + 1

    end

    -- Prefix sum
	-- Set each histogram entry to the sum of entries preceding it
	local Sum0 = 0;
	local Sum1 = 0;
	local Sum2 = 0;

    for i = 1, 1024 do
        local t;

        t = Histogram0[i] + Sum0
        Histogram0[i] = t
        Sum0 = t

        t = Histogram1[i] + Sum1
        Histogram1[i] = t
        Sum1 = t

        t = Histogram2[i] + Sum2
        Histogram2[i] = t
        Sum2 = t
    end

    for i = 1025, 2038 do
        local t;

        t = Histogram1[i] + Sum1
        Histogram1[i] = t
        Sum1 = t

        t = Histogram2[i] + Sum2
        Histogram2[i] = t
        Sum2 = t
    end

    local Dst = {}
    for i = 1, Num do
        local Value = Src[i];
        local Key = SortKey( Value );
        local key1 =  math.BitAnd(math.RightMove( Key,  0 ), 1023) + 1
        Dst[ Histogram0[ key1 ] ] = Value;

        local temp = Histogram0[ key1 ] 
        Histogram0[ key1 ] = Histogram0[ key1 ] - 1
    end

    Src = Dst
    Dst = {}
    for i = 1, Num do
        local Value = Src[i];
        local Key = SortKey( Value );
        local key2 =  math.BitAnd(math.RightMove( Key,  10 ), 2047) + 1
        Dst[ Histogram1[ key2 ] ] = Value;
        Histogram1[ key2 ] = Histogram1[ key2 ] - 1
    end

    Src = Dst
    Dst = {}
    for i = 1, Num do
        local Value = Src[i];
        local Key = SortKey( Value );
        local key3 =  math.BitAnd(math.RightMove( Key,  21 ), 2047) + 1
        Dst[ Histogram2[ key3 ] ] = Value;
        Histogram2[ key3 ] = Histogram2[ key3 ] - 1
    end


	return Dst

end

-- Encode for normal map.
math.SphericalEncode = function(v3)
    local v = Vector.new()
    v.x = math.atan2(v3.y, v3.x) * math.invc2pi
    v.y = v3.z

    v = v * 0.5 + 0.5
    return v
end

math.SphericalDecode = function(v)
    local ang = v * 2.0 - 1.0

    local scth = Vector.new()

    local r = ang.x * math.c2pi
    local d2 =  1.0 - ang.y * ang.y
     

    scth.x = math.cos(r)
    scth.y = math.sin(r)

    local schpi = Vector.new(math.sqrt( 1.0 - ang.y * ang.y ), ang.y)

    local v3 = Vector3.new(scth.x * schpi.x, scth.y * schpi.x, schpi.y)

    return v3
end

local OctWrap = function(v)
    local x = ( 1.0 - math.abs( v.x ) ) * ( v.x >= 0.0 and 1.0 or -1.0 );
    local y = ( 1.0 - math.abs( v.y ) ) * ( v.y >= 0.0 and 1.0 or -1.0 );
    return Vector.new(y, x)
end

math.OctEncode = function(v3)
    v3 = v3 / (math.abs(v3.x) + math.abs(v3.y) + math.abs(v3.z))

    local n = Vector.new(v3.x, v3.y)

    if v3.z < 0 then
        n = OctWrap(n)
    end

    n = n * 0.5 + 0.5
    return n
end

math.OctDecode = function(v)
    v = v * 2.0 - 1.0

    local n = Vector3.new(v.x, v.y, 1.0 - math.abs(v.x) - math.abs(v.y))
    local t = math.clamp(-n.z, 0, 1)
    n.x = n.x + (n.x > 0 and -t or t)
    n.y = n.y + (n.y > 0 and -t or t)

    return n:normalize()
end

math.PointToLineDistance2D = function(point, line)
    return math.PointToLineDistanceXY2D(point, line.x1, line.y1, line.x2, line.y2)
end

math.PointToLineDistanceXY2D = function(point, lineX1, lineY1, lineX2, lineY2)
    local lineStart = Vector.new(lineX1, lineY1)
    local lineEnd = Vector.new(lineX2, lineY2)
    local dx = lineEnd.x - lineStart.x
    local dy = lineEnd.y - lineStart.y
    local lineLengthSquared = dx*dx + dy*dy

    if lineLengthSquared == 0 then
        dx = point.x - lineStart.x
        dy = point.y - lineStart.y
        return math.sqrt(dx*dx + dy*dy)
    end

    local t = ((point.x - lineStart.x) * dx + (point.y - lineStart.y) * dy) / lineLengthSquared

    if t < 0 then
        dx = point.x - lineStart.x
        dy = point.y - lineStart.y
    elseif t > 1 then
        dx = point.x - lineEnd.x
        dy = point.y - lineEnd.y
    else
        local proj = { x = lineStart.x + t * dx, y = lineStart.y + t * dy }
        dx = point.x - proj.x
        dy = point.y - proj.y
    end

    return math.sqrt(dx*dx + dy*dy)
end

math.ArrayAdd = function(a, b)
    _errorAssert(#a == #b, "math.AddArray")
    local Result = {}
    for i = 1, #a do
        Result[i] = a[i] + b[i]
    end
end

math.ArraySub = function(a, b)
    _errorAssert(#a == #b, "math.ArraySub")
    local Result = {}
    for i = 1, #a do
        Result[i] = a[i] - b[i]
    end
end

math.ArrayDiv = function(a, b)
    _errorAssert(#a > 0 and type(b) == 'number', "math.ArrayDiv")
    local Result = {}
    for i = 1, #a do
        Result[i] = a[i] / b
    end
end


math.ArrayMulValue = function(a, b)
    _errorAssert(#a > 0 and type(b) == 'number', "math.ArrayMulValue")
    local Result = {}
    for i = 1, #a do
        Result[i] = a[i] * b
    end
end

math.ArrayNorm = function(a)
    _errorAssert(#a > 0, "math.ArrayNorm")
    local Result = 0
    for i = 1, #a do
        Result = a[i] * a[i]
    end

    return math.sqrt(Result)
end

math.ArrayConvertMatrixsRow = function(v)
    _errorAssert(#v > 0, "math.ArrayConvertMatrixsRow")
    local m = #v
    local mat = Matrixs.new(m, m)
    for j = 1, mat.Column do
        mat[1][j] = v[j]
    end

    return mat
end

math.ArrayConvertMatrixsColumn = function(v)
    _errorAssert(#v > 0, "math.ArrayConvertMatrixsColumn")
    local m = #v
    local mat = Matrixs.new(m, m)
    for i = 1, mat.Row do
        mat[i][1] = v[i]
    end

    return mat
end

math.ArrayIdentity = function(v)
    _errorAssert(#v > 1, "math.ArrayIdentity")
    local Result = {}
    Result[1] = 1
    for i = 2, #v do
        Result[i] = 0
    end

    return Result
end

math.defaulttransform =  love.math.newTransform( );
math.MinNumber = 0.000001;
math.MaxNumber = 999999.0;
math.cEpsilon = 0.000001;

math.maxFloat	=  3.402823466e+38;
math.minFloat	= -3.402823466e+38;

math.c2pi = math.pi * 2
math.invpi = 1 / math.pi
math.invc2pi = 1 / math.c2pi
-- math.ARC = math.PI * 2;