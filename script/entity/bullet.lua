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
    bullet.tick = 0;

    bullet.life = life or 5;
    bullet.isalive = true;
    bullet.speed = speed or 1;

    bullet.direction = Vector.new();
    bullet.position = Vector.new(x, y);
    bullet.target = Vector.new(x, y);
    bullet.ismove = false;

    BulletManager.add(bullet);

    return bullet;
end

function Bullet:reset()
    self.tick = 0
end

function Bullet:setDirection(x, y)
    self.direction.x = x;
    self.direction.y = y;

    self.direction:normalize();
    self.ismove = true;


    self.target.x = self.position.x + self.direction.x * self.speed * self.life;
    self.target.y = self.position.y + self.direction.y * self.speed * self.life;;
end

function Bullet:setTarget(x, y)
    self.target.x = x;
    self.target.y = y;

    self.direction.x = x - self.position.x;
    self.direction.y = y - self.position.y;

    self.direction:normalize();
    self.ismove = true;
end

function Bullet:setDirectionTo(x, y)
    self:setDirection(x - self.position.x, y - self.position.y)
end

function Bullet:moveTo(x, y)
    self.position.x = x;
    self.position.y = y;
end

function Bullet:move(x, y)
    self.position.x = self.position.x + x;
    self.position.y = self.position.y + y;
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
    if self.RenderObj then
        self.RenderObj:draw(e);
    end
end

