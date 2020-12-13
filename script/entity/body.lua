_G.Body = {}
function Body.new(name, order)
    local body = setmetatable({}, Body);
    body.pos = Vector.new();
    body.children = {};
    body.polygon = nil;--TODO
    body.name = name or "";
    body.order = order or 0;

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
        elseif key == "box" then
            return polygon["box"]
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

    local box = Box.new()
    box.x1 = polygon.vertices[1];
    box.y1 = polygon.vertices[2];

    box.x2 = box.x1;
    box.y2 = box.y1;
    for i =1,#polygon.vertices ,2 do 
        box.x1 = math.min(polygon.vertices[i], box.x1);
        box.y1 = math.min(polygon.vertices[i + 1], box.y1);
        
        box.x2 = math.max(polygon.vertices[i], box.x2);
        box.y2 = math.max(polygon.vertices[i + 1], box.y2);
    end

    local cx = (box.x1 + box.x2) * 0.5
    local cy = (box.y1 + box.y2) * 0.5

    local vertices = {}
    for i =1,#polygon.vertices ,2 do 
        table.insert(vertices, polygon.vertices[i] - cx );
        table.insert(vertices, polygon.vertices[i + 1] - cy);
    end

    if polygon.isConvex == false then
        local tcx, tcy =0, 0
        for i = 1, #polygon.triangles[1], 2 do
            tcx = tcx + polygon.triangles[1][i]
            tcy = tcy + polygon.triangles[1][i + 1]
        end

        tcx = tcx / 3
        tcy = tcy / 3

        -- polygon.revisexy.x = tcx - cx
        -- polygon.revisexy.y = tcy - cy

        for i = 1,#polygon.triangles do
            local triangle = polygon.triangles[i]
            for j = 1, #triangle, 2 do
                triangle[j] = triangle[j] - tcx
                triangle[j+ 1] = triangle[j+ 1] - tcy
            end
        end
    end

    box.x1 = box.x1 - cx;
    box.y1 = box.y1 - cy;
    box.x2 = box.x2 - cx;
    box.y2 = box.y2 - cy;

    polygon.box = box;
    box.obj = polygon;
    polygon.vertices = vertices;

    polygon.transform:moveTo(cx, cy);
    polygon.crossline = CrossLine.new(0, 0, 20, 20, 5);
    polygon.crossline.transform = polygon.transform;
    self.polygon = polygon;
    local currentgroup = _G.GroupManager.currentgroup
    
    if currentgroup and currentgroup.grid then      
        currentgroup.grid:addOrChange(self.polygon)
    end

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