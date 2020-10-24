_G.Body = {}
function Body.new(name, order)
    local body = setmetatable({}, {__index = Body});
    body.transform =  Matrix.new();
    body.pos = Vector.new();
    body.children = {};
    body.polygons = {};
    body.name = name or "";
    body.order = order or 0;
    body.renderid = Render.EntityBodyId;
    return body;
end

function Body:moveTo(x, y)
    self.pos.x = x;
    self.pos.y = y;
    self.transform:translate(x, y);
end

function Body:move(x, y)
    self.pos.x = self.pos.x + x;
    self.pos.y = self.pos.y + y;
    self.transform:translate(x, y);
end

function Body:scale(x, y)
    self.transform:scale( x, y);
end

function Body:faceTo(x, y)
    self.transform:setXDirection( x - self.pos.x, y - self.pos.y);
end

function Body:addBody(body)
    table.insert(self.children, body);
    body.parent = self;
end

function Body:update(e)
    for i, v in pairs(self.polygons) do
        v:update(e)
    end

    for i, v in pairs(self.children) do
        v:update(e)
    end
end

function Body:draw()
    love.graphics.push();
    local r, g, b, a = love.graphics.getColor( );
    Render.RenderObject(self);
    love.graphics.setColor(r, g, b, a );

    love.graphics.pop();
end

function Body.createBodyFromSVG(svgdata)
end