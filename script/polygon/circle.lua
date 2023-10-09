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
    local xx = p.x - self.x
    local yy = p.y - self.y

    return xx * xx + yy * yy < self.r * self.r
end



function Circle:draw()
    local r, g, b, a = love.graphics.getColor( );
    love.graphics.setColor(self.color.r, self.color.g, self.color.b, self.color.a );
    Render.RenderObject(self);
    love.graphics.setColor(r, g, b, a );

    if self.box2d then
        self.box2d:draw()
    end
end