FileManager.addAllPath("assert")
math.randomseed(os.time()%10000)

local PointNumber = 16
local ResultNumber = 256
local MaxLenght = 80
local OriginPoint = Point2D.new(100, 100)
local OriLines = {}
local OriginPoints = {}
OriginPoint:SetColor(255, 0, 0, 255)

local _Angle = 360 / PointNumber
local _Radian = math.rad(_Angle)
local _RotationComplex = Complex.CreateFromAngle(_Angle)
local _First = Complex.new(1, 0)

local AllRadian = 0
for i = 1, PointNumber do 
    _First = _First * _RotationComplex
    local _V = Vector.new(_First:GetReal(), _First:GetImag()) * math.random(MaxLenght * 0.1, MaxLenght)
    _V._Radian = Vector.angleClockwise(_V, Vector.new(1, 0))
    OriginPoints[#OriginPoints + 1] = _V
    local NewPoint = _V + OriginPoint
end

table.sort(OriginPoints, function(a, b) return a._Radian < b._Radian end)
for i = 1, PointNumber - 1 do 
    local v1 = OriginPoints[i] + OriginPoint
    local v2 = OriginPoints[i + 1] + OriginPoint
    OriLines[#OriLines +1] = Line.new(v1.x, v1.y, v2.x, v2.y)

    if i == PointNumber - 1 then
        local v1 = OriginPoints[PointNumber] + OriginPoint
        local v2 = OriginPoints[1] + OriginPoint
        OriLines[#OriLines +1] = Line.new(v1.x, v1.y, v2.x, v2.y)
    end
end

local _Z = Zernike_Value.new()
_Z:AddVectors(OriginPoints)

local ResultDatas = {}
local OriResultPoint = Point2D.new(500, 500)
OriResultPoint:SetColor(255, 0, 0, 255)
local _RLines = {}
_First = Complex.new(1, 0)
_Angle = 360 / ResultNumber
_Radian = math.rad(_Angle)
_RotationComplex = Complex.CreateFromAngle(_Angle)
for i = 1, ResultNumber do
    _First = _First * _RotationComplex
    local _V = Vector.new(_First:GetReal(), _First:GetImag())
   --Vector.angleClockwise(_V, Vector.new(1, 0))
    local Length = _Z:GetValueFormDirection(_V)
    -- log('aaaaaaaa', Length)
    local NewPoint =  _V * Length 
    NewPoint._Radian = _Radian * i
    ResultDatas[#ResultDatas + 1] = NewPoint
end
table.sort(ResultDatas, function(a, b) return a._Radian < b._Radian end)
for i = 1, #ResultDatas - 1 do
    local v1 = ResultDatas[i] + OriResultPoint
    local v2 = ResultDatas[i + 1] + OriResultPoint
    _RLines[#_RLines +1] = Line.new(v1.x, v1.y, v2.x, v2.y)
    if i == #ResultDatas - 1 then
        local v1 = ResultDatas[#ResultDatas] + OriResultPoint
        local v2 = ResultDatas[1] + OriResultPoint
        _RLines[#_RLines +1] = Line.new(v1.x, v1.y, v2.x, v2.y)
    end
end

app.render(function(dt)
    for i = 1, #OriLines do
        OriLines[i]:draw()
    end
    OriginPoint:draw()

    for i = 1, #_RLines do
        _RLines[i]:draw()
    end
    OriResultPoint:draw()
end)

-- local N = 6
-- for i = 1, N do
--     log()
--     for j = 1, N do
--         local _p = math.c2pi / N
--         log('ttttttttt', i, j, i *  j * _p)
--     end

-- end