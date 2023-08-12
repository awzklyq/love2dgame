FileManager.addAllPath("assert")

local tgaf = ImageEx.new("test_normal.tga")

local tgaf_imagedata = love.image.newImageData(_G.FileManager.findFile("test_normal.tga"))
local tw = tgaf_imagedata:getWidth()
local th = tgaf_imagedata:getHeight()

local imgData = love.image.newImageData(tw, th)
local SphericalImgData = love.image.newImageData(tw, th)
local OctImgData = love.image.newImageData(tw, th)
local SEImage-- return love.graphics.newImage(imgNormalData)
local OctImage
local EcodeC1 = {}
for i = 0, tw -1 do
    for j = 0, th -1 do
        local r, g, b, a = tgaf_imagedata:getPixel(i, j)
        local v3 = Vector3.new(r, g, b)

        v3 = v3 * 2.0 - 1.0

        local SE = math.SphericalEncode(v3)
        local SD = math.SphericalDecode(SE) 
        SD = SD * 0.5 + 0.5

        SphericalImgData:setPixel(i, j, SD.x, SD.y, SD.z)
       
        local OE = math.OctEncode(v3)
        local OD = math.OctDecode(OE) 
        OD = OD * 0.5 + 0.5
        OctImgData:setPixel(i, j, OD.x, OD.y, OD.z)
    end
end

local RenderType = 1

SEImage = ImageEx.new(SphericalImgData)
OctImgData = ImageEx.new(OctImgData)

app.render(function(dt)
    if RenderType == 1 then
         tgaf:draw()
    elseif RenderType == 2 then
        SEImage:draw()
    elseif RenderType == 3 then
        OctImgData:draw()
    end

    love.graphics.print( "Press Key Space.  RenderType: "..tostring(RenderType), 10, 10)
end)

app.keypressed(function(key, scancode)
    if key == "w" then

    elseif key == "space" then
        RenderType = RenderType + 1
        
        if RenderType == 4 then
            RenderType = 1
        end
    end
end)