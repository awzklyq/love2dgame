
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


function ImageEx:draw()
    Render.RenderObject(self)
end

function ImageEx:Release()
    self.ImageData = nil
end

_G.ImageDataEx = {}

function ImageDataEx.new(w, h, format, rawdata)
local imageData = setmetatable({}, {__index = ImageDataEx});
    imageData.obj = love.image.newImageData( w, h, format, rawdata )

    imageData.renderid = Render.ImageDataId;

    return imageData
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

function ImageDataEx:GetImage()
    return ImageEx.new(self.obj)
end
