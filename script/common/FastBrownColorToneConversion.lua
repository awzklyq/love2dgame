_G.FastBrownColorToneConversion = {}

local _RGB_TO_YIQ = {}
_RGB_TO_YIQ[1] = Vector3.new(0.299, 0.587, 0.144)
_RGB_TO_YIQ[2] = Vector3.new(0.596, -0.275, -0.321)
_RGB_TO_YIQ[3] = Vector3.new(0.212, -0.523, 0.311)

local _YIQ_TO_RGB = {}
_YIQ_TO_RGB[1] = Vector3.new(1.0, 0.956, 0.620)
_YIQ_TO_RGB[2] = Vector3.new(1.0, -0.272, -0.647)
_YIQ_TO_RGB[3] = Vector3.new(1.0, -1.108, 1.705)

local _YIQ_TO_RGB_Brown = {}
_YIQ_TO_RGB_Brown[1] = Vector3.new(1.0, 0.2, 0.0)
_YIQ_TO_RGB_Brown[2] = Vector3.new(1.0, 0.2, 0.0)
_YIQ_TO_RGB_Brown[3] = Vector3.new(1.0, 0.2, 0.0)

FastBrownColorToneConversion.ProcessImage = function(InImage)
    check(InImage ~= nil)
    local _Piexls = InImage:GetPixelsAsVector()
    local _H = #_Piexls
    local _W = #_Piexls[1]

    local _YIQs = {}
    for i = 1, _H do
        _YIQs[i] = {}
        for j = 1, _W do
            local _YIQ = Vector3.new()
            local _Piexl = _Piexls[i][j]
            _YIQ.x = Vector3.Dot(_Piexl, _YIQ_TO_RGB[1])
            _YIQ.y = Vector3.Dot(_Piexl, _YIQ_TO_RGB[2])
            _YIQ.z = Vector3.Dot(_Piexl, _YIQ_TO_RGB[3])

            _YIQs[i][j] = _YIQ
        end
    end

    local _ResulColor = {}
    for i = 1, _H do
        _ResulColor[i] = {}
        for j = 1, _W do
            local _C = Vector3.new()
            local _YIQ = _YIQs[i][j]
            _C.x = Vector3.Dot(_YIQ, _YIQ_TO_RGB_Brown[1])
            _C.y = Vector3.Dot(_YIQ, _YIQ_TO_RGB_Brown[2])
            _C.z = Vector3.Dot(_YIQ, _YIQ_TO_RGB_Brown[3])

            _ResulColor[i][j] = _C:AsColor()
        end
    end

    return ImageEx.CreateFromPixels(_H, _W, _ResulColor)
end

FastBrownColorToneConversion.SetIQ = function(InI, InQ)
    InI = InI or 0.2
    InQ = InQ or 0.0
    _YIQ_TO_RGB_Brown[1] = Vector3.new(1.0, InI, InQ)
    _YIQ_TO_RGB_Brown[2] = Vector3.new(1.0, InI, InQ)
    _YIQ_TO_RGB_Brown[3] = Vector3.new(1.0, InI, InQ)
end