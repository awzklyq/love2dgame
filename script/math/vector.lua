_G.Vector = {}

local metatable_vector = {}
metatable_vector.__index = Vector

metatable_vector.__add = function(myvalue, value)
    if type(value) == "number" then
        return Vector.new(myvalue.x + value, myvalue.y + value)
    else
        return Vector.new(myvalue.x + value.x, myvalue.y + value.y)
    end
end

metatable_vector.__sub = function(myvalue, value)
    if type(value) == "number" then
        return Vector.new(myvalue.x - value, myvalue.y - value)
    else
        return Vector.new(myvalue.x - value.x, myvalue.y - value.y)
    end
end

metatable_vector.__mul = function(myvalue, value)
    if type(value) == 'table' then
        if value.renderid == Render.Matrix2DId then
            return value:MulLeftVector2(myvalue)
        elseif value.renderid == Render.Vector2Id then
            return Vector.new(myvalue.x * value.x, myvalue.y * value.y)
        else
            _errorAssert(false, 'function metatable_vector.__mul')
        end
    else
        return Vector.new(myvalue.x * value, myvalue.y * value)
    end
end

metatable_vector.__unm = function(myvalue)
    return Vector.new( -myvalue.x, -myvalue.y)
end

metatable_vector.__div = function(myvalue, value)
    if type(value) == "number" then
        return Vector.new(myvalue.x / value, myvalue.y / value)
    elseif  type(value) == "table" and value.renderid == Render.Vector2Id then
        return Vector.new(myvalue.x / value.x, myvalue.y / value.y)
    else
        _errorAssert(false, "metatable_vector2.__div~")
    end  
   
end

metatable_vector.__eq = function(myvalue, value)
    return myvalue.x == value.x and myvalue.y == value.y
end

metatable_vector.__call = function(mytable, x, y)
    _errorAssert(type(x) == 'number' and type(y) == 'number',  'metatable_vector.__call x, y')
    mytable.x = x
    mytable.y = y
end

function Vector.new(x ,y)
    local v = setmetatable({}, metatable_vector);
    v.x = x or 0;
    v.y = y or 0;

    v.renderid = Render.Vector2Id

    return v;
end

function Vector:Log(info)
    if not info then
        info = ""
    end
    log(info, "Vector X, Y :", self.x, self.y)
end

function Vector:length()
    return math.sqrt(math.pow(self.x, 2) + math.pow(self.y, 2));
end
function Vector:normalize()
    local w =  math.sqrt(math.pow(self.x, 2) + math.pow(self.y, 2));
    if not w or w == 0 then
        return self;
    end

    self.x = self.x  / w;
    self.y = self.y  / w;

    return self
end

Vector.Normalize = Vector.normalize

function Vector:mul(value)
    self.x = self.x  * value;
    self.y = self.y  * value;
end

function Vector:draw()
    if not self.rect then
        self.rect =  Rect.new(self.x - 4, self.y - 4, 4, 4)
        self.rect:SetColor(0,0,255)
    end

    self.rect:draw()
end

function Vector:IsZero()
    return self.x == 0 and self.y == 0
end

function Vector:GetMortonCode2()
    local Morton = math.MortonCode2( math.round(self.x) );
    Morton = math.BitOr(Morton, math.LeftMove(math.MortonCode2( math.round(self.y) ) ,1));
    return Morton
end

function Vector:Set(v)
    self.x = v.x
    self.y = v.y
end

function Vector:GetNearPoint(v1, v2)

    if Vector.distance(self, v1) < Vector.distance(self, v2) then
        return v1
    else
        return v2
    end
end

function Vector:GetFarPoint(v1, v2)

    if Vector.distance(self, v1) < Vector.distance(self, v2) then
        return v2
    else
        return v1
    end
end

function Vector:RotateClockwise(angle)
    local radianAngle = math.rad(angle)

    local cosTheta = math.cos(-radianAngle)
    local sinTheta = math.sin(-radianAngle)

    local x = self.x
    local y = self.y

    local xRotated = x * cosTheta - y * sinTheta
    local yRotated = x * sinTheta + y * cosTheta

    self.x = xRotated
    self.y = yRotated

    return self
end

Vector.set = Vector.Set
Vector.distance = function(v1, v2)
    return math.sqrt(math.pow(v1.x - v2.x, 2) + math.pow(v1.y - v2.y, 2))
end

Vector.Distance = Vector.distance 

Vector.dot = function(v1, v2)
    return v1.x * v2.x + v1.y * v2.y;
end

Vector.cross = function(v1, v2)
    return v1.x * v2.y - v2.x * v1.y
end

Vector.angle = function(v1, v2)
    local v11 = Vector.new(v1.x, v1.y);
    v11:normalize( );

    local v22 = Vector.new(v2.x, v2.y)
    v22:normalize( );
    local dot = Vector.dot(v11, v22);

    return math.acos(dot);
end

Vector.angleX = function(v1)
    local v11 = Vector.new(v1.x, v1.y);
    v11:normalize( );

    if v11.y >= 0 then
        return math.acos(v11.x);
    elseif v11.y < 0 then
        return math.c2pi - math.acos(v11.x);
    end
end

Vector.angleClockwise = function(v1, v2)
    local a1 = Vector.angleX(v1)
    local a2 = Vector.angleX(v2)

    if a2 > a1 then
        return math.c2pi - (a2 - a1)
    else
        return a1 - a2
    end
end

Vector.copy = function(v)
    return Vector.new(v.x, v.y)
end

Vector.abs = function(v)
    return Vector.new(math.abs(v.x), math.abs(v.y))
end

Vector.Copy = Vector.copy  



    