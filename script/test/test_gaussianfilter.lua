FileManager.addAllPath("assert")
math.randomseed(os.time()%10000)

local img = ImageEx.new("qq1.png")
img.w  = love.graphics.getPixelWidth()
img.h = love.graphics.getPixelHeight()

img.renderWidth = img.w
img.renderHeight = img.h
local IsGaussianFilter = true
app.render(function(dt)
    if IsGaussianFilter then
        local canvas = GaussianFilterNode.Execute(img)
        canvas:draw()
    else
        img:draw()
    end

    love.graphics.print( "GaussianFilterNode.Sigma: "..tostring(GaussianFilterNode.Sigma) .. " IsGaussianFilter: " .. tostring(IsGaussianFilter), 10, 10)
end)

app.keypressed(function(key, scancode, isrepeat)
    if key == "up" then
        GaussianFilterNode.Sigma = math.clamp(GaussianFilterNode.Sigma + 0.1, 0, 1)
    elseif key == 'down' then
        GaussianFilterNode.Sigma = math.clamp(GaussianFilterNode.Sigma - 0.1, 0, 1)
    elseif key == 'space' then
        IsGaussianFilter = not IsGaussianFilter
    end

end)
