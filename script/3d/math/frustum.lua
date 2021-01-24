_G.Frustum = {}
function Frustum.new()
    local frustum = setmetatable({}, {__index = Frustum});

    return frustum
end


function Frustum.insideBox( box )

	-- TODO, use sse.

	Vector3 vmin;

	for ( _dword i = 0; i < 6; i ++ )
	{
		-- X axis.
		vmin.x = ps[i].a > 0.0f ? box.vmin.x : box.vmax.x;

		-- Y axis.
		vmin.y = ps[i].b > 0.0f ? box.vmin.y : box.vmax.y;

		-- Z axis.
		vmin.z = ps[i].c > 0.0f ? box.vmin.z : box.vmax.z;

		if ( ps[i].Distance( vmin ) > 0.0f )
			return _false;
	}

    return _true;
    
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