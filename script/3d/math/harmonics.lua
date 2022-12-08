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

    return harmonics
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

local UniformSampleSphere = function( E )

	local Phi = 2 * math.pi * E.x;
	local CosTheta = 1 - 2 * E.y;
	local SinTheta = math.sqrt( 1 - CosTheta * CosTheta );

	local H = Vector3.new();
	H.x = SinTheta * math.cos( Phi );
	H.y = SinTheta * math.sin( Phi );
	H.z = CosTheta;

	local PDF = 1.0 / (4 * math.pi);

	return Vector4.new( H.x, H.y, H.z, PDF );
end

function Harmonics:GenerateSphereNormals()
	local Normals = {}

	-- for a = 0, 360, 30 do
	-- 	for b = 0, 180, 30 do
	-- 		local x = SphereX(1, math.rad(a), math.rad(b))
	-- 		local y = SphereY(1, math.rad(a), math.rad(b))
	-- 		local z = SphereZ(1, math.rad(b))
	-- 		local nor = Vector3.new(x, y, z)
	-- 		Normals[#Normals + 1] = nor
	-- 	end
	-- end

	local SampleSize = Vector.new(512, 512)
	for x = 1, SampleSize.x - 1 do
		for y = 1, SampleSize.y - 1 do
			-- local angle = GetThetaPhi(x, y, SampleSize);
			-- local xx = SphereX(1, angle.x, angle.y)
			-- local yy = SphereY(1, angle.x, angle.y)
			-- local zz = SphereZ(1, angle.y)

			local result = UniformSampleSphere(Vector.new(x / SampleSize.x , y / SampleSize.y))

			local nor = Vector3.new(result.x, result.y, result.z)

			Normals[#Normals + 1] = nor
		end
	end

	return Normals
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