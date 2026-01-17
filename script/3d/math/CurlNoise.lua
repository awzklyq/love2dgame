_G.CurlNoise = {}

local pot = function(InPosition, InTime)
    local t = InTime* 0.1;

    local pos = InPosition
    local _TempP = pos + Vector.new(InTime* 0.4,0.0)
	local p = Vector3.new(_TempP.x, _TempP.y, t);
	
	local n = math.NoiseVector3 (p);
	n = n + 0.5 *math.NoiseVector3 (p*2.13);
	n = n + 3. * math.NoiseVector3 (pos*0.333);
	
	return n
end

CurlNoise.Process = function(InPosition, InTime)
    local pos = InPosition
    local s = 1.5;
	pos = pos * s;
	
	local n = pot(pos, InTime);
	
	local e = 0.1;
	local nx = pot(pos+Vector.new(e,0), InTime);
	local ny = pot(pos+Vector.new(0.,e), InTime);
	
	return Vector.new(-(ny-n),nx-n)/e;

    -- local pos = InPosition
    -- local s = 1.5;
	-- pos = pos * s;
	
	-- local n = math.NoiseVector2(pos);
	
	-- local e = 0.1;
	-- local nx = math.NoiseVector2(pos+Vector.new(e,0));
	-- local ny = math.NoiseVector2(pos+Vector.new(0.,e));
	
	-- return Vector.new(-(ny-n),nx-n)/e;
end