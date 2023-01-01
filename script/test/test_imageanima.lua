
FileManager.addAllPath("assert")

local imageanima = ImageAnima.new("baozha.png", 4, 4, 8)
imageanima:SetFlowMap("baozha_flow.png")
imageanima:Play()

local imageanima1 = ImageAnima.new("baozha.png", 4, 4, 8)
-- imageanima:SetFlowMap("baozha_flow.png")
imageanima1.transform:move(200, 0)
imageanima1:Play()
app.render(function(dt)
    imageanima:draw()
    imageanima1:draw()
end)

app.keypressed(function(key, scancode, isrepeat)
    if key == "space" then
        imageanima1.Tick = 0
        imageanima.Tick = imageanima.Duration * 0.5
    end
end)