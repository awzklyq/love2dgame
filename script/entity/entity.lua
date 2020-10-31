_G.Entity = {}
dofile('script/entity/body.lua')
dofile('script/entity/me.lua')

function Entity.new()
    local entity = setmetatable({}, {__index = Entity});

    return entity;
end

function Entity:setBody(body)
    self.body = body;
    self.body.entity = self;
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

function Entity:update(e)
    if self.body then
        self.body:update();
    end
end

function Entity:findBodyByName(name)
    if self.body then
        return self.body:findBodyByName(name);
    end
    return nil;
end

--TODO..
function Entity:setBodyParent()
    if self.body then
        return self.body:setBodyParent();
    end
end

function Entity:draw()
    if self.body then
        self.body:draw();
    end
end