
FileManager.addAllPath("assert")

RenderSet.BGColor = LColor.new(80,80,80,255)

local img = ImageEx.new("c.png")

local img2 = img:ErasurePixel(LColor.new(0, 0, 0))
img2.renderWidth = 400
img2.renderHeight = 400
app.render(function(dt)
    img2:draw()
end)