
FileManager.addAllPath("assert")

RenderSet.BGColor = LColor.new(80,80,80,255)

local img = ImageEx.new("itgongzuo.jpg")

local img2 = FastBrownColorToneConversion.ProcessImage(img)
local _IsDrawOri = true
app.render(function(dt)
    if _IsDrawOri then
        img:draw()
    else
        img2:draw()
    end
end)

local checkb = UI.CheckBox.new( 10, 10, 20, 20, "IsDrawOriImg" )
checkb.IsSelect = _IsDrawOri
checkb.ChangeEvent = function(Enable)
    _IsDrawOri = Enable
end

local _I = 0.2
local _Q = 0.0
local scrollbarI = UI.ScrollBar.new( 'I Value', 10, 40, 100, 40, 0.0, 1.0, 0.1)
scrollbarI.Value = _I
scrollbarI.ChangeEvent = function(v)
    _I = v
    FastBrownColorToneConversion.SetIQ(_I, _Q)

    img2 = FastBrownColorToneConversion.ProcessImage(img)
end

local scrollbarQ = UI.ScrollBar.new( 'Q Value', 10, 10, 100, 40, 0.0, 1.0, 0.1)
scrollbarQ.Value = _Q
scrollbarQ.ChangeEvent = function(v)
    _Q = v
    FastBrownColorToneConversion.SetIQ(_I, _Q)

    img2 = FastBrownColorToneConversion.ProcessImage(img)
end