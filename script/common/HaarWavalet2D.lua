_G.HaarWavalet2D = {}

HaarWavalet2D._Meta = {__index = HaarWavalet2D}

function HaarWavalet2D.new(InImage)
    local haar = setmetatable({}, HaarWavalet2D._Meta)

    haar:Init(InImage)
    
    return haar
end

function HaarWavalet2D:Init(InImage)
     self._OriImage = InImage

     self:GetOriImagePixels()

     local _W = #self._Pixels
     local _H = #self._Pixels[1]
     self:Process(self._Pixels, _W, _H, _W, _H)

    _errorAssert(self._AvgW % 2 == 0 and self._AvgH % 2 == 0)

    self._AvgW = self._AvgW / 2
    self._AvgH = self._AvgH / 2
end

function HaarWavalet2D:GetOriImagePixels()
    local _Pixels = self._OriImage:GetPixels()

    local _W = #_Pixels
    local _H = #_Pixels[1]

    --Fix w or h
    if _W % 2 ~= 0 then
        _W = _W - 1
    end

    if _H % 2 ~= 0 then
        _H = _H - 1
    end

    _errorAssert(_W > 1 and _H >1)

    self._OriW = _W
    self._OriH = _H
    self._Pixels = {}
    for i = 1, _W do
        self._Pixels[i] = {}
        for j = 1, _H do
            self._Pixels[i][j] = _Pixels[i][j]:AsVector()
        end
    end
end

function HaarWavalet2D:Process(InPixels, InOriW, InOriH, InAvgW, InAvgH)
    if InAvgW % 2 ~= 0 or InAvgH % 2 ~= 0 then
        return
    end

    -- for j = 1, InAvgH do
    --     local TempPixels = {}
    --     for i = 1, InAvgW, 2 do
    --         local p1 = self._Pixels[i][j] 
    --     end
    -- end

    for i = 1, InAvgW do
        local TempPixels = {}
        local _Index = 1
        for j = 1, InAvgH, 2 do
            local p1 = InPixels[i][j]
            local p2 = InPixels[i][j + 1]

            -- log(InAvgW, InAvgH, #InPixels[i], i, j, p1, p2)
            TempPixels[_Index] = (p1 + p2) / 2

            local C1 = p1:AsColor()
            local C2 = p2:AsColor()

            local l = math.abs(C1:GetLuminance() - C2:GetLuminance())
            if l > 0.5 then
                TempPixels[InAvgH / 2 + _Index] = Vector3.cOrigin
            else
                TempPixels[InAvgH / 2 + _Index] = (p1 - p2) / 2
            end

            _Index = _Index + 1
        end

         for j = 1, InAvgH do
            InPixels[i][j] = TempPixels[j]
         end
    end

    for j = 1, InAvgH do
        local TempPixels = {}
        local _Index = 1
        for i = 1, InAvgW, 2 do
            local p1 = InPixels[i][j]
            local p2 = InPixels[i + 1][j]

            TempPixels[_Index] = (p1 + p2) / 2

            local C1 = p1:AsColor()
            local C2 = p2:AsColor()

            local l = math.abs(C1:GetLuminance() - C2:GetLuminance())
            if l > 0.5 then
                TempPixels[InAvgW / 2 + _Index] = Vector3.cOrigin
            else
                TempPixels[InAvgW / 2 + _Index] = (p1 - p2) / 2
            end
            
            _Index = _Index + 1
        end

         for i = 1, InAvgW do
            InPixels[i][j] = TempPixels[i]
         end
    end

    self._AvgW = InAvgW
    self._AvgH = InAvgH

    local _NewAvgH = InAvgH / 2
    local _NewAvgW = InAvgW / 2

    self:Process(InPixels, InOriW, InOriH, _NewAvgW, _NewAvgH)
end

function HaarWavalet2D:InverseProcess()
    self:InverseProcessInner(self._Pixels, self._OriW, self._OriH, self._AvgW, self._AvgH)
end

function HaarWavalet2D:InverseProcessInner(InPixels, InOriW, InOriH, InAvgW, InAvgH)
    if InAvgW == InOriW or InAvgH == InOriH then
        return
    end

    for j = 1, InAvgH * 2 do
        local TempPixels = {}
        local _Index = 1
        for i = 1, InAvgW do
            local p1 = InPixels[i][j]
            local p2 = InPixels[InAvgW + i][j]

            TempPixels[_Index] = p1 + p2
            _Index = _Index + 1
            TempPixels[_Index] = p1 - p2
            _Index = _Index + 1
        end

         for i = 1, InAvgW * 2 do
            InPixels[i][j] = TempPixels[i]
         end
    end

    for i = 1, InAvgW * 2 do
        local TempPixels = {}
        local _Index = 1
        for j = 1, InAvgH do
            local p1 = InPixels[i][j]
            local p2 = InPixels[i][InAvgH + j]

            -- log(InAvgW, InAvgH, #InPixels[i], i, j, p1, p2)
            TempPixels[_Index] = p1 + p2
            _Index = _Index + 1
            TempPixels[_Index] = p1 - p2
            _Index = _Index + 1
        end

         for j = 1, InAvgH * 2 do
            InPixels[i][j] = TempPixels[j]
         end
    end

    local _NewAvgH = InAvgH * 2
    local _NewAvgW = InAvgW * 2

    self:InverseProcessInner(InPixels, InOriW, InOriH, _NewAvgW, _NewAvgH)
end

function HaarWavalet2D:GenerateImageData()
    if self._GenerateImage then
        return self._GenerateImage
    end
    local _Pixels = {}
    for i = 1, self._OriW  do
        _Pixels[i] = {}
        for j = 1, self._OriH do
            _Pixels[i][j] = self._Pixels[i][j]:AsColor()
        end
    end

    local TestImageData = ImageDataEx.new(self._OriW, self._OriH, 'rgba8')
    TestImageData:SetPixels(_Pixels)
    self._GenerateImage = TestImageData:GetImage()
    return self._GenerateImage
end