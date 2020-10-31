_G.Body = {}
function Body.new(name, order)
    local body = setmetatable({}, {__index = Body});
    body.transform =  Matrix.new();
    body.pos = Vector.new();
    body.children = {};
    body.polygons = {};
    body.name = name or "";
    body.order = order or 0;
    
    body.x1 = 0
    body.y1 = 0;

    body.x2 = 0;
    body.y2 = 0;

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
    body.entity = self.entity;
end

function Body:addPolygon(polygon)
    polygon.body = self;

    self.x1 = polygon.vertices[1];
    self.y1 = polygon.vertices[2];

    self.x2 = self.x1;
    self.y2 = self.y1;
    for i =1,#polygon.vertices ,2 do 
        self.x1 = math.min(polygon.vertices[i], self.x1);
        self.y1 = math.min(polygon.vertices[i + 1], self.y1);
        
        self.x2 = math.max(polygon.vertices[i], self.x2);
        self.y2 = math.max(polygon.vertices[i + 1], self.y2);
    end

    local cx = (self.x1 + self.x2) * 0.5
    local cy = (self.y1 + self.y2) * 0.5

    -- local w = self.x2 - self.x1
    -- local h = self.y2 - self.y1
    local vertices = {}
    for i =1,#polygon.vertices ,2 do 
        table.insert(vertices, polygon.vertices[i] - cx );
        table.insert(vertices, polygon.vertices[i + 1] - cy);
    end

    local cx = (self.x1 + self.x2) * 0.5
    local cy = (self.y1 + self.y2) * 0.5

    polygon.vertices = vertices;
    polygon.x1 = self.x1;
    polygon.y1 = self.y1;

    polygon.x2 = self.x2;
    polygon.y2 = self.y2;

    polygon.cx = cx;
    polygon.cy = cy;

    polygon:moveTo(cx, cy);

    polygon.crossline = CrossLine.new(0, 0, 20, 20, 5);
    polygon.crossline.transform = polygon.transform;
    table.insert(self.polygons, polygon);
end

function Body:findBodyByName(name)
    if self.name == name then 
        return self;
    end

    for i, v in pairs(self.children) do
        local body =  v:findBodyByName(name);
        if body then
            return body;
        end
    end

    return nil;
end 

function Body:setBodyParent()
    if self.parentname and not self.parent then 
        local parent = self.entity:findBodyByName(self.parentname);
        if parent then
            self.parent = parent;
        end
    end

    for i, v in pairs(self.children) do
        v:setBodyParent();        
    end

    return nil;
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
    local r, g, b, a = love.graphics.getColor( );
    Render.RenderObject(self);
    love.graphics.setColor(r, g, b, a );
end

function Body.createBodyFromSVG(svgdata)
end