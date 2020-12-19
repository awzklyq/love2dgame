_G.Vector3 = {}

function Vector3.new(x ,y, z)
    local v = setmetatable({}, {__index = Vector3});
    v.x = x or 0;
    v.y = y or 0;
    v.z = z or 0;
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
end

function Vector3:mul(value)
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
