
FileManager.addAllPath("assert")

-- local img = ImageEx.new("sara-cal2.png")
-- local imageanima = ImageAnima.CreateFromImage(img, 1, 1, 9, 1, 9, 4, 2)

local imageanima =ImageAnima.new("sara-cal2.png", 9, 4, 2)
imageanima:Play()

imageanima.transform:move(200, 200)
imageanima.transform:scale(3, 3)


app.render(function(dt)
    imageanima:draw()
end)

local scrollbar = UI.ScrollBar.new( 'Duration', 10, 10, 200, 40, 0.001, 8, 0.001)
scrollbar.Value = imageanima.Duration
scrollbar.ChangeEvent = function(v)
    imageanima.Tick = 0
    imageanima:SetDuration(v)
end