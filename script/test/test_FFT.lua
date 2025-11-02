local TestDatas3 = {1, 4, 7, 1.2, 4.3, 9, 11, 19, 4.5, 2.1}
local _FT3 = FourierTransform.new()
_FT3:BindDatas_1D(TestDatas3)
_FT3:FFT_Base2_1D()
-- _FT3:InverseFourierTransform_1D()
_FT3:IFFT_1D()

_FT3:Log()