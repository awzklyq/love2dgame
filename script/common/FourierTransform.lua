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

function FourierTransform:InverseProcessTransformImage()
    check(#self._FourierDatasVectors > 0 and #self._FourierDatasVectors[1] > 0)

    self._InverseDatasVectors = {}

    local _H = #self._FourierDatasVectors
    local _W = #self._FourierDatasVectors[1]

    for row = 1, _W do
        self:InverseFourierTransformRow(row)
        log("Beging InverseProcessTransformImage Row: ", row, _W)
    end
    
    log("Beging InverseProcessTransformImage")
    for line = 1, _H do
        self:InverseFourierTransformLine(line)
        log("Beging InverseProcessTransformImage Line: ", line, _H)
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

function FourierTransform:BindDatas(InDatas)
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

function FourierTransform:BindDatasAlign(InDatas, InW, InH)
    check(#InDatas > 0 and #InDatas[1] > 0)

    self._OriDatasVectors = {}
    local _BH = #InDatas
    local _BW = #InDatas[1]

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

    local _StartW = _CenterW - math.ceil(_BW / 2)
    local _StartH = _CenterH - math.ceil(_BH / 2)
    -- log('bbbbbbb', _StartW, _StartH)
    for i = _StartH, _StartH + _BH - 1 do
        for j = _StartW, _StartW + _BW - 1 do
            -- log('aaaaaa', i, j, i - _StartH + 1, j - _StartW + 1)
            _TempDatas[i][j] = Complex.new( InDatas[i - _StartH + 1][j - _StartW + 1], 0)
        end
    end

    self:BindDatas(_TempDatas)
end

function FourierTransform:GetFourierDataScroll(InI, InJ)
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
            local _BlurData = InFT:GetFourierDataScroll(i, j)
            self._FourierDatasVectors[i][j][1] = self._FourierDatasVectors[i][j][1] *  _BlurData[1]
            self._FourierDatasVectors[i][j][2] = self._FourierDatasVectors[i][j][2] *  _BlurData[2]
            self._FourierDatasVectors[i][j][3] = self._FourierDatasVectors[i][j][3] *  _BlurData[3]
        end
    end

    log("FourierTransform FourierTransform Done")
end

function FourierTransform:Log( )
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