FileManager.addAllPath("assert")

-- local TestDatas = {1, 4, 7, 1.2, 4.3, 9, 11}
-- local _FT = FourierTransform.new()
-- _FT:BindDatas_1D(TestDatas)
-- _FT:ProcessTransformDatas_1D()

-- _FT:InverseFourierTransform_1D()

-- _FT:Log()

local TestDatas1 = {1, 4, 7, 1.2, 4.3, 9, 11}
local _FT1 = FourierTransform.new()
_FT1:BindDatas_1D(TestDatas1)
_FT1:ProcessTransformDatas_1D()

local TestDatas2 = {1, 1, 2}
local _FT2 = FourierTransform.new()
_FT2:BindDatas_1D(TestDatas2, #TestDatas1, true)
_FT2:ProcessTransformDatas_1D()

local _NewFT = FourierTransform.Convolution_1D(_FT1, _FT2)
_NewFT:InverseFourierTransform_1D()
_NewFT:Log()