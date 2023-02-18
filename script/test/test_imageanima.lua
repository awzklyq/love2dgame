
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
    love.graphics.print( "Press Key Space.  imageanima.Duration "..tostring(imageanima.Duration) , 10, 10)
end)

app.keypressed(function(key, scancode, isrepeat)
    if key == "space" then
        imageanima1.Tick = 0
        imageanima.Tick = 0
    elseif key == 'up' then
        imageanima:SetDuration(imageanima.Duration + 1)
        imageanima1:SetDuration(imageanima.Duration + 1)
    elseif key == 'down' then
        imageanima:SetDuration(imageanima.Duration - 1)
        imageanima1:SetDuration(imageanima.Duration - 1)
    end
end)