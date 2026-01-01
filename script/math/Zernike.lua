--Zernike多项式

_G.Zernike_Value = {}

local Z_Num = 26
Zernike_Value._Meta = {__index = Zernike_Value}
local GenerateZernikeCoefficients = function(InX, InY)
    local _Datas = {}
    
    -- 直角坐标形式的Zernike多项式前30项 (使用ANSI标准索引)
    local x = InX
    local y = InY
    local x2 = x * x
    local y2 = y * y
    local r2 = x2 + y2  -- r^2 = x^2 + y^2
    local r4 = r2 * r2
    local r6 = r4 * r2
    local x3 = x2 * x
    local y3 = y2 * y
    local x4 = x2 * x2
    local y4 = y2 * y2
    
    -- Z1: Piston (常数项)
    _Datas[1] = 1
    
    -- Z2: Tilt X (x方向倾斜)
    _Datas[2] = 2 * x
    
    -- Z3: Tilt Y (y方向倾斜)
    _Datas[3] = 2 * y
    
    -- Z4: Defocus (离焦)
    _Datas[4] = math.sqrt(3) * (2 * r2 - 1)
    
    -- Z5: Astigmatism 45° (45度像散)
    _Datas[5] = math.sqrt(6) * 2 * x * y
    
    -- Z6: Astigmatism 0° (0度像散)
    _Datas[6] = math.sqrt(6) * (x2 - y2)
    
    -- Z7: Coma Y (y方向彗差)
    _Datas[7] = math.sqrt(8) * (3 * r2 - 2) * y
    
    -- Z8: Coma X (x方向彗差)
    _Datas[8] = math.sqrt(8) * (3 * r2 - 2) * x
    
    -- Z9: Trefoil Y (y方向三叶草)
    _Datas[9] = math.sqrt(8) * (3 * x2 * y - y3)
    
    -- Z10: Trefoil X (x方向三叶草)
    _Datas[10] = math.sqrt(8) * (x3 - 3 * x * y2)
    
    -- Z11: Spherical (球差)
    _Datas[11] = math.sqrt(5) * (6 * r4 - 6 * r2 + 1)
    
    -- Z12: Secondary Astigmatism 45° (二级45度像散)
    _Datas[12] = math.sqrt(10) * (4 * r2 - 3) * 2 * x * y
    
    -- Z13: Secondary Astigmatism 0° (二级0度像散)
    _Datas[13] = math.sqrt(10) * (4 * r2 - 3) * (x2 - y2)
    
    -- Z14: Tetrafoil Y (y方向四叶草)
    _Datas[14] = math.sqrt(10) * 4 * x * y * (x2 - y2)
    
    -- Z15: Tetrafoil X (x方向四叶草)
    _Datas[15] = math.sqrt(10) * (x4 - 6 * x2 * y2 + y4)
    
    -- Z16: Secondary Coma Y (二级Y彗差)
    _Datas[16] = math.sqrt(12) * (10 * r4 - 12 * r2 + 3) * y
    
    -- Z17: Secondary Coma X (二级X彗差)
    _Datas[17] = math.sqrt(12) * (10 * r4 - 12 * r2 + 3) * x
    
    -- Z18: Secondary Trefoil Y (二级Y三叶草)
    _Datas[18] = math.sqrt(12) * (5 * r2 - 4) * (3 * x2 * y - y3)
    
    -- Z19: Secondary Trefoil X (二级X三叶草)
    _Datas[19] = math.sqrt(12) * (5 * r2 - 4) * (x3 - 3 * x * y2)
    
    -- Z20: Pentafoil Y (五叶草Y)
    _Datas[20] = math.sqrt(12) * y * (10 * x4 - 20 * x2 * y2 + 2 * y4)
    
    -- Z21: Pentafoil X (五叶草X)
    _Datas[21] = math.sqrt(12) * x * (2 * x4 - 20 * x2 * y2 + 10 * y4)
    
    -- Z22: Secondary Spherical (二级球差)
    _Datas[22] = math.sqrt(7) * (20 * r6 - 30 * r4 + 12 * r2 - 1)
    
    -- Z23: Tertiary Astigmatism 45° (三级45度像散)
    _Datas[23] = math.sqrt(14) * (15 * r4 - 20 * r2 + 6) * 2 * x * y
    
    -- Z24: Tertiary Astigmatism 0° (三级0度像散)
    _Datas[24] = math.sqrt(14) * (15 * r4 - 20 * r2 + 6) * (x2 - y2)
    
    -- Z25: Secondary Tetrafoil Y (二级四叶草Y)
    _Datas[25] = math.sqrt(14) * (6 * r2 - 5) * 4 * x * y * (x2 - y2)
    
    -- Z26: Secondary Tetrafoil X (二级四叶草X)
    _Datas[26] = math.sqrt(14) * (6 * r2 - 5) * (x4 - 6 * x2 * y2 + y4)
    
    -- Z27: Hexafoil Y (六叶草Y)
    _Datas[27] = math.sqrt(14) * 2 * x * y * (3 * x4 - 10 * x2 * y2 + 3 * y4)
    
    -- Z28: Hexafoil X (六叶草X)
    _Datas[28] = math.sqrt(14) * (x2 - y2) * (x4 - 10 * x2 * y2 + 5 * y4)
    
    -- Z29: Tertiary Coma Y (三级Y彗差)
    _Datas[29] = 4 * (35 * r6 - 60 * r4 + 30 * r2 - 4) * y
    
    -- Z30: Tertiary Coma X (三级X彗差)
    _Datas[30] = 4 * (35 * r6 - 60 * r4 + 30 * r2 - 4) * x
    
    return _Datas
end


local GenerateCoefficientsFromVector = function(InVector)
    local _V = Vector.copy(InVector)
    local Length = _V:length()
    _V:Normalize()

    local _Datas = GenerateZernikeCoefficients(_V.x, _V.y)
    for i = 1, #_Datas do
        _Datas[i] = _Datas[i] * Length
    end

    return _Datas
end

function Zernike_Value.new()
    local z = setmetatable({}, Zernike_Value._Meta)
    z:Init()
    return z
end

function Zernike_Value:Init()
    self._Datas = {}
    for i = 1, Z_Num do
        self._Datas[i] = 0
    end
end

function Zernike_Value:AddVectors(InVectors)
    check(#InVectors > 0)
    for i = 1, #InVectors do
        local _V = InVectors[i]
        local _Datas = GenerateCoefficientsFromVector(_V)
        for j = 1, Z_Num do
            self._Datas[j] = self._Datas[j] + _Datas[j]
        end
    end

    for i = 1, #self._Datas do
        self._Datas[i] = self._Datas[i] / #InVectors
    end
end

function Zernike_Value:GetValueFormDirection(InVector)
    local _V = Vector.copy(InVector)
    _V:Normalize()

    local _Datas = GenerateZernikeCoefficients(_V.x, _V.y)
    -- check(#_Datas == #self._Datas)

    local _Result = 0
    for i = 1, Z_Num do
        _Result = _Result + _Datas[i] * self._Datas[i] * math.invc2pi
    end

    return _Result
end
