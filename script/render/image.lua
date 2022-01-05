
_G.ImageEx = {}

function ImageEx.new(name, ...)
    local image = setmetatable({}, ImageEx);

    if type(name) == 'string' then
        image.obj = love.graphics.newImage(_G.FileManager.findFile(name), ...)
    else
        image.obj = love.graphics.newImage(name, ...)
    end

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
    rawset(tab, key, value);
end

function ImageEx:draw()
    Render.RenderObject(self)
end

