_G.Point3D = {}
__setParentFunction(Point3D, _G.Vector3)


local metatable_point3d = {}
metatable_point3d.__index = Point3D

metatable_point3d.__add = function(myvalue, value)
    return Point3D.new(myvalue.x + value.x, myvalue.y + value.y, myvalue.z + value.z)
end

metatable_point3d.__sub = function(myvalue, value)
    return Point3D.new(myvalue.x - value.x, myvalue.y - value.y, myvalue.z - value.z)
end

metatable_point3d.__mul = function(myvalue, value)
    if type(value) == "number" then
        return Point3D.new(myvalue.x * value, myvalue.y * value, myvalue.z * value)
    elseif  type(value) == "table" and value.renderid == Render.Point3Id then
        return Point3D.new(myvalue.x * value.x, myvalue.y * value.y, myvalue.z * value.z)
    else
        _errorAssert(false, "metatable_point3d.__mul~")
    end
end

metatable_point3d.__unm = function(myvalue)
    return Point3D.new( -myvalue.x, -myvalue.y, -myvalue.z)
end

metatable_point3d.__div = function(myvalue, value)
    if type(value) == "number" then
        return Point3D.new(myvalue.x / value, myvalue.y / value, myvalue.z / value)
    elseif  type(value) == "table" and value.renderid == Render.Point3Id then
        return Point3D.new(myvalue.x / value.x, myvalue.y / value.y, myvalue.z / value.z)
    else
        _errorAssert(false, "metatable_point3d.__div~")
    end 
end

metatable_point3d.__eq = function(myvalue, value)
    return (myvalue.x == value.x and  myvalue.y == value.y and myvalue.z == value.z)
end

function Point3D.new(x, y, z)
    local point = setmetatable({}, metatable_point3d);

    point.x = x or 0
    point.y = y or 0
    point.z = z or 0

    point.renderid = Render.Point3Id

    point.Faces = {}

    point.Edges = {}

    return point
end

function Point3D:CovertVector4()
    return Vector4.new(self.x, self.y, self.z, 1)
end

function Point3D:CovertVector3()
    return Vector3.new(self.x, self.y, self.z)
end

function Point3D:Log(sss)
    log("Point3D ", sss)
    log(self.x, self.y, self.z)
end