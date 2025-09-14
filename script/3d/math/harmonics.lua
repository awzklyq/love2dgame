_G.ThreeBandSHVector = {}
local metatable_ThreeBandSHVector = {}
metatable_ThreeBandSHVector.__index = ThreeBandSHVector
metatable_ThreeBandSHVector.__add = function(myvalue, value)
    local Result = ThreeBandSHVector.new()
	Result.V0 = myvalue.V0 + value.V0
	Result.V1 = myvalue.V1 + value.V1
	Result.V2 = myvalue.V2 + value.V2
	return Result
end

metatable_ThreeBandSHVector.__div = function(myvalue, value)
	if type(value) == 'number' then
		local Result = ThreeBandSHVector.new()
		Result.V0 = myvalue.V0  / value
		Result.V1 = myvalue.V1 / value
		Result.V2 = myvalue.V2 / value
		return Result
	elseif type(value) == 'table' and value.renderid  == Render.ThreeBandSHVectorId then
		local Result = ThreeBandSHVector.new()
		Result.V0 = myvalue.V0 / value.V0
		Result.V1 = myvalue.V1 / value.V1
		Result.V2 = myvalue.V2 / value.V2
		return Result
	else
		errorAssert(false, "metatable_ThreeBandSHVector.__div~")
	end
end

metatable_ThreeBandSHVector.__mul = function(myvalue, value)
	if type(value) == 'number' then
		local Result = ThreeBandSHVector.new()
		Result.V0 = myvalue.V0 * value
		Result.V1 = myvalue.V1 * value
		Result.V2 = myvalue.V2 * value
		return Result
	elseif type(value) == 'table' and value.renderid  == Render.ThreeBandSHVectorId then
		local Result = ThreeBandSHVector.new()
		Result.V0 = myvalue.V0 * value.V0
		Result.V1 = myvalue.V1 * value.V1
		Result.V2 = myvalue.V2 * value.V2
		return Result
	else
		errorAssert(false, "metatable_ThreeBandSHVector.__mul~")
	end
end

function ThreeBandSHVector.new()
    local SHVector = setmetatable({}, metatable_ThreeBandSHVector);

	SHVector.V0 = Vector4.new(0,0,0,0)
	SHVector.V1 = Vector4.new(0,0,0,0)
	SHVector.V2 = 0

	SHVector.renderid = Render.ThreeBandSHVectorId
    return SHVector
end

_G.ThreeBandSHVectorRGB = {}
local metatable_ThreeBandSHVectorRGB = {}
metatable_ThreeBandSHVectorRGB.__index = ThreeBandSHVectorRGB

metatable_ThreeBandSHVectorRGB.__add = function(myvalue, value)
    local Result = ThreeBandSHVectorRGB.new()
	Result.R = myvalue.R + value.R
	Result.G = myvalue.G + value.G
	Result.B = myvalue.B + value.B
	return Result
end

metatable_ThreeBandSHVectorRGB.__mul = function(myvalue, value)
	if type(value) == 'number' then
		local Result = ThreeBandSHVectorRGB.new()
		Result.R = myvalue.R * value
		Result.G = myvalue.G * value
		Result.B = myvalue.B * value
		return Result
	elseif type(value) == 'table' and value.renderid  == Render.ThreeBandSHVectorRGBId then
		local Result = ThreeBandSHVectorRGB.new()
		Result.R = myvalue.R * value.R
		Result.G = myvalue.G * value.B
		Result.B = myvalue.B * value.G
		return Result
	else
		errorAssert(false, "metatable_ThreeBandSHVectorRGB.__mul~")
	end
end

metatable_ThreeBandSHVectorRGB.__div = function(myvalue, value)
	if type(value) == 'number' then
		local Result = ThreeBandSHVectorRGB.new()
		Result.R = myvalue.R / value
		Result.G = myvalue.G / value
		Result.B = myvalue.B / value
		return Result
	elseif type(value) == 'table' and value.renderid  == Render.ThreeBandSHVectorRGBId then
		local Result = ThreeBandSHVectorRGB.new()
		Result.R = myvalue.R / value.R
		Result.G = myvalue.G / value.G
		Result.B = myvalue.B / value.B
		return Result
	else
		errorAssert(false, "metatable_ThreeBandSHVectorRGB.__div~")
	end
end

function ThreeBandSHVectorRGB.new()
    local SHVectorRGB = setmetatable({}, metatable_ThreeBandSHVectorRGB);

	SHVectorRGB.R = ThreeBandSHVector.new()
	SHVectorRGB.G = ThreeBandSHVector.new()
	SHVectorRGB.B = ThreeBandSHVector.new()

	SHVectorRGB.renderid = Render.ThreeBandSHVectorRGBId
    return SHVectorRGB
end

_G.Harmonics = {}
function Harmonics.new()
    local harmonics = setmetatable({}, {__index = Harmonics});

    harmonics.m_Coefs = ThreeBandSHVectorRGB.new()

	harmonics.m_Coefs5 = {}
	harmonics.m_Coefs5_Num = 16
    return harmonics
end

function Harmonics:SHBasisFunction5(InVec)
	local _pi = math.pi
	local _inv_pi = 1 / _pi

	local _V = Vector3.Copy(InVec):normalize()
	local _x = _V.x
	local _y = _V.y
	local _z = _V.z

	local _x2 = _x * _x
	local _y2 = _y * _y
	local _z2 = _z * _z

	local _x4 = _x2 * _x2
	local _y4 = _y2 * _y2
	local _z4 = _z2 * _z2
	local _sqrt = math.sqrt

	local m_Coefs5 = {}
	m_Coefs5[1] = 0.5 * _sqrt(_inv_pi)

	-- l = 1
	m_Coefs5[2] = _sqrt(3 / 4 * _inv_pi) * _y
	m_Coefs5[3] = _sqrt(3 / 4 * _inv_pi) * _z
	m_Coefs5[4] = _sqrt(3 / 4 * _inv_pi) * _x

	-- l = 2
	m_Coefs5[5] = 0.5 * _sqrt(15 * _inv_pi) * _x * _y
	m_Coefs5[6] = 0.5 * _sqrt(15 * _inv_pi) * _y * _z
	m_Coefs5[7] = 0.125 * _sqrt(5 * _inv_pi) * (3 * _z2 - 1)
	m_Coefs5[8] = 0.5 * _sqrt(15 * _inv_pi) * _x * _z
	m_Coefs5[9] = 0.25 * _sqrt(15 * _inv_pi) * (_x2 - _y2)

	-- l = 3
	m_Coefs5[10] = 0.25 * _sqrt(35 / 2 * _inv_pi) * (3 * _x2 - _y2) * _y
	m_Coefs5[11] = 0.5 * _sqrt(105 * _inv_pi) * _x * _y * _z
	m_Coefs5[12] = 0.25 * _sqrt(21 / 2 * _inv_pi) * _y * (4 * _z2 - _x2 - _y2)
	m_Coefs5[13] = 0.25 * _sqrt(7 * _inv_pi) * _z * (2 * _z2 - 3 * _x2 - 3 * _y2)
	m_Coefs5[14] = 0.25 * _sqrt(21 / 2 * _inv_pi) * _x * (4 * _z2 - _x2 - _y2)
	m_Coefs5[15] = 0.25 * _sqrt(105 * _inv_pi) * _z * (_x2 - _y2)
	m_Coefs5[16] = 0.25 * _sqrt(35 / 2 * _inv_pi) * _x *(_x2 - 3 * _y2)

	-- l = 4
	m_Coefs5[17] = 0.75 * _sqrt(35 * _inv_pi) * _x * _y * (_x2 - _y2)
	m_Coefs5[18] = 0.75 * _sqrt(35 / 2 * _inv_pi) * _y * _z * (3 * _x2 - _y2)
	m_Coefs5[19] = 0.75 * _sqrt(5 * _inv_pi) * _x * _y * (7 * _z2 - 1)
	m_Coefs5[20] = 0.75 * _sqrt(5 / 2 * _inv_pi) * _y * _z * (7 * _z2 - 3)
	m_Coefs5[21] = 3 / 16 * _sqrt(_inv_pi) * (35 * _z4 - 30 * _z2 + 3 )
	m_Coefs5[22] = 0.75 * _sqrt(5 / 2 * _inv_pi) * _x *_z * (7 * _z2 - 3)
	m_Coefs5[23] = 3 / 8 * _sqrt(5 * _inv_pi) * (_x2 - _y2) * (7 * _z2 - 1)
	m_Coefs5[24] = 0.75 * _sqrt(35 / 2 * _inv_pi) * _x * _z * (_x2 - 3 * _y2)
	m_Coefs5[25] = 3 / 16 * _sqrt(35 * _inv_pi) * (_x4 - 6 * _x *_x * _y *_y + _y4)

	-- l = 5
	m_Coefs5[26] = (3 / 16) * _sqrt(77 / 2 * _inv_pi) * _y * (5 * _x4 - 10 * _x *_x * _y2 + _y4)
	m_Coefs5[27] = 0.75 * _sqrt(385 * _inv_pi) * _x * _y * ( _x2 - _y2) * _z
	m_Coefs5[28] = (1 / 32) * _sqrt(385 * _inv_pi) * _y * (3 * _x2 - _y2) * (9 * _z2 - 1)
	m_Coefs5[29] = 0.125 * _sqrt(1155 * _inv_pi) * _x * _y * (3 * _z2 - 1) * _z
	m_Coefs5[30] = (1 / 16) * _sqrt(165 / 2 * _inv_pi) * _y * (14 * _z *_z - 21 *_z *_z2 *_z - 1 + 3 * _z *_z )
	m_Coefs5[31] = (1 / 16) * _sqrt(11 * _inv_pi) * _z * (63 * _z *_z2 *_z - 70 * _z *_z + 15)
	m_Coefs5[32] = (1 / 16) * _sqrt(165 / 2 * _inv_pi) * _x * (14 * _z *_z - 21 *_z *_z2 *_z - 1 + 3 * _z *_z )
	m_Coefs5[33] = 0.125 * _sqrt(1155 * _inv_pi) * _z * (_x2 - _y2) * (3 * _z2 - 1)
	m_Coefs5[34] = (1 / 32) * _sqrt(385 * _inv_pi) * _x * (_x2 - 3 * _y2) *  (9 * _z2 - 1)
	m_Coefs5[35] = 0.75 * _sqrt(385 * _inv_pi) * _z * ( _x4 - 6 * _x2 * _y2  + _y4)
	m_Coefs5[36] = (3 / 16) * _sqrt(77 / 2 * _inv_pi) * _x * (_x4 - 10 * _x2 * _y2 + 5 * _y4)
	return m_Coefs5
end

function Harmonics:InItCoefs5()
	self.m_Coefs5 = {}
	for i = 1, self.m_Coefs5_Num do
		self.m_Coefs5[i] = 0
	end
end

function Harmonics:ProjectSH5(InCoefs5, InPower)
	for i = 1, self.m_Coefs5_Num do
		self.m_Coefs5[i] = self.m_Coefs5[i] + InCoefs5[i] * InPower
	end
end

function Harmonics:GenerateMeshFlag(InPoss)
	local _Box = BoundBox.new()--AddVector3
	for i = 1, #InPoss do
		_Box:AddVector3(InPoss[i])
	end

	local _Center = _Box:GetCenter()

	local _Weight = 1 / #InPoss
	self:InItCoefs5()
	for i = 1, #InPoss do
		local _v = InPoss[i]
		local _p = _v - _Center

		local _m_Coefs5 = self:SHBasisFunction5(_p)

		self:ProjectSH5(_m_Coefs5, _p:Length() * _Weight)
	end
end

function Harmonics:GetProjectSH5(InVec)
	InVec = Vector3.Copy(InVec):normalize()
	local _SH5 = self:SHBasisFunction5(InVec)

	local _ProjectV = self:DotSH5(_SH5)
	return InVec * _ProjectV
end

function Harmonics:DotSH5(InCoefs5)
	local _Result = 0
	for i = 1, self.m_Coefs5_Num do
		_Result = _Result + self.m_Coefs5[i] * InCoefs5[i]
	end
	return _Result
end

function Harmonics:ReStrutMeshInfo(InNormals)
	log("Begin ReStrutMeshInfo!")
	local _Normals = InNormals or self:GenerateSphereNormals(126 * 2 + 1, 126 * 2 + 1)
	local _Pos = {}
	for i = 1, #_Normals do
		local _NewPos = self:GetProjectSH5(_Normals[i])
		_Pos[#_Pos + 1] = _NewPos
	end

	log("End ReStrutMeshInfo!")
	return _Pos
end

function Harmonics:SHBasisFunction3(pos)
    local InputVector = Vector3.copy(pos):normalize()
	
	local Result = ThreeBandSHVector.new()
	Result.V0.x = 0.282095 
	Result.V0.y = -0.488603 * InputVector.y;
	Result.V0.z = 0.488603 * InputVector.z;
	Result.V0.w = -0.488603 * InputVector.x;

	local VectorSquared = InputVector * InputVector;
	Result.V1.x = 1.092548 * InputVector.x * InputVector.y;
	Result.V1.y = -1.092548 * InputVector.y * InputVector.z;
	Result.V1.z = 0.315392 * (3.0 * VectorSquared.z - 1.0);
	-- Result.V1.z = 0.315392 * (-VectorSquared.x - VectorSquared.y + 2 * VectorSquared.z);
	Result.V1.w = -1.092548 * InputVector.x * InputVector.z;
	Result.V2 = 0.546274 * (VectorSquared.x - VectorSquared.y);

	return Result;
end

function Harmonics:MulSH3(SHVector, Color)
	local Result = ThreeBandSHVectorRGB.new();

	Result.R.V0 = SHVector.V0 * (Color.r or Color.x);
	Result.R.V1 = SHVector.V1 * (Color.r or Color.x);
	Result.R.V2 = SHVector.V2 * (Color.r or Color.x);
	Result.G.V0 = SHVector.V0 * (Color.g or Color.y);
	Result.G.V1 = SHVector.V1 * (Color.g or Color.y);
	Result.G.V2 = SHVector.V2 * (Color.g or Color.y);
	Result.B.V0 = SHVector.V0 * (Color.b or Color.z);
	Result.B.V1 = SHVector.V1 * (Color.b or Color.z);
	Result.B.V2 = SHVector.V2 * (Color.b or Color.z);
	return Result;
end

function Harmonics:CalcDiffuseTransferSH3(Normal, Exponent)
	local Result = self:SHBasisFunction3(Normal);--FThreeBandSHVector

	-- These formula are scaling factors for each SH band that convolve a SH with the circularly symmetric function
	-- max(0,cos(theta))^Exponent
	local L0 =					2 * math.pi / (1 + 1 * Exponent							);
	local L1 =					2 * math.pi / (2 + 1 * Exponent							);
	local L2 = Exponent *		2 * math.pi / (3 + 4 * Exponent + Exponent * Exponent	);
	local L3 = (Exponent - 1) *	2 * math.pi / (8 + 6 * Exponent + Exponent * Exponent	);

	-- Multiply the coefficients in each band with the appropriate band scaling factor.
	Result.V0.x = Result.V0.x * L0;
	-- Result.V0.yzw *= L1;
	Result.V0.y = Result.V0.y * L1
	Result.V0.z = Result.V0.z * L1
	Result.V0.w = Result.V0.w * L1

	Result.V1 = Result.V1 * L2;
	Result.V2 = Result.V2 * L2;

	return Result;
end

function Harmonics:DotSH(A, B)
	local Result = Vector4.dot(A.V0, B.V0);
	Result = Result +  Vector4.dot(A.V1, B.V1);
	Result = Result + A.V2 * B.V2;
	return Result;
end

function Harmonics:DotSH3(A, B)
	local Result = Vector3.new();
	Result.x = self:DotSH(A.R,B);
	Result.y = self:DotSH(A.G,B);
	Result.z = self:DotSH(A.B,B);
	return Result;
end

function Harmonics:GenerateSphereNormals(InX, InY)
	local Normals = {}

	local SampleSize = Vector.new(InX or 512, InY or 512)
	for x = 1, SampleSize.x - 1 do
		for y = 1, SampleSize.y - 1 do

			local result = math.UniformSampleSphere(Vector.new(x / SampleSize.x , y / SampleSize.y))

			local nor = Vector3.new(result.x, result.y, result.z)

			Normals[#Normals + 1] = nor
		end
	end

	return Normals
end

function Harmonics:GenerateSH5FromMesh(InMesh)
	log("Begin GenerateSH5FromMesh!")
	local _Result = {}
	local _Rays = Ray.CreateSphereMeshRays(true, 10000)
	for i = 1, #_Rays do
		log("GenerateSH5FromMesh : ", string.format("%.2f", ( i / #_Rays) * 100), i, #_Rays)
		local _ray = _Rays[i]
		local dis = InMesh:PickByRay(_ray, true)
        if dis > 0 then
			local _d1 = _ray:GetPosition():distanceself()

			local _dir = _ray:GetDirection()
			local _NewPos = (-_dir) * (_d1 - dis)
			_Result[#_Result + 1] = _NewPos
		end
	end

	log("Begin GenerateSH5FromMesh -> GenerateMeshFlag!")
	self:GenerateMeshFlag(_Result)
	-- return _Result

	log("End GenerateSH5FromMesh -> GenerateMeshFlag!")

	log("End GenerateSH5FromMesh!")
end

local TestNormal = Vector3.new()
function Harmonics:Generate(Normals)
	-- local Normals = self:GenerateSphereNormals()

	local UniformPDF = 1.0 / (2.0 * math.pi);
	local SampleWeight = 1.0 / (UniformPDF * #Normals);
	-- local SampleWeight = 4 * math.pi /  #Normals;
	self.m_Coefs = ThreeBandSHVectorRGB.new()
    for _, nor in pairs(Normals) do
		-- nor:normalize()
		local n = Vector3.copy(nor.Normal):normalize()
        local SHVector = self:SHBasisFunction3(n)

		-- color = Vector3.new(math.random(),math.random(),math.random())
		local SHVectorRGB = self:MulSH3(SHVector, nor.Color)
		
		self.m_Coefs = self.m_Coefs + SHVectorRGB * SampleWeight


		
    end

end

function Harmonics:GetColor(Normal)
	local SHVector = self:CalcDiffuseTransferSH3(Normal, 1)
	-- local SHVector = self:SHBasisFunction3(Normal)

	local color = self:DotSH3(self.m_Coefs, SHVector)
    return color
end