_G.Vector = {}

local metatable_vector = {}
metatable_vector.__index = Vector

metatable_vector.__add = function(myvalue, value)
    return Vector.new(myvalue.x + value.x, myvalue.y + value.y)
end

metatable_vector.__sub = function(myvalue, value)
    return Vector.new(myvalue.x - value.x, myvalue.y - value.y)
end

metatable_vector.__mul = function(myvalue, value)
    return Vector.new(myvalue.x * value, myvalue.y * value)
end

metatable_vector.__unm = function(myvalue)
    return Vector.new( -myvalue.x, -myvalue.y)
end

metatable_vector.__div = function(myvalue, value)
    return Vector.new(myvalue.x / value, myvalue.y / value)
end

function Vector.new(x ,y)
    local v = setmetatable({}, metatable_vector);
    v.x = x or 0;
    v.y = y or 0;
    return v;
end

function Vector:length()
    return math.sqrt(math.pow(self.x, 2) + math.pow(self.y, 2));
end
function Vector:normalize()
    local w =  math.sqrt(math.pow(self.x, 2) + math.pow(self.y, 2));
    if not w or w == 0 then
        return;
    end

    self.x = self.x  / w;
    self.y = self.y  / w;
end

function Vector:mul(value)
    self.x = self.x  * value;
    self.y = self.y  * value;
end
    
Vector.distance = function(v1, v2)
    return math.sqrt(math.pow(v1.x - v2.x, 2) + math.pow(v1.y - v2.y, 2))
end

Vector.dot = function(v1, v2)
    return v1.x * v2.x + v1.y * v2.y;
end

Vector.angle = function(v1, v2)
    local v11 = Vector.new(v1.x, v1.y);
    v11:normalize( );

    local v22 = Vector.new(v2.x, v2.y)
    v2:normalize( );
    local dot = Vector.dot(v11, v22);

    return math.acos(dot);
end

Vector.copy = function(v)
    return Vector.new(v.x, v.y)
end



    