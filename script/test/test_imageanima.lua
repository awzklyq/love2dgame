
FileManager.addAllPath("assert")

local imageanima = ImageAnima.new("baozha.png", 4, 4, 2)
imageanima:SetFlowMap("baozha_flow.png")
imageanima:Play()

local imageanima1 = ImageAnima.new("baozha.png", 4, 4, 2)
-- imageanima:SetFlowMap("baozha_flow.png")
imageanima1.transform:move(200, 0)
imageanima1:Play()
app.render(function(dt)
    imageanima:draw()
    imageanima1:draw()
end)

local scrollbar = UI.ScrollBar.new( 'Duration', 10, 10, 200, 40, 0.1, 24, 0.1)
scrollbar.Value = imageanima.Duration
scrollbar.ChangeEvent = function(v)
    imageanima1.Tick = 0
    imageanima.Tick = 0
    imageanima:SetDuration(v)
    imageanima1:SetDuration(v)
end