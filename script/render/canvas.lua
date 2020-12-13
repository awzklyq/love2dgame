_G.Canvas = {}

function Canvas.new(...)
    local canvas = setmetatable({}, Canvas);

    canvas.obj = love.graphics.newCanvas(...)

    canvas.transform = Matrix.new()

    canvas.bgColor = LColor.new(0, 0, 0)
    canvas.renderid = Render.CanvasId;
    return canvas;
end

Canvas.__index = function(tab, key, ...)
    local value = rawget(tab, key);
    if value then
        return value;
    end

    if Canvas[key] then
        return Canvas[key];
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

Canvas.__newindex = function(tab, key, value)
    rawset(tab, key, value);
end

function Canvas:draw()
    Render.RenderObject(self)
end

_G.pushCanvas = function(canvas)
    if canvas.renderid == Render.CanvasId then
        love.graphics.setCanvas(canvas.obj)
    else
        love.graphics.setCanvas(canvas)
    end

    if canvas.bgColor then
        love.graphics.clear(canvas.bgColor._r, canvas.bgColor._g, canvas.bgColor._b, canvas.bgColor._a)
    end
end

_G.popCanvas = function(canvas)
    love.graphics.setCanvas()
end