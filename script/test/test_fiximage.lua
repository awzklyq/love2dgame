
FileManager.addAllPath("assert")

local img = ImageEx.new("preview_122.png")

local img2 = ImageEx.CreateFromImage(img, 100, 100, 100, 100)
img2.renderWidth = 400
img2.renderHeight = 400
app.render(function(dt)
    img2:draw()
end)