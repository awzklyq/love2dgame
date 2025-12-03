_G.FourierTransform = {}
FourierTransform._Meta = {__index = FourierTransform}

function FourierTransform.new()
    local ft = setmetatable({}, FourierTransform._Meta )

    return ft
end

function FourierTransform:BindImage(InImage)
    self._OriDatasVectors = InImage:GetPixelsAsVector()

    check(#self._OriDatasVectors > 0 and #self._OriDatasVectors[1] > 0)
end

function FourierTransform:ProcessTransformImage()
    check(#self._OriDatasVectors > 0 and #self._OriDatasVectors[1] > 0)

    local _H = #self._OriDatasVectors
    local _W = #self._OriDatasVectors[1]

    log("Beging ProcessTransformImage")
    for line = 1, _H do
        self:CacleFourierTransformLine(line)
        log("Beging ProcessTransformImage Line: ", line, _H)
    end

    for row = 1, _W do
        self:CacleFourierTransformRow(row)
        log("Beging ProcessTransformImage Row: ", row, _W)
    end

end

--InDatas[i][j] = Complex.new()
function FourierTransform:SetFourierDatasVectors(InDatas)
    local _H = #InDatas
    local _W = #InDatas[1]
    
    self._FourierDatasVectors = {}
    --TODO
    for i = 1, _H do
        self._FourierDatasVectors[i] = {}
        for j = 1, _W do
            self._FourierDatasVectors[i][j] = {}
            self._FourierDatasVectors[i][j][1] = InDatas[i][j]
            self._FourierDatasVectors[i][j][2] = InDatas[i][j]
            self._FourierDatasVectors[i][j][3] = InDatas[i][j]
        end
    end
end

function FourierTransform:CacleFourierTransformLine(InLine)
    local _H = #self._OriDatasVectors
    local _W = #self._OriDatasVectors[1]
    if not self._FourierDatasVectors then
        self._FourierDatasVectors = {}
    end

    if not self._FourierDatasVectors[InLine] then
        self._FourierDatasVectors[InLine] = {}
    end

    local _FourierDatasVectors = self._FourierDatasVectors[InLine]
    local _Datas = self._OriDatasVectors[InLine]
    for i = 1, _W do
        self._FourierDatasVectors[InLine][i] = {}
        local _FourierDatasVectors_i = self._FourierDatasVectors[InLine][i]
        _FourierDatasVectors_i[1] = Complex.new(0, 0)
        _FourierDatasVectors_i[2] = Complex.new(0, 0)
        _FourierDatasVectors_i[3] = Complex.new(0, 0)
        for j = 1, _W do
            _FourierDatasVectors_i[1] = _FourierDatasVectors_i[1] + self:CacleIntegrateValue(_Datas[j].x, i, j, _W)
            _FourierDatasVectors_i[2] = _FourierDatasVectors_i[2] + self:CacleIntegrateValue(_Datas[j].y, i, j, _W)
            _FourierDatasVectors_i[3] = _FourierDatasVectors_i[3] + self:CacleIntegrateValue(_Datas[j].z, i, j, _W)
        end
    end
end


function FourierTransform:CacleFourierTransformRow(InRow)
    local _H = #self._OriDatasVectors
    local _W = #self._OriDatasVectors[1]
   
    check(self._FourierDatasVectors ~= 0 and  #self._FourierDatasVectors > 0 and #self._FourierDatasVectors[1] > 0)

    local _FourierTransformRow = {} 
    for i = 1, _H do
        _FourierTransformRow[i] = {}
        _FourierTransformRow[i][1] = Complex.new(0, 0)
        _FourierTransformRow[i][2] = Complex.new(0, 0)
        _FourierTransformRow[i][3] = Complex.new(0, 0)
        for j = 1, _H do
            local _Data = self._FourierDatasVectors[j][InRow]
            _FourierTransformRow[i][1] = _FourierTransformRow[i][1] + self:CacleIntegrateValue(_Data[1], i, j, _H)
            _FourierTransformRow[i][2] = _FourierTransformRow[i][2] + self:CacleIntegrateValue(_Data[2], i, j, _H)
            _FourierTransformRow[i][3] = _FourierTransformRow[i][3] + self:CacleIntegrateValue(_Data[3], i, j, _H)
        end
    end

    --Write back..
    for i = 1, _H do
        self._FourierDatasVectors[i][InRow][1] = _FourierTransformRow[i][1]
        self._FourierDatasVectors[i][InRow][2] = _FourierTransformRow[i][2]
        self._FourierDatasVectors[i][InRow][3] = _FourierTransformRow[i][3]
    end
    
end


function FourierTransform:CacleIntegrateValue(InValue, InW, InK, InN)
    local _p = math.c2pi / InN
    local c = Complex.CreateFromAngle(math.deg(InW *  InK * _p) )
    if tonumber(InValue) then
        return c * InValue
    else
        return InValue * c
    end
end

function FourierTransform:Cacle_W(InK, InN)
    local _p = (math.c2pi * InK) / InN
    return Complex.exp(_p)
end

function FourierTransform:GetInverseDataFromIndex(InI, InJ)
    check(#self._InverseDatasVectors > 0 and #self._InverseDatasVectors[1] > 0)
    check(#self._InverseDatasVectors >= InI and #self._InverseDatasVectors[1] >= InJ)
    return self._InverseDatasVectors[InI][InJ]

end

function FourierTransform:InverseProcessTransformImage()
    check(#self._FourierDatasVectors > 0 and #self._FourierDatasVectors[1] > 0)

    self._InverseDatasVectors = {}

    local _H = #self._FourierDatasVectors
    local _W = #self._FourierDatasVectors[1]

    for row = 1, _W do
        self:InverseFourierTransformRow(row)
        -- log("Beging InverseProcessTransformImage Row: ", row, _W)
    end
    
    -- log("Beging InverseProcessTransformImage")
    for line = 1, _H do
        self:InverseFourierTransformLine(line)
        -- log("Beging InverseProcessTransformImage Line: ", line, _H)
    end
end


function FourierTransform:InverseFourierTransformRow(InRow)
    local _H = #self._FourierDatasVectors
    local _W = #self._FourierDatasVectors[1]

    if not self._InverseDatasVectors then
        self._InverseDatasVectors = {}
    end

    for i = 1, _H do
        if not self._InverseDatasVectors[i] then
            self._InverseDatasVectors[i] = {}
        end

        if not self._InverseDatasVectors[i][InRow] then
            self._InverseDatasVectors[i][InRow] = {}
        end

        local _InverseDatasVectors = self._InverseDatasVectors[i][InRow]
        _InverseDatasVectors[1] = Complex.new(0, 0)
        _InverseDatasVectors[2] = Complex.new(0, 0)
        _InverseDatasVectors[3] = Complex.new(0, 0)
        for j = 1, _H do
            local _Data = self._FourierDatasVectors[j][InRow]
            _InverseDatasVectors[1] = _InverseDatasVectors[1] + self:CacleIntegrateValue(_Data[1], i, j, _H)
            _InverseDatasVectors[2] = _InverseDatasVectors[2] + self:CacleIntegrateValue(_Data[2], i, j, _H)
            _InverseDatasVectors[3] = _InverseDatasVectors[3] + self:CacleIntegrateValue(_Data[3], i, j, _H)           
        end  
        
        _InverseDatasVectors[1] = _InverseDatasVectors[1] / _H
        _InverseDatasVectors[2] = _InverseDatasVectors[2] / _H
        _InverseDatasVectors[3] = _InverseDatasVectors[3] / _H
    end
end

function FourierTransform:InverseFourierTransformLine(InLine)
    check(#self._InverseDatasVectors > 0 and #self._InverseDatasVectors[1] > 0)

    local _H = #self._FourierDatasVectors
    local _W = #self._FourierDatasVectors[1]

    local _InverseDatasVectors = self._InverseDatasVectors[InLine]
    local _TempDatas = {}
    for i = 1, _W do
        _TempDatas[i] = {}
        _TempDatas[i][1] = Complex.new(0, 0)
        _TempDatas[i][2] = Complex.new(0, 0)
        _TempDatas[i][3] = Complex.new(0, 0)
        for j = 1, _W do
            local _Data = _InverseDatasVectors[j]
            _TempDatas[i][1] = _TempDatas[i][1] + self:CacleIntegrateValue(_Data[1], i, j, _W)
            _TempDatas[i][2] = _TempDatas[i][2] + self:CacleIntegrateValue(_Data[2], i, j, _W)
            _TempDatas[i][3] = _TempDatas[i][3] + self:CacleIntegrateValue(_Data[3], i, j, _W)           
        end  
        
        _TempDatas[i][1] = _TempDatas[i][1] / _W
        _TempDatas[i][2] = _TempDatas[i][2] / _W
        _TempDatas[i][3] = _TempDatas[i][3] / _W
    end

    --Write data back...
     for i = 1, _W do
        _InverseDatasVectors[i][1] = _TempDatas[i][1]
        _InverseDatasVectors[i][2] = _TempDatas[i][2]
        _InverseDatasVectors[i][3] = _TempDatas[i][3]
     end
end

function FourierTransform:UseInverseDatasGenerateImage()
    local _Pixels = {}
    local _H = #self._InverseDatasVectors
    local _W = #self._InverseDatasVectors[1]
    log("Begin UseInverseDatasGenerateImage.")
    for i = 1, _H  do
        _Pixels[i] = {}
        for j = 1, _W do
            local IndexI = _H - i  + 1
            local IndexJ = _W - j  + 1
            local _Data = self._InverseDatasVectors[IndexI][IndexJ]
            local _Real1 = _Data[1]:GetReal()
            local _Real2 = _Data[2]:GetReal()
            local _Real3 = _Data[3]:GetReal()
            _Pixels[i][j] = LColor.new(_Real1, _Real2, _Real3)
        end
    end

    local TestImageData = ImageDataEx.new(_H, _W, 'rgba8')
    TestImageData:SetPixels(_Pixels)
    self._GenerateImage = TestImageData:GetImage()

    log("UseInverseDatasGenerateImage Done.")

    return self._GenerateImage
end

function FourierTransform:BindDatas_2D(InDatas)
    check(#InDatas > 0 and #InDatas[1] > 0)

    self._OriDatasVectors = {}
    local _BH = #InDatas
    local _BW = #InDatas[1]

    for i = 1, _BH do
        self._OriDatasVectors[i] = {}
        for j = 1, _BW do
            local _Data = InDatas[i][j]
            self._OriDatasVectors[i][j] = Vector3.new(_Data, _Data, _Data) 
        end
    end
end
function FourierTransform:GetOriW()
    return #self._OriDatasVectors[1]
end

function FourierTransform:GetOriH()
    return #self._OriDatasVectors
end

function FourierTransform:BindDatasAlign_2D(InDatas, InW, InH)
    check(#InDatas > 0 and #InDatas[1] > 0)

    self._OriDatasVectors = {}
    local _BH = #InDatas
    local _BW = #InDatas[1]

    -- InW = math.ceil(InW *0.5)
    -- InH = math.ceil(InH *0.5)

    check(InW > _BW and InH > _BH)

    local _CenterW = math.ceil(InW / 2)
    local _CenterH = math.ceil(InH / 2)
    local _TempDatas = {}
    for i = 1, InH do
        _TempDatas[i] = {}
        for j = 1, InW do
            _TempDatas[i][j] = Complex.new(0, 0) 
        end
    end

    local _StartW = InW - _BW + 1--_CenterW - math.ceil(_BW / 2)
    local _StartH = InH - _BH + 1--_CenterH - math.ceil(_BH / 2)
    -- log('bbbbbbb', _StartW, _StartH)
    for i = _StartH , InH do
        for j = _StartW , InW do
            -- log('aaaaaa', i, j, i - _StartH + 1, j - _StartW + 1)
            _TempDatas[i][j] = Complex.new( InDatas[i - _StartH + 1][j - _StartW + 1], 0)
        end
    end

    self:BindDatas_2D(_TempDatas)
end

function FourierTransform:GetFourierDataScroll_2D(InI, InJ)
    check(#self._FourierDatasVectors > 0 and #self._FourierDatasVectors[1] > 0)
    local _Datas
    local _LEN1 = #self._FourierDatasVectors
    if InI <= _LEN1 then
        _Datas = self._FourierDatasVectors[InI]
    else
        if InI % _LEN1 == 0 then
            _Datas = self._FourierDatasVectors[_LEN1]
        else
            _Datas = self._FourierDatasVectors[InI % _LEN1]
        end
    end

    local _Data
    local _LEN2 = #_Datas
    if InJ <= _LEN2 then
        _Data = _Datas[InJ]
    else
        if InJ % _LEN2 == 0 then
            _Data = _Datas[_LEN2]
        else
            _Data = _Datas[InJ % _LEN2]
        end
    end

    return _Data
end

function FourierTransform:BlurFromFT(InFT)
    check(#self._FourierDatasVectors > 0 and #self._FourierDatasVectors[1] > 0)

    log("FourierTransform Begin FourierTransform")

    -- log('BlurData _Result', _Result:GetReal(), _Result:GetImag())         
    local _H = #self._FourierDatasVectors
    local _W = #self._FourierDatasVectors[1]
    for i = 1, _H do
        for j = 1, _W do
            local _BlurData = InFT:GetFourierDataScroll_2D(i, j)
            -- local _BlurData = InFT._FourierDatasVectors[i][j]
            self._FourierDatasVectors[i][j][1] = self._FourierDatasVectors[i][j][1] *  _BlurData[1]:GetReal()
            self._FourierDatasVectors[i][j][2] = self._FourierDatasVectors[i][j][2] *  _BlurData[2]:GetReal()
            self._FourierDatasVectors[i][j][3] = self._FourierDatasVectors[i][j][3] *  _BlurData[3]:GetReal()
        end
    end

    log("FourierTransform FourierTransform Done")
end

function FourierTransform:BindDatas_1D(InDatas, InLen, IsInvers)
    check(#InDatas > 0)
    InLen = InLen or 0
    local OffsetLen = 0
    if InLen > #InDatas then
         OffsetLen = InLen - #InDatas
    end

    if IsInvers then
        local _Temp = InDatas
        InDatas = {}
        for i = #_Temp, 1, -1 do
            InDatas[#InDatas + 1] = _Temp[i]
        end
    end

    self._OriDatas_1D = {}
    local _LEN =  math.max(#InDatas, InLen)
    for i = 1 , _LEN do
        if i < OffsetLen + 1 then
             self._OriDatas_1D[i] = 0
        else
            self._OriDatas_1D[i] = InDatas[i - OffsetLen]
        end
    end
end

function FourierTransform:ProcessTransformDatas_1D(InNum)
    check( #self._OriDatas_1D > 0)

    InNum = InNum or #self._OriDatas_1D


    local _LEN = #self._OriDatas_1D
    self._FourierDatas_1D = {}
    for i = 1, InNum do
        local _Result = Complex.new(0, 0)
        for j = 1, _LEN do
            _Result = _Result + self:CacleIntegrateValue(self._OriDatas_1D[j], i, j, _LEN)
        end

        self._FourierDatas_1D[i] =_Result
    end
end

function FourierTransform:InverseFourierTransform_1D()
    check(self._FourierDatas_1D and #self._FourierDatas_1D > 0 and #self._OriDatas_1D > 0)

    self._InverseDatas_1D = {}
    
    local _LEN1 = #self._OriDatas_1D
    local _LEN2 = #self._FourierDatas_1D
    for i = 1, _LEN1 do
        local _Result = Complex.new(0, 0) 
        for j = 1, _LEN2 do
            _Result = _Result  + self:CacleIntegrateValue(self._FourierDatas_1D[j], j, i - 1, _LEN2)           
        end
        self._InverseDatas_1D[_LEN1 - i + 1] = _Result /_LEN2
    end
end

function FourierTransform:FFT_Base2_1D()
    check( #self._OriDatas_1D > 0 and #self._OriDatas_1D % 2 == 0)

    -- local InNum = #self._OriDatas_1D / 2 - 1
    local _N_2 =  #self._OriDatas_1D / 2
    local _N =  #self._OriDatas_1D
    self._FourierDatas_1D = {}
    for i = 1, _N_2  do
        local _Result_1 = Complex.new(0, 0)
        local _Result_2 = Complex.new(0, 0)
        for j = 1, _N_2  do
            local _Index_2r = j * 2
            _Result_1 = _Result_1 + self:Cacle_W( -j * i * 2 , _N) *  self._OriDatas_1D[_Index_2r]
            _Result_2 = _Result_2 + self:Cacle_W( -j * i * 2, _N) *  self._OriDatas_1D[_Index_2r - 1]
        end

        self._FourierDatas_1D[i] =_Result_2 + self:Cacle_W(- i, _N) * _Result_1
        self._FourierDatas_1D[i + _N_2] = _Result_2 - self:Cacle_W(- i, _N) * _Result_1
    end

    -- log('aaaaaaaa', self._FourierDatas_1D[1]:GetReal(), self._FourierDatas_1D[1]:SquaredLength(), self._FourierDatas_1D[2]:GetReal(), self._FourierDatas_1D[2]:SquaredLength(), self._FourierDatas_1D[4]:GetReal(), self._FourierDatas_1D[4]:SquaredLength(),  self._FourierDatas_1D[5]:GetReal(), self._FourierDatas_1D[5]:SquaredLength())

    -- for i = 1, _N do
    --     local _Result_1 = Complex.new(0, 0)
    --     for j = 1, _N do
    --         _Result_1 = _Result_1 + self:Cacle_W(-j * i, _N) *  self._OriDatas_1D[j]
    --     end

    --     self._FourierDatas_1D[i] = _Result_1
    -- end

    -- log('bbbbbbbbbb', self._FourierDatas_1D[1]:GetReal(), self._FourierDatas_1D[1]:SquaredLength(), self._FourierDatas_1D[2]:GetReal(), self._FourierDatas_1D[2]:SquaredLength(), self._FourierDatas_1D[4]:GetReal(), self._FourierDatas_1D[4]:SquaredLength(),  self._FourierDatas_1D[5]:GetReal(), self._FourierDatas_1D[5]:SquaredLength())
end
function FourierTransform:IFFT_1D()
    check(self._FourierDatas_1D and #self._FourierDatas_1D > 0 and #self._OriDatas_1D > 0)

    self._InverseDatas_1D = {}
    local _N_2 =  #self._FourierDatas_1D / 2
    local _N =  #self._FourierDatas_1D
    for i = 1, _N_2 do
        local _Result_1 = Complex.new(0, 0) 
        local _Result_2 = Complex.new(0, 0) 
        for j = 1, _N_2 do
            local _Index_2r = j * 2
            _Result_1 = _Result_1 + self:Cacle_W(j * i * 2, _N) *  self._FourierDatas_1D[_Index_2r]
            _Result_2 = _Result_2 + self:Cacle_W(j * i * 2, _N) *  self._FourierDatas_1D[_Index_2r - 1]    
        end

        local _Index1 = i - 1
        local _Index2 = i + _N_2 - 1
        self._InverseDatas_1D[_Index1 == 0 and _N or _Index1] =(_Result_2 + self:Cacle_W(i , _N) * _Result_1) / _N
        self._InverseDatas_1D[_Index2] = (_Result_2 - self:Cacle_W( i , _N) * _Result_1) / _N

    end
end

function FourierTransform.Convolution_1D(InFT1, InFT2 )
    local _NewFT = FourierTransform.new()
    _NewFT._OriDatas_1D = {}

    local _OriDatas_1D_From_InFT1 = InFT1._OriDatas_1D
    for i = 1, #_OriDatas_1D_From_InFT1 do
        _NewFT._OriDatas_1D[i] = _OriDatas_1D_From_InFT1[i]
    end

    local _FourierDatas_From_InFT1 = InFT1._FourierDatas_1D
    local _FourierDatas_From_InFT2 = InFT2._FourierDatas_1D

    _NewFT._FourierDatas_1D = {}
    for i =  #_OriDatas_1D_From_InFT1, 1, -1 do
        _NewFT._FourierDatas_1D[i] = _FourierDatas_From_InFT1[i] * _FourierDatas_From_InFT2[i]
    end

    return _NewFT
end
function FourierTransform:Log( )
    if self._FourierDatasVectors then
        local _H = #self._FourierDatasVectors
        local _W = #self._FourierDatasVectors[1]
        for i = 1, _H do
            local Str1 = ""
            local Str2 = ""
            local Str3 = ""
            for j = 1, _W do
                Str1 = Str1 .. " " .. self._FourierDatasVectors[i][j][1]:GetReal()
                Str2 = Str2 .. " " .. self._FourierDatasVectors[i][j][2]:GetReal()
                Str3 = Str3 .. " " .. self._FourierDatasVectors[i][j][3]:GetReal()
            end
            log("FourierTransform Line1", i, Str1)
            log("FourierTransform Line1", i, Str2)
            log("FourierTransform Line1", i, Str3)
            log()
        end
    end

    if self._OriDatas_1D then
        local Str1 = ""
        for i = 1, #self._OriDatas_1D do
              Str1 = Str1 .. " " .. tostring(self._OriDatas_1D[i])
        end
        log("FourierTransform _OriDatas_1D:")
        log(Str1)
        log()
    end

    if self._FourierDatas_1D then
        local Str1 = ""
        local Str2 = ""
        for i = 1, #self._FourierDatas_1D do
              Str1 = Str1 .. " " .. tostring(self._FourierDatas_1D[i]:GetReal())
              Str2 = Str2 .. " " .. tostring(self._FourierDatas_1D[i]:GetImag())
        end
        log("FourierTransform _FourierDatas_1D:")
        log(Str1)
        log(Str2)
        log()
    end

    if self._InverseDatas_1D then
        local Str1 = ""
        local Str2 = ""
        local Str3 = ""
        for i = 1, #self._InverseDatas_1D do
            Str1 = Str1 .. " " .. tostring(self._InverseDatas_1D[i]:GetReal())
            Str2 = Str2 .. " " .. tostring(self._InverseDatas_1D[i]:GetImag())
            Str3 = Str3 .. " " .. tostring(self._InverseDatas_1D[i]:SquaredLength())
        end
        log("FourierTransform _InverseDatas_1D:")
        log(Str1)
        log(Str2)
        log(Str3)
        log()
    end
end