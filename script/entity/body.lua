_G.Body = {}
function Body.new(name, order)
    local body = setmetatable({}, Body);
    body.pos = Vector.new();
    body.children = {};
    body.polygon = nil;--TODO
    body.name = name or "";
    body.order = order or 0;
    
    body.x1 = 0
    body.y1 = 0;

    body.x2 = 0;
    body.y2 = 0;

    body.renderid = Render.EntityBodyId;
    return body;
end

Body.__index = function(tab, key)
    local polygon = rawget(tab, "polygon");
    if polygon then
        if key == 'transform' then
            return  polygon["transform"];
        elseif key == "box2d" then
            return polygon["box2d"]
        end
    end

    if Body[key] then
        return Body[key];
    end

    return rawget(tab, key);
end

Body.__newindex = function(tab, key, value)
    if key == 'transform' and tab["polygon"] then
        tab["polygon"]["transform"] = value;
    end
    rawset(tab, key, value);
end

function Body:moveTo(x, y)
   
end

function Body:move(x, y)
    
end

function Body:scale(x, y)
   
end

function Body:faceTo(x, y)
    
end

function Body:addBody(body)
    table.insert(self.children, body);
    body.parent = self;
    body.entity = self.entity;
end

function Body:setPolygon(polygon)
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

    self.w = self.x2 - self.x1
    self.h = self.y2 - self.y1

    local vertices = {}
    for i =1,#polygon.vertices ,2 do 
        table.insert(vertices, polygon.vertices[i] - cx );
        table.insert(vertices, polygon.vertices[i + 1] - cy);
    end

    local cx = (self.x1 + self.x2) * 0.5
    local cy = (self.y1 + self.y2) * 0.5

    polygon.vertices = vertices;
    polygon.x1 = self.x1;

    polygon.x2 = self.x2;

    polygon.cx = cx;
    polygon.cy = cy;

    polygon.transform:moveTo(cx, cy);

    polygon.crossline = CrossLine.new(0, 0, 20, 20, 5);
    polygon.crossline.transform = polygon.transform;
    self.polygon = polygon;
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
    if self.polygon then
        self.polygon:update(e)
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