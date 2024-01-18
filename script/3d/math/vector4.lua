_G.Vector4 = {}

local metatable_vector4 = {}
metatable_vector4.__index = Vector4

metatable_vector4.__add = function(myvalue, value)
    if type(value) == "number" then
        return Vector4.new(myvalue.x + value, myvalue.y + value, myvalue.z + value, myvalue.w + value)
    else
        return Vector4.new(myvalue.x + value.x, myvalue.y + value.y, myvalue.z + value.z, myvalue.w + value.w)
    end
   
end

metatable_vector4.__sub = function(myvalue, value)

    if type(value) == "number" then
        return Vector4.new(myvalue.x - value, myvalue.y - value, myvalue.z - value, myvalue.w - value)
    else
        return Vector4.new(myvalue.x - value.x, myvalue.y - value.y, myvalue.z - value.z, myvalue.w - value.w)
    end
    
end

metatable_vector4.__mul = function(myvalue, value)
    if type(value) == "number" then
        return Vector4.new(myvalue.x * value, myvalue.y * value, myvalue.z * value, myvalue.w * value)
    elseif  type(value) == "table" then
        if value.renderid == Render.Vector4Id then
            return Vector4.new(myvalue.x * value.x, myvalue.y * value.y, myvalue.z * value.z, myvalue.w * value.w)
        elseif value.renderid == Render.Matrix3DId then
            local result = Vector4.Copy(myvalue)
            return result:mulMatrix(value)
        end
    else
        _errorAssert(false, "metatable_vector4.__mul~")
    end
        
end

metatable_vector4.__unm = function(myvalue)
    return Vector4.new( -myvalue.x, -myvalue.y, -myvalue.z, -myvalue.w)
end

metatable_vector4.__div = function(myvalue, value)
    if type(value) == "number" then
        return Vector4.new(myvalue.x / value, myvalue.y / value, myvalue.z / value, myvalue.w / value)
    elseif  type(value) == "table" and value.renderid == Render.Vector4Id then
        return Vector4.new(myvalue.x / value.x, myvalue.y / value.y, myvalue.z / value.z, myvalue.w / value.w)
    else
        _errorAssert(false, "metatable_vector4.__div~")
    end 
end

function Vector4.new(x ,y, z, w)
    local v = setmetatable({}, metatable_vector4);
    v.x = x or 0;
    v.y = y or 0;
    v.z = z or 0;
    v.w = w or 1;
    v.renderid = Render.Vector4Id
    return v;
end

function Vector4:mulMatrix(mat)
    local xx = self.x
    local yy = self.y
    local zz = self.z
    local ww = self.w

    self.x = xx * mat:getData(1,1) + yy * mat:getData(2,1) + zz * mat:getData(3,1) + ww * mat:getData(4,1);
	self.y = xx * mat:getData(1,2) + yy * mat:getData(2,2) + zz * mat:getData(3,2) + ww * mat:getData(4,2);
	self.z = xx * mat:getData(1,3) + yy * mat:getData(2,3)+ zz * mat:getData(3,3) + ww * mat:getData(4,3);
    self.w = xx * mat:getData(1,4) + yy * mat:getData(2,2) + zz * mat:getData(3,4) + ww * mat:getData(4,4);
    return self
end

function Vector4:GetVector3()
    return Vector3(self.x, self.y, self.z)
end

function Vector4:Log(sss)
    log("Vector4 ", sss)
    log(self.x, self.y, self.z, self.w)
end

Vector4.dot = function(v1, v2)
    return v1.x * v2.x + v1.y * v2.y + v1.z * v2.z + v1.w * v2.w;
end
Vector4.dot3 = function(v1, v2)
    return v1.x * v2.x + v1.y * v2.y + v1.z * v2.z;
end

function Vector4.Copy(v)
    return Vector4.new(v.x ,v.y, v.z, v.w)
end