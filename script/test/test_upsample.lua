FileManager.addAllPath("assert")
math.randomseed(os.time()%10000)


local GetLuminance = function(r, g, b)
    return 0.2125 * r + 0.7154 * g + 0.0721 * b
end

local OriImg = ImageEx.new("QQUpSample.png") -- QQTTest.png
log(OriImg.w, OriImg.h)

local w = OriImg.w * 2
local h = OriImg.h * 2
local OriImageData = ImageEx.NewImageData("QQUpSample.png")

local ImageData1 = ImageEx.NewImageData(w, h)
local ImageData2 = ImageEx.NewImageData(w, h)

local Img1
local Img2

local Offset = 4
local TestFunc = function()
        ---------------
    for i = 0, w - 1 do
        for j = 0, h - 1 do
            local r, g, b, a = OriImageData:getPixel(i * 0.5, j * 0.5)
            ImageData1:setPixel(i, j, r, g, b, a)
            ImageData2:setPixel(i, j, r, g, b, a)
        end
    end

    ---------------------------------
    for i = 0, w - 1 do
        for j = 0, h - 1 do
            
            if i % 2 ~= 0 or j % 2 ~= 0 then
                if i - Offset >= 0 and j - Offset >= 0 and i + Offset <= w - 1 and j + Offset <=  h - 1 then
                    local r1, g1, b1, a1 = ImageData2:getPixel(i - Offset, j)
                    local l1 = GetLuminance(r1, g1, b1)
                    local r2, g2, b2, a2 = ImageData2:getPixel(i + Offset, j)
                    local l2 = GetLuminance(r2, g2, b2)

                    local r3, g3, b3, a3 = ImageData2:getPixel(i, j - Offset)
                    local l3 = GetLuminance(r3, g3, b3)
                    local r4, g4, b4, a4 = ImageData2:getPixel(i, j + Offset)
                    local l4 = GetLuminance(r4, g4, b4)

                    if math.abs(l1 - l2) < math.abs(l3 - l4) then
                        ImageData2:setPixel(i, j, (r1 + r2) * 0.5, (g1 + g2) * 0.5, (b1 + b2) * 0.5)
                    
                    else
                        ImageData2:setPixel(i, j, (r3 + r4) * 0.5, (g3 + g4) * 0.5, (b3 + b4) * 0.5)
                    end

                end
            end
            
        end
    end

    Img1 = ImageEx.new(ImageData1)
    Img2 = ImageEx.new(ImageData2)
end

TestFunc()

local rendertype = 1
app.render(function(dt)
    if rendertype == 1 then
        OriImg:draw()
    elseif rendertype == 2 then
        Img1:draw()
    else
        Img2:draw()
    end

    love.graphics.print( "test " .. tostring(rendertype) .. "  Offset ".. tostring(Offset), 10, 10)
end)

app.keypressed(function(key, scancode, isrepeat)
    if key == 'space' then
        rendertype = rendertype + 1
        if rendertype == 4 then
            rendertype = 1
        end
    elseif key == 'q' then
        Offset = Offset + 1
        TestFunc()
    elseif key == 'a' then
        Offset = Offset - 1
        if Offset == 0 then
            Offset = 1
        end
        TestFunc()
    end

end)
