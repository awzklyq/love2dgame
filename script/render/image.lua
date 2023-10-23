
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

    image.transform = Matrix.new()

    image.renderid = Render.ImageId;

    image.w = image:getWidth()
    image.h = image:getHeight()

    image.x = 0
    image.y = 0

    image.alpha = 1
    return image;
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
    local IsColor = not not g
    if IsColor then
        imgd:setPixel(x, y, r._r, r._g, r._b, r._a)
    else
        imgd:setPixel(x, y, r, g, b, a)
    end
    
end


function ImageEx:draw()
    Render.RenderObject(self)
end

function ImageEx:Release()
    self.ImageData = nil
end