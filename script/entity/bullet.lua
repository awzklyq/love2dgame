local BulletManager = {};
local bullets = {};
local deathbullet  = {}
BulletManager.add = function(bullet)
    bullets[bullet] = bullet;
end

BulletManager.del = function(bullet)
    bullets[bullet] = nil;
end

BulletManager.update = function(dt)
    for i, v in pairs(bullets) do--TODO..
        v:update(dt);
    end

    --处理死亡
    if #deathbullet > 0 then
        for i= 1, #deathbullet do
            BulletManager.del(deathbullet[i]);
        end
    end
end

BulletManager.render = function(e)
    for i, v in pairs(bullets) do--TODO..
        v:draw(e);
    end
end

_G.app.update(function(dt)
    BulletManager.update(dt);
end)

_G.app.render(function(e)
    BulletManager.render(e);
end)

_G.Bullet = {}

function Bullet.new(x, y, speed, life)
    local bullet = setmetatable({}, {__index = Bullet});
    bullet.polygon = Polygon.new(x, y)
    bullet.tick = 0;

    bullet.life = life or 5;
    bullet.isalive = true;
    bullet.speed = speed or 1;

    bullet.direction = Vector.new();

    bullet:moveTo(x, y);
    bullet.ismove = false;

    BulletManager.add(bullet);

    return bullet;
end

function Bullet:setDirection(x, y)
    self.direction.x = x;
    self.direction.y = y;

    self.direction:normalize();
    self.ismove = true;
end

function Bullet:setDirectionTo(x, y)
    self.direction.x = x - self.pos.x;
    self.direction.y = y - self.pos.y;

    self.direction:normalize();

    self.ismove = true;
end

function Bullet:moveTo(x, y)
    self.polygon:moveTo(x, y);
end

function Bullet:move(x, y)
    self.polygon:move(x, y);
end

function Bullet:scale(x, y)
    self.polygon:scale( x, y);
end

function Bullet:faceTo(x, y)
    self.polygon:setXDirection( x - self.pos.x, y - self.pos.y);
end

function Bullet:update(dt)
    if not self.isalive then return end

    self.tick = self.tick + dt;
    self.isalive = self.tick <= self.life;

    if not self.isalive then
        table.insert(deathbullet, self);
    elseif self.ismove then
        local dis = dt * self.speed;
        self:move(self.direction.x * dis, self.direction.y * dis);
    end

end

function Bullet:draw(e)
    self.polygon:draw(e);
end

