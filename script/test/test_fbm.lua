
local SampleSize = Vector.new(512, 512)
local scale = 5
local ImageData =love.image.newImageData(SampleSize.x, SampleSize.y)
for i = 1, SampleSize.x - 1 do
    for j = 1, SampleSize.y - 1 do
       -- local v = math.abs(PerLinNoise1.Process(i / SampleSize.x + i)) % 1
       local v = FBM.Process(j / 100  , i / 100, 0)
    --    log(v)

        local color = Vector3.new(v, v, v)
        ImageData:setPixel(i, j, color.x, color.y, color.z, 1)
    end
end

local image = ImageEx.new(ImageData)
app.render(function(dt)
    image:draw()
end)