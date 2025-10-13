dofile('script/demo/BilateralFilter/demo_BilateralFilter_Grid3D.lua') 

FileManager.addAllPath("assert")

local _OriImg = ImageEx.new("SkyTest.png")

-- local _Grid3 = BilateralFilter_Grid3D.new(64, 32, 64)
local _Grid3 = BilateralFilter_Grid3D.new(64, 32, 64)
_Grid3:SetImage(_OriImg)

local _Pixels = _OriImg:GetPixels()
local _W = #_Pixels
local _H = #_Pixels[1]

local _M = _Pixels[math.ceil(_W * 0.5)][math.ceil(_H * 0.5)]:GetLogLuminance()
local TestImage
local _ScaleL = 1.0
function ReGenerate()
   local TestImageData = ImageDataEx.new(_W, _H, 'rgba8')

    for ix = 1, _W do
        for iy = 1, _H do
            local _l = _Grid3:SampleFromPixel(ix, iy, _Pixels[ix][iy], _M, _ScaleL)

            local _C = LColor.Copy(_Pixels[ix][iy]):MulLuminance(_l)
            TestImageData:SetPixel(ix - 1, iy - 1, _C)
        end
    end

    TestImage = TestImageData:GetImage() 
end

ReGenerate()

local IsDrawOriImg = true
app.render(function(dt)
    -- _OriImg:draw()
    if IsDrawOriImg then
        _OriImg:draw()
    else
        TestImage:draw()
    end
    -- love.graphics.print( "Press Key A.  RenderSet.AlphaTestMode: "..tostring(RenderSet.AlphaTestMode), 10, 10)
end)


local checkb = UI.CheckBox.new( 10, 10, 20, 20, "IsDrawOriImg" )
checkb.IsSelect = IsDrawOriImg
checkb.ChangeEvent = function(Enable)
    IsDrawOriImg = Enable
end

local scrollbar = UI.ScrollBar.new( 'test', 10, 40, 200, 40, 0.1, 2, 0.1)
scrollbar.Value = _ScaleL
scrollbar.ChangeEvent = function(v)
    _ScaleL = v
end

local btn = UI.Button.new( 10, 90, 100, 50, 'Generate', 'btn' )

btn.ClickEvent = function()
    ReGenerate()
end