
FileManager.addAllPath("assert")

RenderSet.BGColor = LColor.new(80,80,80,255)

local img = ImageEx.new("shenzhenjichang.jpg")

local Result = img:Histogram()
local h = HistogramRender.CreateFromTwoDimensionalArray(Result, 100, 600, 500, 2)

local ColorDatas = img:HistogramEqualization()
local TestImageData = ImageDataEx.new(img.w, img.h, 'rgba8')
TestImageData:SetPixelsFromDatas(ColorDatas)
local TempImg = TestImageData:GetImage()
local TempResult = TempImg:Histogram()
local TempH = HistogramRender.CreateFromTwoDimensionalArray(TempResult, 100, 600, 500, 2)

local IsRenderImage = true
local IsRenderHE = false
app.render(function(dt)
    if IsRenderHE then
        if IsRenderImage then
            TempImg:draw()
        else
            TempH:draw()
        end
    else
        if IsRenderImage then
            img:draw()
        else
            h:draw()
        end
    end
    -- img:draw()
    
end)

local checkb = UI.CheckBox.new( 100, 100, 20, 20, "RenderImage" )
checkb.IsSelect = IsRenderImage
checkb.ChangeEvent = function(Enable)
    IsRenderImage = Enable
end

local checka = UI.CheckBox.new( 100, 150, 20, 20, "RenderHE" )
checka.IsSelect = IsRenderHE
checka.ChangeEvent = function(Enable)
    IsRenderHE = Enable
end