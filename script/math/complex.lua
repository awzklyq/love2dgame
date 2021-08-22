_G.Complex = {}

local metatable_complex = {}
metatable_complex.__index = Complex

metatable_complex.__add = function(myvalue, value)
    return Complex.new(myvalue.real + value.real, myvalue.imag + value.imag)
end

metatable_complex.__sub = function(myvalue, value)
    return Complex.new(myvalue.real - value.real, myvalue.imag - value.imag)
end

metatable_complex.__mul = function(myvalue, value)
    if type(value) == "number" then
        return Complex.new(myvalue.real * value, myvalue.imag * value)
    else
        return Complex.new(myvalue.real * value.real - myvalue.imag * value.imag, myvalue.imag * value.real + myvalue.real * value.imag)
    end
    
end

-- metatable_complex.__unm = function(myvalue)
--     return Complex.new( -myvalue.real, -myvalue.imag)
-- end

metatable_complex.__div = function(myvalue, value)
    return Complex.new((myvalue.real * value.real + myvalue.imag * value.imag) / (math.pow(value.real, 2) + math.pow(value.imag, 2)),
     (myvalue.imag * value.real - myvalue.real * value.imag) / (math.pow(value.real, 2) + math.pow(value.imag, 2)))
end

function Complex.new(real ,imag)
    local v = setmetatable({}, metatable_complex);
    v.real = real or 0;
    v.imag = imag or 0;
    return v;
end

function Complex.exp(value)
    return Complex.new(math.exp(value.real) * math.cos(value.imag), math.exp(value.real) * math.sin(value.imag))
end
