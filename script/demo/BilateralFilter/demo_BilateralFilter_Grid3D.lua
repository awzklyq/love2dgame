_G.BilateralFilter_Grid3D = {}

BilateralFilter_Grid3D._Meta = {__index = BilateralFilter_Grid3D}

function BilateralFilter_Grid3D.new(InX, InY, InZ)
    local grid3d = setmetatable({}, BilateralFilter_Grid3D._Meta )

    grid3d:Init(InX, InY, InZ)

    return grid3d
end

function BilateralFilter_Grid3D:Init(InX, InY, InZ)

    self._X = InX
    self._Y = InY
    self._Z = InZ

    self._Datas = {}
    for ix = 1, InX do
        self._Datas[ix] = {}
        for iy = 1, InY do
            self._Datas[ix][iy] = {}
            for iz = 1, InZ do
                self._Datas[ix][iy][iz] = Vector.new(0, 0)
            end
        end
    end

    self:InitBlurDatas()
end

function BilateralFilter_Grid3D:InitBlurDatas()
    self._BlurDatas = {}
    self._TempBlurDatas = {}
    for ix = 1, self._X do
        self._BlurDatas[ix] = {}
        self._TempBlurDatas[ix] = {}
        for iy = 1, self._Y do
            self._BlurDatas[ix][iy] = {}
            self._TempBlurDatas[ix][iy] = {}
            for iz = 1, self._Z do
                self._BlurDatas[ix][iy][iz] = Vector.new(0, 0)
                self._TempBlurDatas[ix][iy][iz] = Vector.new(0, 0)
            end
        end
    end
end

function BilateralFilter_Grid3D:SetImage(InImage)
    local _Pixels = InImage:GetPixels()
    local _W = #_Pixels
    local _H = #_Pixels[1]

    self._ImageW = _W
    self._ImageH = _H

    local _OffsetX = math.ceil(_W / self._X)
    local _OffsetY = math.ceil(_H / self._Y)

    self._OffsetX = _OffsetX
    self._OffsetY = _OffsetY

    local _OffsetZ = 1.0 / self._Z

    for ix = 1, _W do
        for iy = 1, _H do
            local _IndexX = math.ceil(ix / _OffsetX)
            local _IndexY = math.ceil(iy / _OffsetY)

            local iz = _Pixels[ix][iy]:GetLuminance()
            local _IndexZ = math.ceil(iz / _OffsetZ)
            self._Datas[_IndexX][_IndexY][_IndexZ] = self._Datas[_IndexX][_IndexY][_IndexZ] + Vector.new(math.log(iz), 1)
        end
    end

    self:ProcessDatas()
end

function BilateralFilter_Grid3D:ProcessDatas()
    if #self._Datas == 0 then
        return
    end

    local _sigma = 2
    local _range = 2
    local _weights1 = {}
    local _TotalWeight = 0 
    for i = -_range, _range do
        _weights1[#_weights1 + 1] = math.exp(-0.5 * math.pow(i / _sigma,2))
        _TotalWeight = _TotalWeight + _weights1[#_weights1]
    end

    for i = 1, #_weights1 do
        _weights1[i] = _weights1[i] / _TotalWeight
    end

    -- local _range = 5
    -- local _weights1 = {1,2,3,4,5,6,5,4,3,2,1}
    -- -- local _TotalWeight = 0 
    -- -- for i = -_range, _range do
    -- --     _weights1[#_weights1 + 1] = math.abs()
    -- --     _TotalWeight = _TotalWeight + _weights1[#_weights1]
    -- -- end

    self:InitBlurDatas()

    self:ForEachGridData(function(ix, iy, iz)
        self:GenerateBlurDataX(ix, iy, iz, _range, _weights1)
    end)

    self:ForEachGridData(function(ix, iy, iz)
        self:GenerateBlurDataY(ix, iy, iz, _range, _weights1)
    end)

    self:ForEachGridData(function(ix, iy, iz)
        self:GenerateBlurDataZ(ix, iy, iz, _range, _weights1)
    end)

end

function BilateralFilter_Grid3D:ForEachGridData(InFunc)
    for ix = 1, self._X do
        for iy = 1, self._Y do
            for iz = 1, self._Z do
                InFunc(ix, iy, iz)
            end
        end
    end
end

function BilateralFilter_Grid3D:GenerateBlurDataX(IX, IY, IZ, InRange, InWeight)
    local _TempTotalW = 0
    local IW = 0
    local _Luminance = Vector.new(0, 0)
    for ix = IX - InRange, IX + InRange do
        IW = IW + 1
        if ix > 0 and ix <= self._X then
            _TempTotalW = _TempTotalW + InWeight[IW]

            local _Lum = self._Datas[ix][IY][IZ] * InWeight[IW]

            _Luminance = _Luminance + _Lum
        end
    end

    -- _Luminance = _TempTotalW == 0 and 0 or _Luminance / _TempTotalW

    self._BlurDatas[IX][IY][IZ] = _Luminance
end

function BilateralFilter_Grid3D:GenerateBlurDataY(IX, IY, IZ, InRange, InWeight)
    local _TempTotalW = 0
    local IW = 0
    local _Luminance = Vector.new(0, 0)
    for iy = IY - InRange, IY + InRange do
        IW = IW + 1
        if iy > 0 and iy <= self._Y then
            _TempTotalW = _TempTotalW + InWeight[IW]

            local _Lum = self._BlurDatas[IX][iy][IZ] * InWeight[IW]

            _Luminance = _Luminance + _Lum
        end
    end

    -- _Luminance = _TempTotalW == 0 and 0 or _Luminance / _TempTotalW

    self._TempBlurDatas[IX][IY][IZ] = _Luminance
end

function BilateralFilter_Grid3D:GenerateBlurDataZ(IX, IY, IZ, InRange, InWeight)
    local _TempTotalW = 0
    local IW = 0
    local _Luminance = Vector.new(0, 0)
    for iz = IZ - InRange, IZ + InRange do
        IW = IW + 1
        if iz > 0 and iz <= self._Z then
            _TempTotalW = _TempTotalW + InWeight[IW]

            local _Lum = self._TempBlurDatas[IX][IY][iz] * InWeight[IW]

            _Luminance = _Luminance + _Lum
        end
    end

    -- _Luminance = _TempTotalW == 0 and 0 or _Luminance / _TempTotalW

    self._BlurDatas[IX][IY][IZ] = _Luminance
end

--https://zhuanlan.zhihu.com/p/573894977
--Return Value
function BilateralFilter_Grid3D:SampleFromPixel(InX, InY, InColor, InM)
    local _IndexX = math.ceil(InX / self._OffsetX)
    local _IndexY = math.ceil(InY / self._OffsetY)

    local iz = InColor:GetLuminance()

    local _OffsetZ = 1.0 / self._Z
    local _IndexZ = math.ceil(iz / _OffsetZ)

    local l1 = self._BlurDatas[_IndexX][_IndexY][_IndexZ]
    local l2 = self._Datas[_IndexX][_IndexY][_IndexZ]

    if l1.y == 0 then
        return 1
    end

    local _NewL_B = l1.x / l1.y
    local _OLd_L = l2.x / l2.y

    -- local a = 0.9
    -- _NewL_B = _NewL_B * a + (_OLd_L - _NewL_B)

    local c = 0.99
    local d = _OLd_L - _NewL_B
    _NewL_B = c * (_NewL_B - InM) + d * (InColor:GetLogLuminance() - _NewL_B) + InM
    return math.exp(_NewL_B )/ iz--math.clamp(_NewL / iz, 0.5, 1.5)
end