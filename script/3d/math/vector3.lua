_G.Vector3 = {}

local metatable_vector3 = {}
metatable_vector3.__index = Vector3

metatable_vector3.__add = function(myvalue, value)
    return Vector3.new(myvalue.x + value.x, myvalue.y + value.y, myvalue.z + value.z)
end

metatable_vector3.__sub = function(myvalue, value)
    return Vector3.new(myvalue.x - value.x, myvalue.y - value.y, myvalue.z - value.z)
end

metatable_vector3.__mul = function(myvalue, value)
    return Vector3.new(myvalue.x * value, myvalue.y * value, myvalue.z * value)
end

metatable_vector3.__unm = function(myvalue)
    return Vector3.new( -myvalue.x, -myvalue.y, -myvalue.z)
end

function Vector3.new(x ,y, z)
    local v = setmetatable({}, metatable_vector3);
    v.x = x or 0;
    v.y = y or 0;
    v.z = z or 0;

    v.renderid = Render.Vector3Id
    return v;
end

function Vector3:length()
    return math.sqrt(math.pow(self.x, 2) + math.pow(self.y, 2), math.pow(self.z, 2));
end
function Vector3:normalize()
    local w =  self:length()--math.sqrt(math.pow(self.x, 2) + math.pow(self.y, 2), math.pow(self.z, 2));
    if not w or w == 0 then
        return;
    end

    self.x = self.x  / w;
    self.y = self.y  / w;
    self.z = self.z  / w;

    return self
end

function Vector3:mulSelf(value)
    self.x = self.x  * value;
    self.y = self.y  * value;
    self.z = self.z  * value
end

function Vector3:set(value)
    self.x = value.x
    self.y = value.y
    self.z = value.z 
end

function Vector3:setXYZ(x, y, z)
    self.x = x
    self.y = y
    self.z = z 
end

function Vector3:distanceself()
    return math.sqrt(math.pow(self.x, 2) + math.pow(self.y, 2) + math.pow(self.z, 2))
end

function Vector3:equal(v)
    return math.abs(self.x -v.x ) <= math.cEpsilon and math.abs(self.y -v.y ) <= math.cEpsilon and math.abs(self.z -v.z ) <= math.cEpsilon
end

function Vector3:Cartesian2Spherical( )
	local xx = math.sqrt( self.x * self.x + self.y * self.y + self.z * self.z );
	local yy = xx == 0.0 and 0.0 or math.acos( self.z / xx );
	local zz = ( self.x == 0.0 and self.y == 0.0 ) and 0.0 or math.asin( self.y / math.sqrt( self.x * self.x + self.y * self.y ) );

	if ( self.x < 0.0 ) then
        zz = math.pi - zz;
    end

	if ( zz < 0.0 ) then
        zz = zz + math.pi * 2;
    end

    self.x = xx;
	self.y = yy;
    self.z = zz;
    
    return self
end

function Vector3:Spherical2Cartesian( )

	local xx = self.x * math.sin( self.y ) * math.cos( self.z );
	local yy = self.x * math.sin( self.y ) * math.sin( self.z );
	local zz = self.x * math.cos( self.y );

	self.x = xx;
	self.y = yy;
    self.z = zz;
    
    return self
end

function Vector3:negativeSelf(v)
    self.x = -self.x
    self.y = -self.y
    self.z = -self.z
end

function Vector3.negative(v)
    return Vector3.new(-v.x, -v.y, -v.z)
end

-- Vector3& Vector3::Cartesian2Cylindrical( )
-- {
-- 	_float xx = Math::Atan( y / x );
-- 	_float yy = Math::Sqrt( x * x + y * y );

-- 	if ( x < 0.0f )
-- 		xx += Math::cPi;

-- 	x = xx;
-- 	y = yy;

-- 	return *this;
-- }

-- Vector3& Vector3::Cylindrical2Cartesian( )
-- {
-- 	_float xx = y * Math::Cos( x );
-- 	_float yy = y * Math::Sin( x );

-- 	x = xx;
-- 	y = yy;

-- 	return *this;
-- }
    
Vector3.mul = function(a, value)
    return Vector3.new(a.x *value, a.y * value, a.z * value);
end

Vector3.sub = function(a, b)
    return Vector3.new(a.x - b.x, a.y - b.y, a.z - b.z);
end

Vector3.add = function(a, b)
    return Vector3.new(a.x + b.x, a.y + b.y, a.z + b.z);
end
    
Vector3.distance = function(v1, v2)
    return math.sqrt(math.pow(v1.x - v2.x, 2) + math.pow(v1.y - v2.y, 2) +  math.pow(v1.z - v2.z, 2))
end

Vector3.dot = function(v1, v2)
    return v1.x * v2.x + v1.y * v2.y + v1.z * v2.z;
end

-- function SubtractVector(v1, v2)
--     return {v1[1] - v2[1], v1[2] - v2[2], v1[3] - v2[3]}
-- end

-- function DotProduct(a,b)
--     return a[1]*b[1] + a[2]*b[2] + a[3]*b[3]
-- end

Vector3.cross = function(a,b)
    local result = Vector3.new(
        a.y*b.z - a.z*b.y,
        a.z*b.x - a.x*b.z,
        a.x*b.y - a.y*b.x
)
    return result
end


Vector3.cOrigin = Vector3.new(0, 0, 0)