_G.Plane = {}

function Plane.new(a, b, c, d)
    local plane = setmetatable({}, {__index = Plane});

    plane.a = a or 0
    plane.b = b or 0
    plane.c = c or 0
    plane.d = d or 0

    plane.name = 'plane'

    return plane
end

function Plane.buildFromPoints( v1, v2, v3 )
    local plane = Plane.new()
    local n = Vector3.cross( v2 - v1, v3 - v1 );
    n:normalize( );

    plane.a = n.x;
    plane.b = n.y;
    plane.c = n.z;
    plane.d = - Vector3.dot( v1, n );
    return plane
end


function Plane:distance( v )
    return self.a * v.x + self.b * v.y + self.c * v.z + self.d
end

function Plane:buildFromThreePoints( v1, v2, v3 )
    local n = Vector3.cross( Vector3.sub(v2, v1), Vector3.sub(v3, v1) );
    n:normalize( );

    self.a = n.x;
    self.b = n.y;
    self.c = n.z;
    self.d = - Vector3.dot( v1, n );
end

function Plane:normal( )
    return Vector3.new( self.a, self.b, self.c ); 
end

function Plane.mulMatrix( plane, mat )
    local aa = mat:getData( 1, 1 ) * plane.a + mat:getData( 1, 2 ) * plane.b + mat:getData( 1, 3 ) * plane.c;
    local bb = mat:getData( 2, 1 ) * plane.a + mat:getData( 2, 2 ) * plane.b + mat:getData( 2, 3 ) * plane.c;
    local cc = mat:getData( 3, 1 ) * plane.a + mat:getData( 3, 2 ) * plane.b + mat:getData( 3, 3 ) * plane.c;

    local v = Vector3.new( plane.a, plane.b, plane.c )
    v:mulSelf( -plane.d)

    local temp = Matrix3D.transpose(mat)
    temp:mulLeftVector3(v)

    local newplane = Plane.new(aa, bb, cc, Vector3.dot( v, Vector3.new( aa, bb, cc ) ))

    return newplane;

    -- _float aa = mat( 0, 0 ) * a + mat( 0, 1 ) * b + mat( 0, 2 ) * c;
	-- 	_float bb = mat( 1, 0 ) * a + mat( 1, 1 ) * b + mat( 1, 2 ) * c;
	-- 	_float cc = mat( 2, 0 ) * a + mat( 2, 1 ) * b + mat( 2, 2 ) * c;

	-- 	Vector3 v = Vector3( a, b, c ) * -d * mat;

	-- 	a = aa;
	-- 	b = bb;
	-- 	c = cc;
	-- 	d = - Vector3::Dot( v, Vector3( aa, bb, cc ) );
end

function Plane:getName( )
    return self.name
end
