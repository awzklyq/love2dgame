
FileManager.addAllPath("assert")

RenderSet.BGColor = LColor.new(80,80,80,255)

local img = ImageEx.new("shenzhenjichang.jpg")

local Result = img:Histogram()

local h = HistogramRender.CreateFromTwoDimensionalArray(Result, 100, 600, 500, 2)

local IsRenderImage = true

app.render(function(dt)
    if IsRenderImage then
        img:draw()
    else
        h:draw()
    end
    -- img:draw()
    
end)

local checkb = UI.CheckBox.new( 100, 100, 20, 20, "RenderImage" )
checkb.IsSelect = IsRenderImage
checkb.ChangeEvent = function(Enable)
    IsRenderImage = Enable
end