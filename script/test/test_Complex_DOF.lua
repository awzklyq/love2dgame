--GDC : Circular Separable Convolution Depth of Field “Circular Dof”Kleber Garcia Rendering Engineer – Frostbite Engine Electronic Arts Inc.

FileManager.addAllPath("assert")

RenderSet.BGColor = LColor.new(80,80,80,255)

local Mat2 = Matrix2D.new()

local W = 64
local H = 64
local _Pixels = {}
for i = 1, H  do
    _Pixels[i] = {}
    for j = 1, W do
        if (i < 31 or i > 33) or (j < 31 or j > 33) then
            _Pixels[i][j] = LColor.new(0, 0, 0)
        else
            _Pixels[i][j] = LColor.new(255, 255, 255)
        end

    end
end

local GetReal = function(a, b, X2)
    return math.exp(-a * X2) * math.cos(b * X2)
end

local GetImag = function(a, b, X2)
    return math.exp(-a * X2) * math.sin(b * X2)
end

local a = -0.886528
local b = 5.268509
local A = 0.411259
local B = -0.548794
local BaseColor = Vector3.new(255, 255, 255)
local _FinalPiexls = {}
local _RealPiexls = {}
local _ImagPiexls = {}
local HalfH = H / 2
local HalfW = W / 2
local Distance = HalfH * HalfH + HalfW * HalfW
for i = 1, H  do
    _FinalPiexls[i] = {}
    _RealPiexls[i] = {}
    _ImagPiexls[i] = {}
    for j = 1, W do
        local xd = j - HalfW
        local yd = i - HalfH
        local d = xd * xd + yd * yd
        local angled = (d / Distance) * math.pi 
        local real = BaseColor * GetReal(a, b, angled)
        local imag = BaseColor * GetImag( a, b, angled) 
        local color =  real * A +  imag * B
        _FinalPiexls[i][j] = color:AsColor()
        _RealPiexls[i][j] = real:AsColor()
        _ImagPiexls[i][j] = imag:AsColor()
    end
end

local OriImageData = ImageDataEx.new(W, H, 'rgba8')
OriImageData:SetPixels(_Pixels)

-- local OriImage s= ImageEx.new("WhiteBlock.png")
local OriImage = OriImageData:GetImage()
local RealImage = ImageEx.CreateFromPixels(W, H, _RealPiexls)
local ImagImage = ImageEx.CreateFromPixels(W, H, _ImagPiexls)
local FinalImage = ImageEx.CreateFromPixels(W, H, _FinalPiexls)
app.render(function(dt)
    OriImage:draw()

    Mat2:SetTranslation(64 + 1, 0)
    RenderSet.PushMatrix2D(Mat2)
    RealImage:draw()
    RenderSet.PopMatrix2D()

    Mat2:SetTranslation(128 + 2, 0)
    RenderSet.PushMatrix2D(Mat2)
    ImagImage:draw()
    RenderSet.PopMatrix2D()

    Mat2:SetTranslation(192 + 3, 0)
    RenderSet.PushMatrix2D(Mat2)
    FinalImage:draw()
    RenderSet.PopMatrix2D()
end)