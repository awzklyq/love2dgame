_G.Vector4 = {}

function Vector4.new(x ,y, z, w)
    local v = setmetatable({}, {__index = Vector4});
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