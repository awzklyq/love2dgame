_G.Quaternion = {}
Quaternion._Meta = {}
Quaternion._Meta.__index = Quaternion
Quaternion._Meta.__add = function(myvalue, value)
    if value.renderid == Render.QuaternionID then
        return Quaternion.Add(myvalue, value)
    end
    _errorAssert(false)
end

Quaternion._Meta.__sub = function(myvalue, value)
    if value.renderid == Render.QuaternionID then
        return Quaternion.Sub(myvalue, value)
    end
    _errorAssert(false)
end

Quaternion._Meta.__eq = function(myvalue, value)
    if value.renderid == Render.QuaternionID then
        return Quaternion.Equals(myvalue, value)
    end
    _errorAssert(false)
end

Quaternion._Meta.__mul = function(myvalue, value)
    if value.renderid == Render.QuaternionID then
        return Quaternion.Mul(myvalue, value)
    elseif tonumber(value) ~= nil then
         return Quaternion.new(myvalue.x * value, myvalue.y * value, myvalue.z * value, myvalue.w * value)   
    end
    _errorAssert(false)
end

local _Tolerance = math.MinNumber
function Quaternion.new(InX, InY, InZ, InW)
    local quat = setmetatable({}, Quaternion._Meta)

    quat.x = InX or 0
    quat.y = InY or 0
    quat.z = InZ or 0
    quat.w = InW or 1

    quat.renderid = Render.QuaternionID
    return quat
end

function Quaternion.CreateFromAxisAndAngle(InVec3, InAngle)
    InAngle = math.rad(InAngle)
    local half_a = 0.5 * InAngle;

    local s = math.sin(half_a)
    local c = math.cos(half_a)

    local X = s * InVec3.x;
    local Y = s * InVec3.y;
    local Z = s * InVec3.z;
    local W = c;

    return Quaternion.new(X, Y, Z, W)
end

function Quaternion.Equals(InThis, InOther)
    return (math.abs(InThis.x - InOther.x) <= _Tolerance and math.abs(InThis.y - InOther.y) <= _Tolerance and math.abs(InThis.z - InOther.z) and _Tolerance and math.abs(InThis.w - InOther.w) <= _Tolerance) or ( math.abs(InThis.x + InOther.x) <= _Tolerance and math.abs(InThis.y +  InOther.y) <= _Tolerance and math.abs(InThis.z +  InOther.z) and _Tolerance and math.abs(InThis.w +  InOther.w) <= _Tolerance)
end

function Quaternion.Add(InThis, InOther)
    return Quaternion.new(InThis.x + InOther.x, InThis.y + InOther.y, InThis.z + InOther.z, InThis.w + InOther.w)
end

function Quaternion.Sub(InThis, InOther)
    return Quaternion.new(InThis.x - InOther.x, InThis.y - InOther.y, InThis.z - InOther.z, InThis.w - InOther.w)
end

function Quaternion.Dot(InThis, InOther)
    return InThis.x * InOther.x + InThis.y * InOther.y + InThis.z * InOther.z + InThis.w * InOther.w;
end

function Quaternion.Mul(InThis, InOther)
    local _NewQuat = Quaternion.new()
    _NewQuat.w = InThis.w * InOther.w - InThis.x * InOther.x -  InThis.y * InOther.y - InThis.z * InOther.z

    _NewQuat.x = InThis.w * InOther.x +  InThis.x * InOther.w + InThis.y * InOther.z - InThis.z * InOther.y

    _NewQuat.y = InThis.w * InOther.y +  InThis.y * InOther.w + InThis.z * InOther.x - InThis.x * InOther.z

    _NewQuat.z = InThis.w * InOther.z +  InThis.z * InOther.w + InThis.x * InOther.y - InThis.y * InOther.x

    return _NewQuat
end

function Quaternion:Length()
    return math.sqrt(self.x * self.x + self.y * self.y + self.z * self.z + self.w * self.w);
end

function Quaternion:Normalize()
    local _Len = self:Length()
    if _Len >= _Tolerance then
        local InvLen = 1.0 / _Len
        self.x = self.x * InvLen
        self.y = self.y * InvLen
        self.z = self.z * InvLen
        self.w = self.w * InvLen
        return self
    end
    self.x = 0
    self.y = 0 
    self.z = 0
    self.w = 0
    return self
end

Quaternion.Identity = Quaternion.new(0, 0, 0, 1)