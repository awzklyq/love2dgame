FileManager.addAllPath("assert")
math.randomseed(os.time()%10000)
-- local TestDatas = {1, 4, 7, 1.2, 4.3, 9, 11}
-- local _FT = FourierTransform.new()
-- _FT:BindDatas_1D(TestDatas)
-- _FT:ProcessTransformDatas_1D()

-- _FT:InverseFourierTransform_1D()

-- _FT:Log()

local _BaseDatas = {}
local _TestDatas = {}

local _BaseDatas_DFT = FourierTransform.new()
local _TestDatas_DFT = {}

local _Num = 100
local _Len = 256

local _GetData = function()
    return math.random(-10000 , 10000)
end

local _Normalize = function(InDatas)
    local _Result = 0
    for i = 1, _Len do
        _Result = _Result + InDatas[i]
    end

    for i = 1, _Len do
        InDatas[i] = InDatas[i] / _Result
    end
end

local _Dot = function(InData1, InData2)
    local _Result = 0
    for i = 1, _Len do
        _Result = _Result + InData1[i] * InData2[i]
    end

    return _Result
end

local _DotFT = function(InFT1, InFT2)
    local _Result = InFT1._FourierDatas_1D[#InFT1._FourierDatas_1D] * InFT2._FourierDatas_1D[#InFT2._FourierDatas_1D]
    return _Result:GetReal()
end

for i = 1, _Len do
    _BaseDatas[i] = _GetData()
end

_Normalize(_BaseDatas)
for i = 1, #_BaseDatas do
    log('iiii', _BaseDatas[i])
end

_BaseDatas_DFT:BindDatas_1D(_BaseDatas, nil, true)
_BaseDatas_DFT:ProcessTransformDatas_1D()
for i = 1, _Num do
    _TestDatas[i] = {}
    for j = 1, _Len do
        _TestDatas[i][j] = _GetData()
    end

    _Normalize( _TestDatas[i])

    _TestDatas_DFT[i] = FourierTransform.new()
    _TestDatas_DFT[i]:BindDatas_1D( _TestDatas[i])
    _TestDatas_DFT[i]:ProcessTransformDatas_1D()
end

local _SortResults = {}
local _SortResults2 = {}
for i = 1, _Num do
    _SortResults[i] = {a = _Dot(_TestDatas[i], _BaseDatas), b = i}
    _SortResults2[i] = {a = _DotFT(_TestDatas_DFT[i], _BaseDatas_DFT), b = i}
end

table.sort(_SortResults, function(a, b)
    return a.a > a.b
end)

table.sort(_SortResults2, function(a, b)
    return a.a > a.b
end)

for i = 1, #_SortResults do
    log('aaaaaaaa', _SortResults[i].b, _SortResults2[i].b)
    check(_SortResults[i].b == _SortResults2[i].b)
end