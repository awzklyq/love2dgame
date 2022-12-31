
FileManager.addAllPath("assert")

local imageanima = ImageAnima.new("baozha.png", 4, 4, 4)
imageanima:Play()
app.render(function(dt)
    imageanima:draw()
end)