_G.Circle = {}

function Circle.new(r, x ,y, segments)
    local circle = setmetatable({}, {__index = Circle});
    circle.r = r;
    circle.x = x;
    circle.y = y;

    circle.seg = segments or 100;

    circle.color = LColor.new(255,255,255,255)

    circle.mode = 'line';

    circle.renderid = Render.CircleId;
    return circle;
end

function Circle:setColor(r, g, b, a)
    self.color.r = r;
    self.color.g = g;
    self.color.b = b;
    self.color.a = a;
end

function Circle:SetColor(r, g, b, a)
    self.color.r = r;
    self.color.g = g;
    self.color.b = b;
    self.color.a = a;
end

function Circle:CheckPointIn(p)
    return self:CheckPointInXY(p.x, p.y)
end

function Circle:CheckPointInXY(x, y)
    local xx = x - self.x
    local yy = y - self.y

    return xx * xx + yy * yy < self.r * self.r
end

function Circle:SetMouseEventEable(enable)
    AddEventToPolygonevent(self, enable)
end



function Circle:draw()
    Render.RenderObject(self);

    if self.box2d then
        self.box2d:draw()
    end
end