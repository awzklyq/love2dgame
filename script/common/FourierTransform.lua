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
        
        _TempDatas[i][1] = _TempDatas[i][1] / _H
        _TempDatas[i][2] = _TempDatas[i][2] / _H
        _TempDatas[i][3] = _TempDatas[i][3] / _H
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