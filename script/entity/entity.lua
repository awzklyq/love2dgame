

dofile('script/entity/body.lua')
_G.Entity = {}

function Entity.new()
    local entity = setmetatable({}, {__index = Entity});

    return entity;
end


function Entity:moveTo(x, y)
    if self.body then
        self.body:moveTo(x, y);
    end
end

function Entity:move(x, y)
    if self.body then
        self.body:move(x, y);
    end
end

function Entity:scale(x, y)
    if self.body then
        self.body:scale( x, y);
    end
end

function Entity:faceTo(x, y)
    if self.body then
        self.body:setXDirection( x - self.pos.x, y - self.pos.y);
    end
end

function Entity:draw()
    if self.body then
        self.body:draw();
    end
end