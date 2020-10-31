_G.Line = {}

function Line.new(x1, y1, x2, y2, lw)-- lw :line width
    local line = setmetatable({}, {__index = Line});
    line.x1 = x1 or 0;
    line.y1 = y1 or 0;
    line.x2 = x2 or 1;
    line.y2 = y2 or 1;

    line.lw = lw or 2;

    line.color = LColor.new(255,255,255,255)

    line.renderid = Render.LineId ;
    return line;
end

function Line:setColor(r, g, b, a)
    self.color.r = r;
    self.color.g = g;
    self.color.b = b;
    self.color.a = a;
end

function Line:draw()
    -- local r, g, b, a = love.graphics.getColor( );
    Render.RenderObject(self);
    -- love.graphics.setColor(r, g, b, a );
end

-- function Rect:update(e)
    
--  end

_G.CrossLine = {}
function CrossLine.new(x, y, w, h, lw)-- lw :line width
    local line = setmetatable({}, {__index = CrossLine});
    line.x = x or 0;
    line.y = y or 0;
    line.w = w or 1;
    line.h = h or 1;

    line.lw = lw or 2;

    line.color = LColor.new(200,0,0, 255)

    line.renderid = Render.CrossLineId ;
    return line;
end

function CrossLine:setColor(r, g, b, a)
    self.color.r = r;
    self.color.g = g;
    self.color.b = b;
    self.color.a = a;
end

function CrossLine:draw()
    Render.RenderObject(self);
end
