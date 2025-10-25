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