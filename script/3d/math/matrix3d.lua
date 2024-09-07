_G.Matrix3D = {}


local metatable_Matrix3D = {}
metatable_Matrix3D.__index = Matrix3D

metatable_Matrix3D.__add = function(myvalue, value)
    return Matrix3D.createFromNumbers(myvalue[1] + value[1], myvalue[2] + value[2], myvalue[3] + value[3], myvalue[4] + value[4],
								myvalue[5] + value[5], myvalue[6] + value[6], myvalue[7] + value[7], myvalue[8] + value[8],
								myvalue[9] + value[9], myvalue[10] + value[10], myvalue[11] + value[11], myvalue[12] + value[12],
								myvalue[13] + value[13], myvalue[14] + value[14], myvalue[15] + value[15], myvalue[16] + value[16])
end

metatable_Matrix3D.__div = function(myvalue, value)
    return Matrix3D.createFromNumbers(myvalue[1] / value, myvalue[2] / value, myvalue[3] / value, myvalue[4] / value,
								myvalue[5] / value, myvalue[6] / value, myvalue[7] / value, myvalue[8] / value,
								myvalue[9] / value, myvalue[10] / value, myvalue[11] / value, myvalue[12] / value,
								myvalue[13] / value, myvalue[14] / value, myvalue[15] / value, myvalue[16] / value)
end

metatable_Matrix3D.__eq = function(myvalue, value)
    return (myvalue[1] == value[1] and myvalue[2] == value[2] and myvalue[3] == value[3] and myvalue[4] == value[4] and
	myvalue[5] == value[5] and myvalue[6] == value[6] and myvalue[7] == value[7] and myvalue[8] == value[8] and
	myvalue[9] == value[9] and myvalue[10] == value[10] and myvalue[11] == value[11] and myvalue[12] == value[12] and
	myvalue[13] == value[13] and myvalue[14] == value[14] and myvalue[15] == value[15] and myvalue[16] == value[16])
end
	
-- metatable_Matrix3D.__sub = function(myvalue, value)
--     return Vector3.new(myvalue.x - value.x, myvalue.y - value.y, myvalue.z - value.z)
-- end

metatable_Matrix3D.__mul = function(myvalue, value)

    if  type(value) == "table" then
		local mat = Matrix3D.copy(myvalue)
		if value.renderid == Render.Matrix3DId then
			mat:mulRight(value)
			return mat--Matrix3D.matrixMult(myvalue, value)
		elseif value.renderid == Render.Vector4Id then
			return mat:mulVector4(value)--Matrix3D.matrixMult(myvalue, value
		elseif value.renderid == Render.Vector3Id then
			return mat:mulRightVector3(value)
		elseif value.renderid == Render.Triangle3DId then
			return mat:mulTrangle(value)
		elseif value.renderid == Render.BoundBoxId then
			return mat:mulBoundBox(value)
		end
    else
        _errorAssert(false, "metatable_Matrix3D.__mul~")
    end
end

-- metatable_Matrix3D.__unm = function(myvalue)
--     return Vector3.new( -myvalue.x, -myvalue.y, -myvalue.z)
-- end


Matrix3D.new = function()
    local mat = setmetatable({1,0,0,0,
                            0,1,0,0,
                            0,0,1,0,
                            0,0,0,1}, metatable_Matrix3D);

    mat.translation = Vector3.new();
    mat.rotation = Vector3.new();
    mat.scale = Vector3.new(1,1,1);

	mat.renderid = Render.Matrix3DId

    return mat;
end

Matrix3D.createFromNumbers = function(...)
    local mat = setmetatable({...}, metatable_Matrix3D);

	mat.renderid = Render.Matrix3DId
    return mat;
end

Matrix3D.createFromVectors = function(XAxis, YAxis, ZAxis, WAxis)
	-- return Matrix3D.createFromNumbers(
	-- 	XAxis.x, XAxis.y, XAxis.z, 0,
	-- 	YAxis.x, YAxis.y, YAxis.z, 0,
	-- 	ZAxis.x, ZAxis.y, ZAxis.z, 0,
	-- 	WAxis.x, WAxis.y, WAxis.z, 1

	-- );

	return Matrix3D.createFromNumbers(
		XAxis.x, YAxis.x, ZAxis.x, WAxis.x,
		XAxis.y, YAxis.y, ZAxis.y, WAxis.y,
		XAxis.z, YAxis.z, ZAxis.z, WAxis.z,
		0, 0, 0, 1

	);
end

function Matrix3D:getMatrixXY(x,y)
    return self[x + (y-1)*4]
end

function Matrix3D:GetRotationMatrix()
    local rx = Vector3.new(self[1], self[2], self[3]):Normalize()
	local ry = Vector3.new(self[5], self[6], self[7]):Normalize()
	local rz = Vector3.new(self[9], self[10], self[11]):Normalize()

	return Matrix3D.createFromNumbers(
		rx.x, rx.y, rx.z, 0,
		ry.x, ry.y, ry.z, 0,
		rz.x, rz.y, rz.z, 0,
		0, 0, 0, 1

	);
end


-- return the matrix that results from the two given matrices multiplied together
function Matrix3D.matrixMult(a,b)
    local ret = Matrix3D.new()

    local i = 1
    for y=1, 4 do
        for x=1, 4 do
            ret[i] = ret[i] + a:getMatrixXY(1,y)*b:getMatrixXY(x,1)
            ret[i] = ret[i] + a:getMatrixXY(2,y)*b:getMatrixXY(x,2)
            ret[i] = ret[i] + a:getMatrixXY(3,y)*b:getMatrixXY(x,3)
            ret[i] = ret[i] + a:getMatrixXY(4,y)*b:getMatrixXY(x,4)
            i = i + 1
        end
    end

    return ret
end


-- returns a view matrix
-- eye, target, and down are all 3d vectors
Matrix3D.getViewMatrix = function(eye, look, up)
    local z = Vector3.new(eye.x - look.x, eye.y - look.y, eye.z - look.z)
    z:normalize()
    local x = Vector3.cross(Vector3.new(-up.x, -up.y, -up.z), z)
    x:normalize()
    local y = Vector3.cross(z, x)

    return Matrix3D.createFromNumbers(
        x.x, x.y, x.z, -1*Vector3.dot(x, eye),
        y.x, y.y, y.z, -1*Vector3.dot(y, eye),
        z.x, z.y, z.z, -1*Vector3.dot(z, eye),
        0, 0, 0, 1
)
end


Matrix3D.createLookAtRH = function(  eye, lookat, upaxis )

	local zaxis = ( eye - lookat):normalize( );
	local xaxis = Vector3.cross( upaxis, zaxis ):normalize( );
	local yaxis = Vector3.cross( zaxis, xaxis );

	local xeye = - Vector3.dot( xaxis, eye );
	local yeye = - Vector3.dot( yaxis, eye );
	local zeye = - Vector3.dot( zaxis, eye );

	return Matrix3D.createFromNumbers(
		xaxis.x, yaxis.x, zaxis.x, 0.0,
		xaxis.y, yaxis.y, zaxis.y, 0.0,
		xaxis.z, yaxis.z, zaxis.z, 0.0,
		   xeye,    yeye,    zeye, 1.0 );
end

Matrix3D.createLookAtLH = function(eye, lookat, upaxis )
	local zaxis = ( lookat - eye ):normalize( );
	local xaxis = Vector3.cross( upaxis, zaxis ):normalize( );
	local yaxis = Vector3.cross( zaxis, xaxis );

	local xeye = - Vector3.dot( xaxis, eye );
	local yeye = - Vector3.dot( yaxis, eye );
	local zeye = - Vector3.dot( zaxis, eye );

	return Matrix3D.createFromNumbers(
		xaxis.x, yaxis.x, zaxis.x, 0.0,
		xaxis.y, yaxis.y, zaxis.y, 0.0,
		xaxis.z, yaxis.z, zaxis.z, 0.0,
		   xeye,    yeye,    zeye, 1.0 );
end

function Matrix3D:mulLeftVector3(tab2, NeedNotW)
	local xx, yy, zz = tab2.x, tab2.y, tab2.z
	local mat = self
	local w = xx * mat:getData(1,4) + yy * mat:getData(2,4) + zz * mat:getData(3,4) + mat:getData(4,4)
	local rsult = Vector3.new()
	rsult.x = xx * mat:getData(1,1) + yy * mat:getData(2,1) + zz * mat:getData(3,1) + mat:getData(4,1)
	rsult.y = xx * mat:getData(1,2) + yy * mat:getData(2,2) + zz * mat:getData(3,2) + mat:getData(4,2)
	rsult.z = xx * mat:getData(1,3) + yy * mat:getData(2,3) + zz * mat:getData(3,3) + mat:getData(4,3)

	if  w ~= 0.0 and not NeedNotW then
		local winv = 1.0 / w;
		rsult.x = rsult.x * winv;
		rsult.y = rsult.y * winv;
		rsult.z = rsult.z * winv;
	end
	return rsult
end

function Matrix3D:mulRightVector3(tab2, NeedNotW)
	local xx, yy, zz = tab2.x, tab2.y, tab2.z
	local mat = self
	local w = xx * mat:getData(4,1) + yy * mat:getData(4,2) + zz * mat:getData(4,3) + mat:getData(4,4)
	
	local rsult = Vector3.new()

	rsult.x = xx * mat:getData(1,1) + yy * mat:getData(1,2) + zz * mat:getData(1,3) + mat:getData(1,4)
	rsult.y = xx * mat:getData(2,1) + yy * mat:getData(2,2) + zz * mat:getData(2,3) + mat:getData(2,4)
	rsult.z = xx * mat:getData(3,1) + yy * mat:getData(3,2) + zz * mat:getData(3,3) + mat:getData(3,4)

	if  w ~= 0.0 and not NeedNotW then
		local winv = 1.0 / w;
		rsult.x = rsult.x * winv;
		rsult.y = rsult.y * winv;
		rsult.z = rsult.z * winv;
	end
	return rsult
end

function Matrix3D:mulTrangle(triangle)

	local P1 = self * triangle.P1
	local P2 = self * triangle.P2
	local P3 = self * triangle.P3

	local result = Triangle3D.new(P1, P2, P3)
	return result
end

function Matrix3D:mulVector4(v4)
	local xx, yy, zz, ww = v4.x, v4.y, v4.z, v4.w
	local mat = self
	local rsult = Vector4.new()
	
	rsult.x = xx * mat:getData(1, 1) + yy * mat:getData(1, 2) + zz * mat:getData(1, 3) + mat:getData(1, 4) * ww
	rsult.y = xx * mat:getData(2, 1) + yy * mat:getData(2, 2) + zz * mat:getData(2, 3) + mat:getData(2, 4) * ww
	rsult.z = xx * mat:getData(3, 1) + yy * mat:getData(3, 2) + zz * mat:getData(3, 3) + mat:getData(3 ,4) * ww
	rsult.w = xx * mat:getData(4, 1) + yy * mat:getData(4, 2) + zz * mat:getData(4, 3) + mat:getData(4 ,4) * ww

	return rsult
end

function Matrix3D:mulBoundBox(boundbox, NeedNotW)

	local mat = Matrix3D.transpose(self)

	local box = OrientedBox.buildFormBoundBox(boundbox)

	for i = 1, 8 do
		box.vs[i] = mat:mulLeftVector3(box.vs[i], NeedNotW)
	end

	return box:getBoundBox()
end
		
function Matrix3D:SetTranslation(x, y, z)
	local mm = self
	if type(x) == "table" and x.renderid == Render.Vector3Id then
		mm[13] = x.x
		mm[14] = x.y
		mm[15] = x.z
	else
		mm[13] = x
		mm[14] = y
		mm[15] = z
	end
end
			
function Matrix3D:mulTranslationRight(x, y, z)
	local mm = Matrix3D.new()
	mm:SetTranslation(x, y, z)
	self:mulLeft(Matrix3D.transpose(mm))
end

function Matrix3D:mulRotationRight(x, y, z, r)
	local sinvalue, cosvalue, cosreverse = math.sin( r ), math.cos( r )
	local cosreverse = 1 - cosvalue

	local m = math.sqrt(x*x + y*y + z*z)
	x, y, z = x/m, y/m, z/m

	local mm = Matrix3D.new()
	mm[1] = cosreverse * x * x + cosvalue
	mm[2] = cosreverse * x * y + sinvalue * z
	mm[3] = cosreverse * x * z - sinvalue * y
	mm[4] = 0

	mm[5] = cosreverse * x * y - sinvalue * z
	mm[6] = cosreverse * y * y + cosvalue
	mm[7] = cosreverse * y * z + sinvalue * x
	mm[8] = 0

	mm[9] = cosreverse * x * z + sinvalue * y
	mm[10] = cosreverse * y * z - sinvalue * x
	mm[11] = cosreverse * z * z + cosvalue
	mm[12] = 0

	mm[13] = 0
	mm[14] = 0
	mm[15] = 0
	mm[16] = 1
	self:mulLeft(Matrix3D.transpose(mm))
end

function Matrix3D:mulScalingRight(x, y, z)
	local mm = Matrix3D.new()
	mm[1] = x
	mm[6] = y
	mm[11] = z
	self:mulLeft(Matrix3D.transpose(mm))
end

			
function Matrix3D:mulTranslationLeft(x, y, z)
	local mm = Matrix3D.new()
	mm[13] = x mm[14] = y mm[15] = z
	self:mulRight(Matrix3D.transpose(mm))
end

function Matrix3D:mulRotationLeft(x, y, z, r)
	local sinvalue, cosvalue, cosreverse = math.sin( r ), math.cos( r )
	local cosreverse = 1 - cosvalue

	local m = math.sqrt(x*x + y*y + z*z)
	x, y, z = x/m, y/m, z/m

	local mm = Matrix3D.new()
	mm[1] = cosreverse * x * x + cosvalue
	mm[2] = cosreverse * x * y + sinvalue * z
	mm[3] = cosreverse * x * z - sinvalue * y
	mm[4] = 0

	mm[5] = cosreverse * x * y - sinvalue * z
	mm[6] = cosreverse * y * y + cosvalue
	mm[7] = cosreverse * y * z + sinvalue * x
	mm[8] = 0

	mm[9] = cosreverse * x * z + sinvalue * y
	mm[10] = cosreverse * y * z - sinvalue * x
	mm[11] = cosreverse * z * z + cosvalue
	mm[12] = 0

	mm[13] = 0
	mm[14] = 0
	mm[15] = 0
	mm[16] = 1
	self:mulRight(Matrix3D.transpose(mm))
end

function Matrix3D:mulScalingLeft(x, y, z)
	local mm = Matrix3D.new()
	mm[1] = x
	mm[6] = y
	mm[11] = z
	self:mulRight(Matrix3D.transpose(mm))
end

function Matrix3D:getTranslation()
	return Vector3.new(self[4], self[8], self[12])
end


function Matrix3D:mulRight(tab)
    -- self:transposeSelf()
    -- tab = Matrix3D.transpose(tab)
	local mat = self
	local m00, m01, m02, m03, m10, m11, m12, m13, m20, m21, m22, m23, m30, m31, m32, m33 = mat[1], mat[2], mat[3], mat[4], mat[5], mat[6], mat[7], mat[8], mat[9], mat[10], mat[11], mat[12], mat[13], mat[14], mat[15], mat[16]

	mat[1] = m00 * tab[1] + m01 * tab[5] + m02 * tab[9] + m03 * tab[13]
	mat[2] = m00 * tab[2] + m01 * tab[6] + m02 * tab[10] + m03 * tab[14]
	mat[3] = m00 * tab[3] + m01 * tab[7] + m02 * tab[11] + m03 * tab[15]
	mat[4] = m00 * tab[4] + m01 * tab[8] + m02 * tab[12] + m03 * tab[16]

	mat[5] = m10 * tab[1] + m11 * tab[5] + m12 * tab[9] + m13 * tab[13]
	mat[6] = m10 * tab[2] + m11 * tab[6] + m12 * tab[10] + m13 * tab[14]
	mat[7] = m10 * tab[3] + m11 * tab[7] + m12 * tab[11] + m13 * tab[15]
	mat[8] = m10 * tab[4] + m11 * tab[8] + m12 * tab[12] + m13 * tab[16]

	mat[9] = m20 * tab[1] + m21 * tab[5] + m22 * tab[9] + m23 * tab[13]
	mat[10] = m20 * tab[2] + m21 * tab[6] + m22 * tab[10] + m23 * tab[14]
	mat[11] = m20 * tab[3] + m21 * tab[7] + m22 * tab[11] + m23 * tab[15]
	mat[12] = m20 * tab[4] + m21 * tab[8] + m22 * tab[12] + m23 * tab[16]

	mat[13] = m30 * tab[1] + m31 * tab[5] + m32 * tab[9] + m33 * tab[13]
	mat[14] = m30 * tab[2] + m31 * tab[6] + m32 * tab[10] + m33 * tab[14]
	mat[15] = m30 * tab[3] + m31 * tab[7] + m32 * tab[11] + m33 * tab[15]
    mat[16] = m30 * tab[4] + m31 * tab[8] + m32 * tab[12] + m33 * tab[16]
    -- self:transposeSelf()
end

function Matrix3D:mulLeft(tab)
    -- self:transposeSelf()
    -- tab = Matrix3D.transpose(tab)
	local m00, m01, m02, m03, m10, m11, m12, m13, m20, m21, m22, m23, m30, m31, m32, m33 = self[1], self[2], self[3], self[4], self[5], self[6], self[7], self[8], self[9], self[10], self[11], self[12], self[13], self[14], self[15], self[16]
	self[1] = tab[1]* m00+ tab[2] * m10 + tab[3] * m20 + tab[4] * m30  
	self[2] = tab[1]* m01+ tab[2] * m11 + tab[3]* m21  + tab[4] *  m31
	self[3] = tab[1]* m02+ tab[2] * m12 + tab[3]* m22  + tab[4] *  m32
	self[4] = tab[1]* m03+ tab[2] * m13 + tab[3]* m23  + tab[4] *  m33

	self[5] = tab[5] * m00 + tab[6] * m10 + tab[7]  * m20 + tab[8] * m30  
	self[6] = tab[5] * m01 + tab[6] * m11 + tab[7]  *m21  + tab[8] *  m31
	self[7] = tab[5] * m02 + tab[6] * m12 + tab[7] * m22 + tab[8] *   m32
	self[8] = tab[5] * m03 + tab[6] * m13 + tab[7] * m23 + tab[8] *   m33
                                                                          
	self[9] = tab[9] * m00+ tab[10] * m10+ tab[11]  *  m20 + tab[12] * m30  
	self[10] = tab[9] *m01 + tab[10] *m11 + tab[11] * m21 + tab[12] *   m31
	self[11] = tab[9] *m02 + tab[10] *m12 + tab[11] * m22 + tab[12] *   m32
	self[12] = tab[9] *m03 + tab[10] *m13 + tab[11] * m23 + tab[12] *   m33
                                                                          
	self[13] = tab[13] * m00 + tab[14] *m10 + tab[15]  * m20 + tab[16] * m30  
	self[14] = tab[13] * m01 + tab[14] *m11 + tab[15] * m21 + tab[16] *   m31
	self[15] = tab[13] * m02 + tab[14] *m12 + tab[15] * m22 + tab[16] *   m32
    self[16] = tab[13] * m03 + tab[14] *m13 + tab[15] * m23 + tab[16] *   m33
end

function Matrix3D:transposeSelf( )
	-- local m00, m01, m02, m03, m10, m11, m12, m13, m20, m21, m22, m23, m30, m31, m32, m33 = self[1], self[2], self[3], self[4], self[5], self[6], self[7], self[8], self[9], self[10], self[11], self[12], self[13], self[14], self[15], self[16]

	-- 	m[0][1] = m10; m[0][2] = m20; m[0][3] = m30;
	-- 	m[1][0] = m01; m[1][2] = m21; m[1][3] = m31;
	-- 	m[2][0] = m02; m[2][1] = m12; m[2][3] = m32;
	-- 	m[3][0] = m03; m[3][1] = m13; m[3][2] = m23;

        local mats = {}
        for x = 1, 4 do
            for y = 1, 4 do
                mats[x + (y-1)*4] = self[x + (y-1)*4]
            end
        end

        for x = 1, 4 do
            for y = 1, 4 do
                self[y + (x-1)*4] = mats[x + (y-1)*4]
            end
        end

	-- return *this;
end

function Matrix3D.transpose(m)
	-- local m00, m01, m02, m03, m10, m11, m12, m13, m20, m21, m22, m23, m30, m31, m32, m33 = self[1], self[2], self[3], self[4], self[5], self[6], self[7], self[8], self[9], self[10], self[11], self[12], self[13], self[14], self[15], self[16]

	-- 	m[0][1] = m10; m[0][2] = m20; m[0][3] = m30;
	-- 	m[1][0] = m01; m[1][2] = m21; m[1][3] = m31;
	-- 	m[2][0] = m02; m[2][1] = m12; m[2][3] = m32;
	-- 	m[3][0] = m03; m[3][1] = m13; m[3][2] = m23;

	local mat = Matrix3D.new()
	local mats = {}
	for x = 1, 4 do
		for y = 1, 4 do
			mats[x + (y-1)*4] = m[x + (y-1)*4]
		end
	end

	for x = 1, 4 do
		for y = 1, 4 do
			mat[y + (x-1)*4] = mats[x + (y-1)*4]
		end
	end

	return mat
end


----------------------------------------------------------------------------------------------------
-- transformation, projection, and rotation matrices
----------------------------------------------------------------------------------------------------
-- the three most important matrices for 3d graphics
-- these three matrices are all you need to write a simple 3d shader

-- returns a transformation matrix
-- translation and rotation are 3d vectors
Matrix3D.getTransformationMatrix = function(translation, rotation, scale)
    local ret = Matrix3D.new()

    ret.translation = translation;
    ret.rotation = rotation;
    ret.scale = scale;

    -- translations
    ret[4] = translation.x
    ret[8] = translation.y
    ret[12] = translation.z

    -- rotations
    -- x
    local rx = Matrix3D.new()
    rx[6] = math.cos(rotation.x)
    rx[7] = -1*math.sin(rotation.x)
    rx[10] = math.sin(rotation.x)
    rx[11] = math.cos(rotation.x)
    ret = Matrix3D.matrixMult(ret, rx)

    -- y
    local ry = Matrix3D.new()
    ry[1] = math.cos(rotation.y)
    ry[3] = math.sin(rotation.y)
    ry[9] = -math.sin(rotation.y)
    ry[11] = math.cos(rotation.y)
    ret = Matrix3D.matrixMult(ret, ry)

    -- z
    local rz = Matrix3D.new()
    rz[1] = math.cos(rotation.z)
    rz[2] = -math.sin(rotation.z)
    rz[5] = math.sin(rotation.z)
    rz[6] = math.cos(rotation.z)
    ret = Matrix3D.matrixMult(ret, rz)

    -- scale
    local sm = Matrix3D.new()
    sm[1] = scale.x
    sm[6] = scale.y
    sm[11] = scale.z
    -- ret = Matrix3D.matrixMult(ret, sm)

    ret:mulRight(sm)
    return ret
end

function Matrix3D:getData(i, j)
    return self[(i - 1) * 4 + j]
end

function Matrix3D:setData(i, j, v)
    self[(i - 1) * 4 + j] = v
end

function Matrix3D.determinant3x3( m00, m01, m02, m10, m11, m12, m20, m21, m22)
	return m00 * m11 * m22 + m01 * m12 * m20 + m02 * m10 * m21 - m00 * m12 * m21- m01 * m10 * m22 - m02 * m11 * m20;
end

function Matrix3D:determinant()
	local d1 = Matrix3D.determinant3x3(self:getData(2,2), self:getData(2,3), self:getData(2,4), self:getData(3,2), self:getData(3,3), self:getData(3,4), self:getData(4,2), self:getData(4,3), self:getData(4,4))

	local d2 = Matrix3D.determinant3x3(self:getData(2,1), self:getData(2,3), self:getData(2,4), self:getData(3,1), self:getData(3,3), self:getData(3,4), self:getData(4,1), self:getData(4,3), self:getData(4,4))

	local d3 = Matrix3D.determinant3x3( self:getData(2,1),  self:getData(2,2),  self:getData(2,4),  self:getData(3,1),  self:getData(3,2),  self:getData(3,4),  self:getData(4,1),  self:getData(4,2),  self:getData(4,4))

	local d4 = Matrix3D.determinant3x3( self:getData(2,1), self:getData(2,2), self:getData(2,3), self:getData(3,1), self:getData(3,2), self:getData(3,3), self:getData(4,1), self:getData(4,2), self:getData(4,3))

	return self:getData(1, 1) * d1 - self:getData(1, 2) * d2 + self:getData(1, 3) * d3 - self:getData(1, 4) * d4;

end

function Matrix3D:adjoint( )

	local m00 = self:getData(1,1)
	local m01 = self:getData(1,2)
	local m02 = self:getData(1,3)
	local m03 = self:getData(1,4)
	local m10 = self:getData(2,1)
	local m11 = self:getData(2,2)
	local m12 = self:getData(2,3)
	local m13 = self:getData(2,4)
	local m20 = self:getData(3,1)
	local m21 = self:getData(3,2)
	local m22 = self:getData(3,3)
	local m23 = self:getData(3,4)
	local m30 = self:getData(4,1)
	local m31 = self:getData(4,2)
	local m32 = self:getData(4,3)
	local m33 = self:getData(4,4)

	self:setData(1,1,Matrix3D.determinant3x3( m11, m12, m13, m21, m22, m23, m31, m32, m33 ) )
	self:setData(2,1,-Matrix3D.determinant3x3( m10, m12, m13, m20, m22, m23, m30, m32, m33 ) )
	self:setData(3,1,Matrix3D.determinant3x3( m10, m11, m13, m20, m21, m23, m30, m31, m33 ) )
	self:setData(4,1,-Matrix3D.determinant3x3( m10, m11, m12, m20, m21, m22, m30, m31, m32 ) )
	                                         
	self:setData(1,2,-Matrix3D.determinant3x3( m01, m02, m03, m21, m22, m23, m31, m32, m33 ) )
	self:setData(2,2,Matrix3D.determinant3x3( m00, m02, m03, m20, m22, m23, m30, m32, m33 ) )
	self:setData(3,2,-Matrix3D.determinant3x3( m00, m01, m03, m20, m21, m23, m30, m31, m33 ) )
	self:setData(4,2,Matrix3D.determinant3x3( m00, m01, m02, m20, m21, m22, m30, m31, m32 ) )
	                                         
	self:setData(1,3,Matrix3D.determinant3x3( m01, m02, m03, m11, m12, m13, m31, m32, m33) )
	self:setData(2,3,-Matrix3D.determinant3x3( m00, m02, m03, m10, m12, m13, m30, m32, m33) )
	self:setData(3,3,Matrix3D.determinant3x3( m00, m01, m03, m10, m11, m13, m30, m31, m33 ) )
	self:setData(4,3,-Matrix3D.determinant3x3( m00, m01, m02, m10, m11, m12, m30, m31, m32 ) )
	                                         
	self:setData(1,4,-Matrix3D.determinant3x3( m01, m02, m03, m11, m12, m13, m21, m22, m23 ) )
	self:setData(2,4,Matrix3D.determinant3x3( m00, m02, m03, m10, m12, m13, m20, m22, m23 ) )
	self:setData(3,4,-Matrix3D.determinant3x3( m00, m01, m03, m10, m11, m13, m20, m21, m23 ) )
	self:setData(4,4,Matrix3D.determinant3x3( m00, m01, m02, m10, m11, m12, m20, m21, m22 ) )
	return self
end

function Matrix3D:Set(mat)
	local result = self
	result[1] = mat[1]
	result[2] = mat[2]
	result[3] = mat[3]
	result[4] = mat[4]

	result[5] = mat[5]
	result[6] = mat[6]
	result[7] = mat[7]
	result[8] = mat[8]
	
	result[9] = mat[9]
	result[10] = mat[10]
	result[11] = mat[11]
	result[12] = mat[12]

	result[13] = mat[13]
	result[14] = mat[14]
	result[15] = mat[15]
	result[16] = mat[16]

	return result;
end

function Matrix3D.copy(mat)
	local result = Matrix3D.new()
	
	return result:Set(mat);
end

Matrix3D.Copy =  Matrix3D.copy

function Matrix3D.inverse(mat)
	local m = Matrix3D.copy(mat)
	local d = m:determinant( );

	if d ~= 0 then
		m:adjoint( );
		d = 1.0 / d;
		for i = 1, 16 do
			m[i] = m[i] * d;
		end		
	end

	return m;
end

function Matrix3D.createPerspectiveFovRH( fovy, aspect, znear, zfar )
	local ys = 1 / math.tan( fovy / 2.0 );
	local xs = ys / aspect;
	local zf = zfar / ( znear - zfar );
	local zn = znear * zf;

	return Matrix3D.createFromNumbers(
		  xs, 0.0, 0.0,  0.0,
		0.0,   ys, 0.0,  0.0,
		0.0, 0.0,   zf, -1.0,
		0.0, 0.0,   zn,  0. );
end

function Matrix3D.createPerspectiveFovLH( fovy, aspect, znear, zfar )
	local ys = 1 / math.tan( fovy / 2.0 );
	local xs = ys / aspect;
	local zf = zfar / ( zfar - znear );
	local zn = - znear * zf;

	return Matrix3D.createFromNumbers(
		  xs, 0.0, 0.0, 0.0,
		0.0,   ys, 0.0, 0.0,
		0.0, 0.0,   zf, 1.0,
		0.0, 0.0,   zn, 0.0 );
end


-- returns a standard projection matrix
-- (things farther away appear smaller)
-- all arguments are scalars aka normal numbers
-- aspectRatio is defined as window width divided by window height
Matrix3D.getProjectionMatrix = function(fov, near, far, aspectRatio)
    local top = near * math.tan(fov/2)
    local bottom = -1*top
    local right = top * aspectRatio
    local left = -1*right
    return Matrix3D.createFromNumbers(
        2*near/(right-left), 0, (right+left)/(right-left), 0,
        0, 2*near/(top-bottom), (top+bottom)/(top-bottom), 0,
        0, 0, -1*(far+near)/(far-near), -2*far*near/(far-near),
        0, 0, -1, 0
)
end

-- returns an orthographic projection matrix
-- (things farther away are the same size as things closer)
-- all arguments are scalars aka normal numbers
-- aspectRatio is defined as window width divided by window height
Matrix3D.getOrthoMatrix = function(fov, size, near, far, aspectRatio)
    local top = size * math.tan(fov/2)
    local bottom = -1*top
    local right = top * aspectRatio
    local left = -1*right
    return Matrix3D.createFromNumbers(
        2/(right-left), 0, 0, -1*(right+left)/(right-left),
        0, 2/(top-bottom), 0, -1*(top+bottom)/(top-bottom),
        0, 0, -2/(far-near), -(far+near)/(far-near),
        0, 0, 0, 1
)
end

Matrix3D.createOrthoOffCenterLH = function(left, right, bottom, top, znear, zfar )
	local xs1 = 2.0 / ( right - left );
	local xs2 = ( left + right ) / ( left - right );
	local ys1 = 2.0 / ( top - bottom );
	local ys2 = ( bottom + top ) / ( bottom - top );
	local zf  = 1.0 / ( zfar - znear );
	local zn  = - znear * zf;

	return Matrix3D.createFromNumbers(
		 xs1, 0.0, 0.0, 0.0,
		0.0,  ys1, 0.0, 0.0,
		0.0, 0.0,   zf, 0.0,
         xs2,  ys2,   zn, 1.0);
end

Matrix3D.createOrthoOffCenterRH = function( left, right, bottom, top, znear, zfar )
	local xs1 = 2.0 / ( right - left );
	local xs2 = ( left + right ) / ( left - right );
	local ys1 = 2.0 / ( top - bottom );
	local ys2 = ( bottom + top ) / ( bottom - top );
	local zf  = 1.0 / ( znear - zfar );
	local zn  = znear * zf;

	return Matrix3D.createFromNumbers(
		 xs1, 0.0, 0.0, 0.0,
		0.0,  ys1, 0.0, 0.0,
		0.0, 0.0,   zf, 0.0,
		 xs2,  ys2,   zn, 1.0 );
end

function Matrix3D:Log(sss)
	log()
	log('Matrix3D: ', sss)
	log(self[1], self[2], self[3], self[4])
	log(self[5], self[6], self[7], self[8])
	log(self[9], self[10], self[11], self[12])
	log(self[13], self[14], self[15], self[16])
	log()
end