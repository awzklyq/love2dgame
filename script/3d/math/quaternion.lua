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
    elseif value.renderid == Render.Matrix3DId then
        local _NewQuat = Quaternion.Copy(myvalue)
        return _NewQuat:MulMatrix3DRight(value)
    end
    _errorAssert(false)
end

Quaternion._Meta.__unm = function(myvalue)
    return Quaternion._Meta.new( -myvalue.x, -myvalue.y, -myvalue.z, -myvalue.w)
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

function Quaternion.CreateFromMatrix3(ImMat)
    -- Algorithm in Ken Shoemake's article in 1987 SIGGRAPH course notes
	-- article "TQuaternion Calculus and Fast Animation".
    -- If Matrix is NULL, return Identity quaternion. If any of them is 0, you won't be able to construct rotation
	-- if you have two plane at least, we can reconstruct the frame using cross product, but that's a bit expensive op to do here
	-- for now, if you convert to matrix from 0 scale and convert back, you'll lose rotation. Don't do that. 
	if ImMat:GetScaleX() < _Tolerance or ImMat:GetScaleY() < _Tolerance or ImMat:GetScaleZ() < _Tolerance then
		return Quaternion.Copy(Quaternion.Identity)
    end

    local tr = ImMat:GetData(1, 1) + ImMat:GetData(2, 2) + ImMat:GetData(3, 3)

    local s

    local _NewQuat = Quaternion.new()
    if tr > 0.0 then
	
		local InvS = 1.0 / math.sqrt(tr + 1.0);
		_NewQuat.w = 0.5 * (1.0 / InvS);
		s = 0.5 * InvS;

		_NewQuat.x = (ImMat:GetData(2,3) - ImMat:GetData(3,2)) * s
		_NewQuat.y = (ImMat:GetData(3,1) - ImMat:GetData(1,3)) * s
		_NewQuat.z = (ImMat:GetData(1,2) - ImMat:GetData(2,1)) * s
	else
        -- diagonal is negative
		local i = 1;

		if ImMat:GetData(2, 2) > ImMat:GetData(1, 1) then
			i = 2;
        end

		if  ImMat:GetData(3, 3) >  ImMat:GetData(i, i) then
			i = 3;
        end

		local nxt = { 2, 3, 1 };
		local j = nxt[i];
		local k = nxt[j];
 
		s = ImMat:GetData(i, i) - ImMat:GetData(j, j) - ImMat:GetData(k, k) +  1.0

		local InvS = 1.0 / math.sqrt(s);

		local qt = {};
		qt[i] = 0.5 * (1.0 / InvS)

		s = 0.5 * InvS;

		qt[4] = (ImMat:GetData(j, k) - ImMat:GetData(k, j)) * s;
		qt[j] = (ImMat:GetData(i, j) + ImMat:GetData(j, i)) * s;
		qt[k] = (ImMat:GetData(i, k) + ImMat:GetData(k, i)) * s;

		_NewQuat.x = qt[1];
		_NewQuat.y = qt[2];
		_NewQuat.z = qt[3];
		_NewQuat.w = qt[4];
    end

    return _NewQuat
end

function Quaternion:IsNormalized()
    return math.abs(1.0 - self:SquaredLength()) < _Tolerance
end

function Quaternion:ToMatrix()
    if self:IsNormalized() then
        self:Normalize()
    end

    local X = self.x
    local Y = self.y
    local Z = self.z
    local W = self.w

    local x2 = X + X;    local y2 = Y + Y;    local z2 = Z + Z;
    local xx = X * x2;   local xy = X * y2;   local xz = X * z2;
    local yy = Y * y2;   local yz = Y * z2;   local zz = Z * z2;
    local wx = W * x2;   local wy = W * y2;   local wz = W * z2;

    local _NewMat = Matrix3D.new()
    _NewMat:SetData(1, 1, 1.0 - (yy + zz))	 _NewMat:SetData(2, 1, xy - wz)				_NewMat:SetData(3, 1, xz + wy)			_NewMat:SetData(4, 1, 0.0)
    _NewMat:SetData(1, 2, xy + wz)			_NewMat:SetData(2, 2, 1.0 - (xx + zz))		_NewMat:SetData(3, 2, yz - wx)			_NewMat:SetData(4, 2, 0.0)
    _NewMat:SetData(1, 3, xz - wy)			_NewMat:SetData(2, 3, yz + wx)				_NewMat:SetData(3, 3, 1.0 - (xx + yy))	_NewMat:SetData(4, 3, 0.0)
    _NewMat:SetData(1, 4, 0.0)				_NewMat:SetData(2, 4, 0.0)					_NewMat:SetData(3, 4, 0.0)				_NewMat:SetData(4, 4, 1.0)

    return _NewMat
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

function Quaternion.Slerp(InThis, InOther, InT)
    local From = Quaternion.Copy(InThis):Normalize()
    local To = Quaternion.Copy(InOther):Normalize()

    local cs = Quaternion.Dot(From, To)

    -- Q and -Q are equivalent, but if we try to Slerp between them we will get nonsense instead of 
	-- just returning Q. Depending on how the Quaternion was constructed it is possible
	-- that the sign flips. So flip it back.
	if cs < -0.99 then
		From = -From
    end

    local _NewQuat = Quaternion.new()
    local angle = math.acos(cs);
	if math.abs(angle) >= _Tolerance then
	
		local sn = math.sin(angle);
		local invSn = 1.0 / sn;
		local tAngle = InT * angle;
		local coeff0 = math.sin(angle - tAngle) * invSn;
		local coeff1 = math.sin(tAngle) * invSn;
		_NewQuat.x = coeff0 * From.x + coeff1 * To.x;
		_NewQuat.y = coeff0 * From.y + coeff1 * To.y;
		_NewQuat.z = coeff0 * From.z + coeff1 * To.z;
		_NewQuat.w = coeff0 * From.w + coeff1 * To.w;
	else 
	
		_NewQuat:Set(From)
    end

    return _NewQuat
end


function Quaternion.Mul(InThis, InOther)
    local _NewQuat = Quaternion.new()
    _NewQuat.w = InThis.w * InOther.w - InThis.x * InOther.x -  InThis.y * InOther.y - InThis.z * InOther.z

    _NewQuat.x = InThis.w * InOther.x +  InThis.x * InOther.w + InThis.y * InOther.z - InThis.z * InOther.y

    _NewQuat.y = InThis.w * InOther.y +  InThis.y * InOther.w + InThis.z * InOther.x - InThis.x * InOther.z

    _NewQuat.z = InThis.w * InOther.z +  InThis.z * InOther.w + InThis.x * InOther.y - InThis.y * InOther.x

    return _NewQuat
end

function Quaternion.Copy(InOther)
    return Quaternion.new(InOther.x, InOther.y, InOther.z, InOther.w)
end

function Quaternion:SquaredLength()
    return self.x * self.x + self.y * self.y + self.z * self.z + self.w * self.w    
end

function Quaternion:Inverse()
    local norm = self:SquaredLength()

	if norm > 0 then 
		local invNorm = 1.0 / norm
		return Quaternion.new(-self.x * invNorm, -self.y * invNorm, -self.z * invNorm, self.w * invNorm)
    end

	return Quaternion.Copy(Quaternion.Zero)
end

function Quaternion:Set(InOther)
    self.x = InOther.x
    self.y = InOther.y
    self.z = InOther.z
    self.w = InOther.w
    return self
end

function Quaternion:Length()
    return math.sqrt(self.x * self.x + self.y * self.y + self.z * self.z + self.w * self.w);
end

function Quaternion:MulMatrix3DRight(InMat)
   local _Quat = InMat:GetQuaternion()
    self:Set(self * _Quat)
    return self
end

function Quaternion:MulMatrix3DLeft(InMat)
   local _Quat = InMat:GetQuaternion()
    self:Set(_Quat * self )
    return self
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

function Quaternion:GetX()
    return self.x    
end

function Quaternion:GetY()
    return self.y    
end

function Quaternion:GetZ()
    return self.z    
end

function Quaternion:GetW()
    return self.w    
end



Quaternion.Identity = Quaternion.new(0, 0, 0, 1)
Quaternion.Zero = Quaternion.new(0, 0, 0, 0)