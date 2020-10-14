_G.Battery = {}

function Battery.new()
    local battery = setmetatable({}, {__index = Battery});
    battery.circle =  Circle.new(20, 0, 0, 100);
    battery.rect = Rect.new(20, 0, 15, 5);
    battery.pos = Vector.new();
    battery.transform =  Matrix.new();

    return battery;
end

function Battery:moveTo(x, y)
    self.pos.x = x;
    self.pos.y = y;
    self.transform:translate(x, y);
end

function Battery:scale(x, y)
    self.transform:scale( x, y);
end

function Battery:faceTo(x, y)
    self.transform:setXDirection( x - self.pos.x, y - self.pos.y);
end

function Battery:update(e)
    self.tick = self.tick + e;
    self.circle.x = math.lerp(self.circle.x, self.x1, self.tick / self.time);
    self.circle.y = math.lerp(self.circle.y, self.y1, self.tick / self.time);
end

function Battery:draw(e)
    self.transform:use();
    self.circle:draw(e)
    self.rect:draw(e)
    Matrix.reset()
end