local TestW = 3.0
local TestK = 19.2

local TestN = 20
local TestA = math.c2pi / TestN
local cw = Complex.new(TestW ,0)
local ck = Complex.new(TestK ,0)
local ca = Complex.new(0 ,TestA)

-- local c1 = cw * ck * ca
local TestB = TestW * TestK * TestA
local c1 = Complex.new(0 ,TestB) 
local c2 = Complex.Exp(c1)
c2:Log('c2')

log(math.deg(math.c2pi))

local c3 = Complex.CreateFromAngle(math.deg(TestB ) )

c3:Log('c3')

FileManager.addAllPath("assert")

-- RenderSet.BGColor = LColor.new(80,80,80,255)

local img = ImageEx.new("sara-cal1.png")

local _FT = FourierTransform.new()
_FT:BindImage(img)
_FT:ProcessTransformImage()

local _BlurFT = FourierTransform.new()
local _BlurDatas = {}
_BlurDatas[1] = {0.001, 0.1, 0.25, 0.1, 0.001}
_BlurDatas[2] = {0.1, 0.35, 0.5, 0.35, 0.1}
_BlurDatas[3] = {0.25, 0.5, 1, 0.5, 0.25}
_BlurDatas[4] = {0.1, 0.35, 0.5, 0.35, 0.1}
_BlurDatas[5] = {0.001, 0.1, 0.25, 0.1, 0.001}

local _All = 0
for i = 1, 5 do
    for j = 1, 5 do
        _All = _All + _BlurDatas[i][j]
    end
end

for i = 1, 5 do
    for j = 1, 5 do
        _BlurDatas[i][j] = _BlurDatas[i][j] / _All * 1.01
    end
end
-- FourierTransform:BindDatasAlign
_BlurFT:BindDatasAlign(_BlurDatas, _FT:GetOriW(), _FT:GetOriH())
-- _BlurFT:BindDatas(_BlurDatas)
_BlurFT:ProcessTransformImage()

_FT:BlurFromFT(_BlurFT)

_FT:InverseProcessTransformImage()

local _FTImg = _FT:UseInverseDatasGenerateImage()
local _IsDrawOri = true
app.render(function(dt)
    if _IsDrawOri then
        img:draw()
    else
        _FTImg:draw()
    end
end)

local checkb = UI.CheckBox.new( 10, 150, 20, 20, "IsDrawOriImg" )
checkb.IsSelect = _IsDrawOri
checkb.ChangeEvent = function(Enable)
    _IsDrawOri = Enable
end