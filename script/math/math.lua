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

    if luabit then
        return luabit.lshift(x, offset)
    end

    if offset < 1 then
        return x
    end

    local v, _ = math.modf(x)

    return v * math.pow(2, offset)
end

math.RightMove = function(x, offset)
    assert(offset)

    if luabit then
        return luabit.rshift(x, offset)
    end

    if offset < 1 then
        return x
    end

    local v, _ = math.modf(x)
    
    local r, _ =  math.modf(v / math.pow(2, offset))
    return r
end

math.round = function(v)
    return math.floor(v + 0.5)
end



math.BitXor = function(v1, v2)
    if luabit then
        return luabit.bxor(v1, v2)
    end

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

math.BitAnd = function(v1, v2)
    if luabit then
        return luabit.band(v1, v2)
    end

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

math.BitOr = function(v1, v2)
    if luabit then
        return luabit.bor(v1, v2)
    end

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

math.BitEquationRightNumber = function(v1, v2)
    local BaseD = 0x80000000;

    for i = 1, 32 do
        if math.BitAnd(BaseD, v1) ~= math.BitAnd(BaseD, v2) then
            return i - 1
        else
            BaseD =  math.RightMove(BaseD, 1)
        end
    end

    return 32
end

math.MortonCode2 = function(x)
    x = math.BitAnd(0x0000ffff, x);
   
    x = math.BitAnd(math.BitXor(x, math.LeftMove(x, 8)), 0x00ff00ff);
    x = math.BitAnd(math.BitXor(x, math.LeftMove(x, 4)), 0x0f0f0f0f);
    x = math.BitAnd(math.BitXor(x, math.LeftMove(x, 2)), 0x33333333);
    x = math.BitAnd(math.BitXor(x, math.LeftMove(x, 1)), 0x55555555);

    return x
end

math.MortonCode3 = function(x)
    x = math.BitAnd(0x000003ff, x);

    x = math.BitAnd(math.BitXor(x, math.LeftMove(x, 16)), 0xff0000ff);
   
    x = math.BitAnd(math.BitXor(x, math.LeftMove(x, 8)), 0x0300f00f);
    x = math.BitAnd(math.BitXor(x, math.LeftMove(x, 4)), 0x030c30c3);
    x = math.BitAnd(math.BitXor(x, math.LeftMove(x, 2)), 0x09249249);

    return x
end

math.ReverseMortonCode2 = function( x )
    x = math.BitAnd(0x55555555, x);
    x = math.BitAnd(math.BitXor(x, math.RightMove(x, 1)), 0x33333333)
    x = math.BitAnd(math.BitXor(x, math.RightMove(x, 2)), 0x0f0f0f0f)
    x = math.BitAnd(math.BitXor(x, math.RightMove(x, 4)), 0x00ff00ff)
    x = math.BitAnd(math.BitXor(x, math.RightMove(x, 8)), 0x0000ffff)
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
    for i = 1, #Src do
        local Value = Src[i];
        
        local Key = SortKey( Value );
        local key1 =  math.BitAnd(math.RightMove( Key,  0 ), 1023) + 1
        Dst[ Histogram0[ key1 ] ] = Value;

        local temp = Histogram0[ key1 ] 
        Histogram0[ key1 ] = Histogram0[ key1 ] - 1
    end

    Src = Dst
    Dst = {}
    for i = 1, #Src do
        local Value = Src[i];
       
        local Key = SortKey( Value );
        local key2 =  math.BitAnd(math.RightMove( Key,  10 ), 2047) + 1
        Dst[ Histogram1[ key2 ] ] = Value;
        Histogram1[ key2 ] = Histogram1[ key2 ] - 1
    end

    Src = Dst
    Dst = {}
    for i = 1, #Src do
        local Value = Src[i];
        local Key = SortKey( Value );
        local key3 =  math.BitAnd(math.RightMove( Key,  21 ), 2047) + 1
        Dst[ Histogram2[ key3 ] ] = Value;
        Histogram2[ key3 ] = Histogram2[ key3 ] - 1
    end


	return Dst

end

math.SortLargeArray = function(Datas, SortFunc)
    local LimiteNum = 5120
    if #Datas < LimiteNum then
        table.sort(Datas, SortFunc)
    end

    local SubDatas = {}
    local CurrentIndex = 1

    local Num = #Datas
    for i = 1, Num do
        if not SubDatas[CurrentIndex] then
            SubDatas[CurrentIndex] = {}
        end

        local SubData =  SubDatas[CurrentIndex]
        SubData[#SubData + 1] = Datas[i]
        if #SubDatas[CurrentIndex] == LimiteNum then
            CurrentIndex = CurrentIndex + 1
        end
    end

    local IndexArray = {}
    for i = 1, #SubDatas do
        table.sort(SubDatas[i], SortFunc)
        IndexArray[i] = 1
    end

    local TempDatas = {}
    math.ArrayCopy(Datas, TempDatas)

    for i = 1, Num do
        local IndexJ = 1
        for j = 2, #SubDatas do
            if not SortFunc(SubDatas[IndexJ][IndexArray[IndexJ]], SubDatas[j][IndexArray[j]]) then
                IndexJ = j
            end
        end

        Datas[i] = SubDatas[IndexJ][IndexArray[IndexJ]]

        IndexArray[IndexJ] = IndexArray[IndexJ] + 1
        if IndexArray[IndexJ] > #SubDatas[IndexJ] then
            table.remove(IndexArray, IndexJ)
            table.remove(SubDatas, IndexJ)
        end
    end
end

math.AppendArray = function(DesArray, SourceArray)
    for i = 1, #SourceArray do
        DesArray[#DesArray + 1] = SourceArray[i]
    end
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
    return Result
end

math.ArraySub = function(a, b)
    _errorAssert(#a == #b, "math.ArraySub")
    local Result = {}
    for i = 1, #a do
        Result[i] = a[i] - b[i]
    end
    return Result
end

math.ArrayDiv = function(a, b)
    _errorAssert(#a > 0 and type(b) == 'number', "math.ArrayDiv")
    local Result = {}
    for i = 1, #a do
        Result[i] = b ~= 0 and a[i] / b or 0
    end

    return Result
end


math.ArrayMulValue = function(a, b)
    _errorAssert(#a > 0 and type(b) == 'number', "math.ArrayMulValue")
    local Result = {}
    for i = 1, #a do
        Result[i] = a[i] * b
    end
    return Result
end

math.ArrayNorm = function(a)
    _errorAssert(#a > 0, "math.ArrayNorm")
    local Result = 0
    for i = 1, #a do
        Result = Result + a[i] * a[i]
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

math.ArrayCopy = function(SourceArray, DesArray)
    for i, v in ipairs(SourceArray) do
        DesArray[i] = v
    end
end

math.IsNearlyEqual = function(A, B, SMALL_NUMBER)
    local ErrorTolerance = SMALL_NUMBER or math.SMALL_NUMBER
    return math.abs( A - B ) <= ErrorTolerance;
end

-- Returns <0 if C is left of A-B
math.ComputeDeterminant2D = function(A, B, C)
    local u1 = B.x - A.x;
    local v1 = B.y - A.y;
    local u2 = C.x - A.x;
    local v2 = C.y - A.y;

    return u1 * v2 - v1 * u2;
end

--Alternate simple implementation that was found to work correctly for points that are very close together (inside the 0-1 range).
math.ComputeConvexHull2 = function(InPoints, OutIndices)
    if #InPoints <= 1 then
        return
    end

    --Jarvis march implementation
    local LeftMostIndex = 1
    local LeftMostVec = InPoints[1]
    for i = 2, #InPoints do
        if InPoints[i].x < LeftMostVec.x or (InPoints[i].x == LeftMostVec.x and InPoints[i].y < LeftMostVec.y) then
            LeftMostVec = InPoints[i]
            LeftMostIndex = i
        end
    end

    local PointOnHullIndex = LeftMostIndex
	local EndPointIndex = -1;

    while EndPointIndex ~= LeftMostIndex do
        OutIndices[#OutIndices + 1] = PointOnHullIndex
        EndPointIndex = 1

        for j = 2, #InPoints do
            if EndPointIndex == PointOnHullIndex or math.ComputeDeterminant2D(InPoints[EndPointIndex], InPoints[PointOnHullIndex], InPoints[j]) < 0 then
                EndPointIndex = j
            end
        end

        PointOnHullIndex = EndPointIndex
    end

end

function IsValidUV(InUV, w, h)

	return InUV.x >= 0 and InUV.x <= w and InUV.y >= 0.0 and InUV.y <= h
end

math.ComputePointIntersectionBetweenLines2D = function(ray2d0, ray2d1, OutIntersectPoint)
    local d = Vector.cross(ray2d0.dir, ray2d1.dir)

    if math.abs(d) < math.SMALL_NUMBER then
        return false
    end

    local t = Vector.cross(ray2d1.dir, ray2d0.orig - ray2d1.orig) / d;

    if t < 0.5 then
		return false;
    end

    local result = ray2d0.orig + ray2d0.dir * t
    OutIntersectPoint:Set(result)
    return true
end

--InTargetVertexCount Must be 4, 6, 8
function FindOptimalPolygonInner(w, h, InTargetVertexCount, InRay2Ds, InStartIndex, InPreIndex, InFirstIndex, InUVTable, InCount, OutData)
    for i = InStartIndex, #InRay2Ds do
        local V = Vector.new()

        local IsIntersect = math.ComputePointIntersectionBetweenLines2D(InRay2Ds[InStartIndex - 1], InRay2Ds[i], V)

        if IsIntersect and IsValidUV(V, w, h) then
            InUVTable[#InUVTable + 1] = V
          
            local VV = Vector.new()
            local IsLast = InCount == (InTargetVertexCount - 1)
            IsIntersect = IsLast and math.ComputePointIntersectionBetweenLines2D(InRay2Ds[i], InRay2Ds[InFirstIndex], VV)
           
            if IsIntersect and IsValidUV(VV, w, h) then
                InUVTable[#InUVTable + 1] = VV
                local Area =  OutData.MinArea + 1
                if InTargetVertexCount == 4 then
                    local U0 = InUVTable[2] - InUVTable[1];
                    local U1 = InUVTable[3] - InUVTable[1];
                    local U2 = InUVTable[4] - InUVTable[1];

                    Area =
                        (U0.y * U1.x - U0.x * U1.y) +
                        (U1.y * U2.x - U1.x * U2.y);
                elseif InTargetVertexCount == 6 then
                    local U0 = InUVTable[2] - InUVTable[1];
                    local U1 = InUVTable[3] - InUVTable[1];
                    local U2 = InUVTable[4] - InUVTable[1];
                    local U3 = InUVTable[5] - InUVTable[1];
                    local U4 = InUVTable[6] - InUVTable[1];

                    Area =
                        (U0.y * U1.x - U0.x * U1.y) +
                        (U1.y * U2.x - U1.x * U2.y) + 
                        (U2.y * U3.x - U2.x * U3.y) +
                        (U3.y * U4.x - U3.x * U4.y);

                elseif InTargetVertexCount == 8 then
                        local U0 = InUVTable[2] - InUVTable[1];
                        local U1 = InUVTable[3] - InUVTable[1];
                        local U2 = InUVTable[4] - InUVTable[1];
                        local U3 = InUVTable[5] - InUVTable[1];
                        local U4 = InUVTable[6] - InUVTable[1];
                        local U5 = InUVTable[7] - InUVTable[1];
                        local U6 = InUVTable[8] - InUVTable[1];
    
                        Area =
                            (U0.y * U1.x - U0.x * U1.y) +
                            (U1.y * U2.x - U1.x * U2.y) + 
                            (U2.y * U3.x - U2.x * U3.y) +
                            (U3.y * U4.x - U3.x * U4.y) +
                            (U4.y * U5.x - U4.x * U5.y) +
                            (U5.y * U6.x - U5.x * U6.y);
                end

                if Area < OutData.MinArea then
                    OutData.MinArea = Area;
                    local Size = Vector.new(w, h)
                    for VNIndex = 1, #InUVTable do
                        OutData.OutBoundingVertices[VNIndex] = InUVTable[VNIndex];
                    end
                end
                
                table.remove(InUVTable, #InUVTable)
            else
                FindOptimalPolygonInner(w, h, InTargetVertexCount, InRay2Ds, i + 1, i, InFirstIndex, InUVTable, InCount + 1, OutData)
            end

            table.remove(InUVTable, #InUVTable)
        end
    end
end

--TargetVertexCount Must be 4, 6, 8
math.FindOptimalPolygon = function(w, h, TargetVertexCount, ConvexHullIndices, PotentialHullVertices, OutData)
    local VertexCount = math.min(TargetVertexCount, #ConvexHullIndices)

    local Ray2Ds = {}
    local Size = Vector.new(w,h)
    for i = 1, #ConvexHullIndices do
        local i1 = i
        local i2 = i + 1
        if i2 > #ConvexHullIndices then
            i2 = 1
           
        end

        local v1 = PotentialHullVertices[ConvexHullIndices[i1]] 
        local v2 = PotentialHullVertices[ConvexHullIndices[i2]]
        -- v1.y = h - v1.y
        -- local vv = v1 / Size
        -- log('hhhhhhhhhhhhhh', vv.x, vv.y )
        Ray2Ds[#Ray2Ds + 1] = Ray2D.new(v1 , v2 - v1)
    end
    
    OutData.MinArea = math.FLT_MAX - 2

    local UVTable = {}
    local Count = 0
    for i = 1, #Ray2Ds do
        FindOptimalPolygonInner(w, h, VertexCount, Ray2Ds, i + 1, i, i, UVTable, Count + 1, OutData)
    end

    -- for i = 1, #ConvexHullIndices do
    --     OutData.OutBoundingVertices[i] = PotentialHullVertices[ConvexHullIndices[i]] 
    -- end
end

math.GetTangentCone2D = function(InVector, InCircle, OutOCone2d)
    local CPos = Vector.new(InCircle.x, InCircle.y)
    local R = InCircle.r

    local dis = Vector.Distance(InVector, CPos)
    local sina = math.asin(R / dis)

    if OutOCone2d then
        OutOCone2d.pos = Vector.copy(InVector)
        OutOCone2d.angle = sina * 2
        OutOCone2d.dir = (CPos - InVector):normalize()
        OutOCone2d.r = R + dis
    else
        
        OutOCone2d = Cone2D.new(InVector, (CPos - InVector):normalize(), R + dis,  math.deg(sina * 2))
    end
    return OutOCone2d
end

math.defaulttransform =  love.math.newTransform( );
math.MinNumber = 0.000001;
math.MaxNumber = 999999.0;
math.cEpsilon = 0.000001;

math.maxFloat	=  3.402823466e+38;
math.minFloat	= -3.402823466e+38;

math.KINDA_SMALL_NUMBER	 = 1.e-4
math.SMALL_NUMBER = 1.e-8

math.c2pi = math.pi * 2
math.invpi = 1 / math.pi
math.invc2pi = 1 / math.c2pi
-- math.ARC = math.PI * 2;
math.FLT_MAX = 3.402823466e+38
math.UE_KINDA_SMALL_NUMBER = 1.e-4