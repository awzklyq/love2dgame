
_G.ImageEx = {}

function ImageEx.new(name, ...)
    local image = setmetatable({}, ImageEx);

    if type(name) == 'string' then
        image.obj = love.graphics.newImage(_G.FileManager.findFile(name), ...)
    else
        image.obj = love.graphics.newImage(name, ...)
        image.ImageData = name
    end

    image.filename = name

    image.w = image:getWidth()
    image.h = image:getHeight()

    image:InitData()
    return image;
end

function ImageEx.CreateFromImage(obj, x, y, w, h, ...)
    local image = setmetatable({}, ImageEx);

    if type(obj) == 'table' and obj.renderid == Render.ImageId then
        image.obj = obj.obj
        image.ImageData = obj.ImageData
    else
        image.obj = love.graphics.newImage(obj, ...)
    end

    image.filename = name

    image.w = w or 0
    image.h = h or 0

    image.Quad = love.graphics.newQuad( x or 0, y or 0, w or 0, h or 0, image.obj);

    image:InitData()
    return image;
end

function ImageEx.CreateFromPixels(InW, InH, InPixels)
    local TestImageData = ImageDataEx.new(InW, InH, 'rgba8')
    TestImageData:SetPixels(InPixels)
    return TestImageData:GetImage()
end

function ImageEx:InitData()
    self.transform = Matrix.new()

    self.renderid = Render.ImageId;

    self.x = 0
    self.y = 0

    self.alpha = 1
end

ImageEx.__index = function(tab, key, ...)
    local value = rawget(tab, key);
    if value then
        return value;
    end

    if key == 'renderWidth' then
        return rawget(tab, 'w');
    end

    if key == 'renderHeight' then
        return rawget(tab, 'h');
    end

    if ImageEx[key] then
        return ImageEx[key];
    end
    
    if tab["obj"] and tab["obj"][key] then
        if type(tab["obj"][key]) == "function" then
            tab[key] = function(tab, ...)
                return tab["obj"][key](tab["obj"], ...);--todo..
            end
            return  tab[key]
        end
        return tab["obj"][key];
    end

    return nil;
end

ImageEx.__newindex = function(tab, key, value)
    if key == 'renderWidth' then
        rawset(tab, 'w', value);
    elseif key == 'renderHeight' then
        rawset(tab, 'h', value);
    else
        rawset(tab, key, value);
    end
end

function ImageEx:GetImageData()
    if not self.ImageData then
        self.ImageData = love.image.newImageData( _G.FileManager.findFile(self.filename) )
    end

    return self.ImageData
end

function ImageEx:GetPixel(x, y)
    local imgd = self:GetImageData()
    local r, g, b, a = imgd:getPixel(x, y)
    return LColor.new(r * 255, g * 255, b * 255, a * 255)
end

function ImageEx:GetPixels()
    local imgd = self:GetImageData()
    local index = 0
    local ImageColors = {}
    for i = 0, self.w - 1 do
        ImageColors[#ImageColors + 1] = {}
        for j = 0, self.h - 1 do
            local r, g, b, a = imgd:getPixel(i, j)
            ImageColors[#ImageColors][j + 1] = LColor.new(r * 255, g * 255, b * 255, a * 255)
        end
    end
    return ImageColors
end

function ImageEx:GetPixelsAsVector()
    local imgd = self:GetImageData()
    local index = 0
    local ImageColorsVector = {}
    for i = 0, self.w - 1 do
        ImageColorsVector[#ImageColorsVector + 1] = {}
        for j = 0, self.h - 1 do
            local r, g, b, a = imgd:getPixel(i, j)
            ImageColorsVector[#ImageColorsVector][j + 1] = LColor.new(r * 255, g * 255, b * 255, a * 255):AsVector()
        end
    end
    return ImageColorsVector
end

function ImageEx:Histogram()
    local ImageColors = self:GetPixels()
    local Num = 255

    local Result = {}
    for i = 1, Num do
        Result[i] = {}
    end

    --Floor
    for i = 1, #ImageColors do
        for j = 1, #ImageColors[i] do
            local L = ImageColors[i][j]:GetLuminance()
            local Index = math.floor(L * Num) + 1
            local CurrentH = Result[Index]
            CurrentH[#CurrentH + 1] = {x = i, y = j, L = L}
        end
    end 
    return Result
end

function ImageEx:SetPixel(x, y, r, g, b, a)
    local imgd = self:GetImageData()
    if not g then
        imgd:setPixel(x, y, r._r, r._g, r._b, r._a)
    else
        imgd:setPixel(x, y, r, g, b, a)
    end
    return imgd
end

function ImageEx:ErasurePixel(c)
    local w = self:getWidth()
    local h = self:getHeight()

    local index = 0
    for i = 0, w - 1 do
        for j = 0, h - 1 do
            local pc = self:GetPixel(i, j)
            if math.abs(c:GetLuminance() - pc:GetLuminance()) < 0.2 then
                self:SetPixel(i,j,pc._r,pc._g,pc._b,pc:GetLuminance() * 0.1)
            end
        end
    end

    return ImageEx.new(self:GetImageData())
end

function ImageEx:CacleCDF(InHistogramData)
    local NumHistogram = #InHistogramData
    local NumberData = 0
    for i = 1, NumHistogram do
        NumberData = NumberData + #InHistogramData[i]
    end

    local cdf_normalized = {}
    local CurrentNumberData = 0
    local cdf_min = 0
    for i = 1, NumHistogram do
        CurrentNumberData = CurrentNumberData + #InHistogramData[i]
        cdf_normalized[i] = CurrentNumberData / NumberData
        if cdf_normalized[i] > 0 and cdf_min == 0 then
            cdf_min = cdf_normalized[i]
        end
    end

    local NewColorDatas = {}
    for i = 1, NumHistogram do
        NewColorDatas[i] = {}
        local NewL = ((cdf_normalized[i] - cdf_min) / (1 - cdf_min)) --* 255
        -- NewL = math.round(NewL)
        
        for j = 1, #InHistogramData[i] do
            local HD = InHistogramData[i][j]
            local c = LColor.new()
            c:Set(HD.C)
            c:AdjustGray(NewL)

            -- c.r = 255
            -- c.g = 0
            -- c.b = 0
            -- c.a = 255 
            NewColorDatas[i][j] = {x = HD.x, y = HD.y, C = c}
        end
    end

    return NewColorDatas
end

function ImageEx:HistogramEqualization()
    local ImageColors = self:GetPixels()
    local Num = 255

    local Result = {}
    for i = 1, Num do
        Result[i] = {}
    end

    --Floor
    for i = 1, #ImageColors do
        for j = 1, #ImageColors[i] do
            local L = ImageColors[i][j]:GetLuminance()
            local Index = math.floor(L * Num) + 1
            local CurrentH = Result[Index]
            CurrentH[#CurrentH + 1] = {x = i, y = j, L = L, C = ImageColors[i][j]}
        end
    end 

    local NewColorDatas = self:CacleCDF(Result)
    return NewColorDatas
end

function ImageEx:draw()
    Render.RenderObject(self)
end

function ImageEx:Release()
    self.ImageData = nil
end

-----------------------------------------------

_G.ImageDataEx = {}

function ImageDataEx.new(w, h, format, rawdata)
    local imageData = setmetatable({}, {__index = ImageDataEx});
    imageData.obj = love.image.newImageData( w, h, format, rawdata )

    imageData.renderid = Render.ImageDataId;

    imageData._w = w
    imageData._h = h

    return imageData
end

function ImageDataEx.CreateFromFile(InFile)
    local imageData = setmetatable({}, {__index = ImageDataEx});
    imageData.filename = InFile;
    imageData.obj = love.image.newImageData( _G.FileManager.findFile(InFile) )

    imageData.renderid = Render.ImageDataId;

    imageData._w = imageData.obj:getWidth()
    imageData._h = imageData.obj:getHeight()

    return imageData
end

function ImageDataEx:GetDataAsString()
    return self.obj:getString( 0, self.obj:getSize())
end

function ImageDataEx:GetPixel(x, y)
    local r, g, b, a = self.obj:getPixel(x, y)
    return LColor.new(r * 255, g * 255, b * 255, a * 255)
end

function ImageDataEx:SetPixel(x, y, r, g, b, a)
    if not g then
        self.obj:setPixel(x, y, r._r, r._g, r._b, r._a)
    else
        self.obj:setPixel(x, y, r, g, b, a)
    end
    return self.obj
end

--InDatas:x, y, C
function ImageDataEx:SetPixelsFromDatas(InDatas)
    for i = 1, #InDatas do
        for j = 1, #InDatas[i] do
            local d = InDatas[i][j]
            self:SetPixel(d.x - 1, d.y - 1, d.C)
        end
    end
end

function ImageDataEx:SetPixels(InPixels)
    for i = 1, #InPixels do
        for j = 1, #InPixels[i] do
            local C = InPixels[i][j]
            self:SetPixel(i - 1, j - 1, C)
        end
    end
end

function ImageDataEx:GetImage()
    return ImageEx.new(self.obj)
end
