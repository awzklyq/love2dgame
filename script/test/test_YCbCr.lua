local OriRects = {}
local DesRects = {}

local Colors = {}

local Number = 16
local offsetx = 50
local offsety = 50
function RGBToYCbCr(rgb)

    local ycbcr = Vector3.new()
    ycbcr.x  = 0.299 * rgb.r + 0.587 * rgb.g + 0.114 * rgb.b;
    ycbcr.y = -0.169 * rgb.r - 0.331 * rgb.g + 0.500 * rgb.b + 128;
    ycbcr.z = 0.500 * rgb.r - 0.419 * rgb.g - 0.081 * rgb.b + 128;
    return ycbcr;
end

function YCbCrToRGB(ycbcr)
    local rgb = LColor.new(0, 0, 0, 255)
    rgb.r = ycbcr.x + 1.402 * (ycbcr.z - 128);
    rgb.g = ycbcr.x - 0.344136 * (ycbcr.y - 128) - 0.714136 * (ycbcr.z - 128);
    rgb.b = ycbcr.x + 1.772 * (ycbcr.y - 128);
    return rgb;
end

function CompressYCbCr(color) --YCbCr
    local compressed = Vector.new();
    compressed.x = color.x; 
    compressed.y = math.floor( color.y ) + color.z / 256.0;

    -- if compressed.x > 255 or compressed.y > 255 then
    --     log('aaaaaaaaaaaaaaaaaa')
    -- end
    
    compressed.x = compressed.x / 255;
    compressed.y = compressed.y / 255;
    return compressed;
end

function DecompressYCbCr(compressed)

    compressed.x = compressed.x * 255
    compressed.y = compressed.y * 255

    local color = Vector3.new(); -- YCbCr
    color.x = compressed.x;
    color.y =  math.floor( compressed.y);
    color.z = (compressed.y - color.y) * 256.0;
    return color;
end

local GenerateColors = function()
    Colors = {}
    for i = 1, Number * Number do
        local c = LColor.new(math.random(0 , 1) * 255, math.random(0 , 1) * 255, math.random(0 , 1) * 255, 255)
        Colors[#Colors + 1] = c
    end
end

GenerateColors()

local GenerateRects = function()
    OriRects ={}
    DesRects = {}

    local screenwidth = RenderSet.screenwidth
    local screenheight = RenderSet.screenheight

    local rw = (screenwidth - offsetx * 2) / Number
    local rh = (screenheight - offsety * 2) / Number

    for i = 1, Number do
        for j = 1, Number do
            local rect = Rect.new((i - 1) * rw + offsetx, (j - 1) * rh + offsety, rw, rh)
            local ci = #OriRects + 1
            rect:SetColor(Colors[ci].r, Colors[ci].b, Colors[ci].g, 255)
            OriRects[ci] = rect 
        end
    end

    for i = 1, Number do
        for j = 1, Number do
            local rect = Rect.new((i - 1) * rw + offsetx, (j - 1) * rh + offsety, rw, rh)
            local ci = #DesRects + 1
            local c = Colors[ci]
            local YCbCr = RGBToYCbCr(c)

            local compressed = CompressYCbCr(YCbCr)
            local Decomress = DecompressYCbCr(compressed)
            local newc = YCbCrToRGB(Decomress)

            rect:SetColor(newc.r, newc.b, newc.g, 255)
            DesRects[ci] = rect 
        end
    end
end

GenerateRects()

local IsDrawOri = true
app.render(function(dt)
    if IsDrawOri then
        for i = 1, #OriRects do
            OriRects[i]:draw()
        end
    else
        for i = 1, #DesRects do
            DesRects[i]:draw()
        end
    end
end)

app.resizeWindow(function(w, h)
    GenerateRects()
end)

local checkb = UI.CheckBox.new( 10, 10, 20, 20, "Draw Ori" )
checkb.IsSelect = IsDrawOri
checkb.ChangeEvent = function(Enable)
    IsDrawOri = Enable
end