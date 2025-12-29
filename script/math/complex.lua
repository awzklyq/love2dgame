_G.Complex = {}
local _Tolerance = math.MinNumber
local metatable_complex = {}
metatable_complex.__index = Complex

metatable_complex.__add = function(myvalue, value)
    if value.renderid == Render.ComplexID then
        return Complex.new(myvalue.real + value.real, myvalue.imag + value.imag)
    end

    _errorAssert(false)
end

metatable_complex.__sub = function(myvalue, value)
    if value.renderid == Render.ComplexID then
        return Complex.new(myvalue.real - value.real, myvalue.imag - value.imag)
    end

    _errorAssert(false)
end

metatable_complex.__mul = function(myvalue, value)
    if type(value) == "number" then
        return Complex.new(myvalue.real * value, myvalue.imag * value)
    elseif  value.renderid == Render.ComplexID then
        return Complex.new(myvalue.real * value.real - myvalue.imag * value.imag, myvalue.imag * value.real + myvalue.real * value.imag)
    end
    _errorAssert(false)
end

-- metatable_complex.__unm = function(myvalue)
--     return Complex.new( -myvalue.real, -myvalue.imag)
-- end

metatable_complex.__div = function(myvalue, value)
    if type(value) == "number" then
        return Complex.new(myvalue.real / value, myvalue.imag / value)
    elseif value.renderid == Render.ComplexID then
        return Complex.new((myvalue.real * value.real + myvalue.imag * value.imag) / (math.pow(value.real, 2) + math.pow(value.imag, 2)),
        (myvalue.imag * value.real - myvalue.real * value.imag) / (math.pow(value.real, 2) + math.pow(value.imag, 2)))
    end

    _errorAssert(false)
end

function Complex.new(real ,imag)
    local v = setmetatable({}, metatable_complex);
    v.real = real or 0;
    v.imag = imag or 0;
    v.renderid = Render.ComplexID
    return v;
end

function Complex.CreateFromAngle(InAngle)
    InAngle = math.rad(InAngle)

    return Complex.new(math.cos(InAngle) ,math.sin(InAngle))
end


function Complex.exp(value)
    if type(value) == "number" then
        return Complex.CreateFromAngle(math.deg(value))
    else
        return Complex.new(math.exp(value.real) * math.cos(value.imag), math.exp(value.real) * math.sin(value.imag))
    end
end

Complex.Exp = Complex.exp


function Complex:SquaredLength()
    return math.sqrt(self.real * self.real + self.imag * self.imag)
end

function Complex:Normalize()
    local _Len = self:SquaredLength()
    if _Len >=_Tolerance then
        self.real = self.real / _Len
        self.imag = self.imag / _Len
        return self
    end

    self.real = 0
    self.imag = 0
    return self
end

function Complex:IsNormalized()
    return math.abs(1.0 - self:SquaredLength()) < _Tolerance
end

function Complex:GetReal()
    return self.real
end

function Complex:GetImag()
    return self.imag
end

function Complex:ToMatrix2D()
    if self:IsNormalized() == false then
        self:Normalize()
    end

    local _NewMat = Matrix2D.Identity()
    _NewMat:RotationComplex(self)
    return _NewMat
end

function Complex:AsVector()
    return Vector.new(self.real, self.imag)
end

function Complex:AsPoint()
    return Point2D.new(self.real, self.imag)
end

function Complex:Conjugate()
    return Complex.new(self.real, -self.imag)
end

function Complex:Log(InV)
    InV = InV or ""
    log(tostring(InV) .. ' Complex:', self.real, self.imag)
end

function Complex:GetAngle()
    local _Len = self:SquaredLength()
    return math.deg(math.atan2(self.imag / _Len, self.real / _Len))
end

function Complex:GetAngle_Rad()
    local _Len = self:SquaredLength()
    return math.atan2(self.imag / _Len, self.real / _Len)
end