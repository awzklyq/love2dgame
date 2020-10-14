_G.Polygon = {}

function Polygon.new(x ,y)
    local polygon = setmetatable({}, {__index = Polygon});
    -- polygon.mode1 = 'fill';

    polygon.color = LColor.new(255,255,255,255)

    polygon.renderid = Render.PolygonId;

    polygon.circles = {};

    polygon.rects = {};

    polygon.vertices = {};

    polygon.svgpaths = {};

    polygon.usesvgpaths = false;

    polygon.pos = Vector.new();
    polygon.transform =  Matrix.new();
    return polygon;
end

function Polygon:setColor(r, g, b, a)
    self.color.r = r;
    self.color.g = g;
    self.color.b = b;
    self.color.a = a;
end

function Polygon:addCircle(circle)
    table.insert(self.circles, circle);
end

function Polygon:addRect(rect)
    table.insert(self.rects, rect);
end

function Polygon:moveTo(x, y)
    self.pos.x = x;
    self.pos.y = y;
    self.transform:translate(x, y);
end

function Polygon:move(x, y)
    self.pos.x = self.pos.x + x;
    self.pos.y = self.pos.y + y;
    self.transform:translate(x, y);
end

function Polygon:scale(x, y)
    self.transform:scale( x, y);
end

function Polygon:faceTo(x, y)
    self.transform:setXDirection( x - self.pos.x, y - self.pos.y);
end

function Polygon:draw()
    local r, g, b, a = love.graphics.getColor( );
    love.graphics.setColor(self.color.r, self.color.g, self.color.b, self.color.a );
    Render.RenderObject(self);
    love.graphics.setColor(r, g, b, a );
    -- Matrix.reset()
    if self.box2d then
        self.box2d:draw();
    end
end

function Polygon:createSVG(file, entity)
    local svg = lovector.SVG(file);
    -- local current_path = svg.current_path;
    if  svg.userpaths then
        self.usesvgpaths = true;
        self.svgpaths = svg.userpaths;
        -- local entity;
        -- if needentity then
        --     entity = Entity.new();
        -- end
        self:createSVGRenderPaths(self.svgpaths, entity, nil);
        -- if needentity then
        -- --todo..
        -- end
    end

    return svg;
end


function Polygon:createSVGRenderPaths(svgpaths, entity, rootbody)
    
    for i, v in pairs(svgpaths) do
        local svgpath = svgpaths[i];
        local values = {}
        if svgpath.paths then
            svgpath.rendervertices = {}
            for j = 1, #svgpath.paths do
                 local path = svgpath.paths[j];
                 for index, value in pairs(path.vertices) do
                    table.insert(svgpath.rendervertices, value)
                    -- table.insert(values, value);
                 end
            end
            
        end 

        -- if v.typename == 'rect' then
        --     if v.paths and v["user_phytype"] then
               
        --        local box2d = Box2dObject:newPolygon(values);
        --        box2d:setType(v["user_phytype"] == "1" and 'static' or 'dynamic');
        --        local ps = {box2d:getPoints()}
        --     --    svgpath.rendervertices = {}
        --     --    for j, k in pairs(ps) do
        --     --     table.insert(svgpath.rendervertices, k)
        --     --     end
        --     end 
        -- end

        local body;
        if entity and svgpath.rendervertices then--需要创建entity
            local transform = Matrix.new();
            if svgpath.rotate then
                transform:translate(svgpath.rotate.x, svgpath.rotate.y);
                transform:rotate(svgpath.rotate.a);
                transform:translate(-svgpath.rotate.x, -svgpath.rotate.y);
            end
    
            if svgpath.scale then
                transform:scale(svgpath.scale.x, svgpath.scale.y)
            end
    
            if svgpath.translate then
                transform:translate(svgpath.translate.x, svgpath.translate.y)
            end
            
            if svgpath.matrix then
                transform:applyTransform(svgpath.matrix);
            end
    
            if svgpath.skewx then
                transform:shear(svgpath.skewx, 0);
            end
            if svgpath.skewy then
                transform:shear(0, svgpath.skewy);
            end

            local polygon = Polygon.new(0, 0);
            local vertices = {}
            for n = 1,#svgpath.rendervertices,2 do
                local localX, localY = transform:transformPoint( svgpath.rendervertices[n], svgpath.rendervertices[n+1] );
                table.insert(polygon.vertices, localX);
                table.insert(polygon.vertices, localY);
            end
            
            if svgpath.stroke_paint and svgpath.paths then
   
                polygon.stroke_width = svgpath.stroke_width or 2;
                polygon.stroke_paint = svgpath.stroke_paint;--todo;
    
                -- if svgpath.paths and svgpath.rendervertices and #svgpath.rendervertices > 4 then
                --     love.graphics.polygon("line", svgpath.rendervertices );
                -- end
            end
    
            if svgpath.fill_paint then
               
                polygon.fill_paint = svgpath.fill_paint;--todo;
                -- if svgpath.paths and svgpath.rendervertices and #svgpath.rendervertices > 4 then
                --     love.graphics.polygon("fill", svgpath.rendervertices );
                -- end
            end

            if not body then
                print('ccccccccccc', not rootbody)
                if not rootbody then --没有body的时候 创建rootbody
                    rootbody = Body.new("", 0);--name, order
                    entity.body = rootbody;
                    body = rootbody;
                    print('bbbbbbbbbbbbbbbbb',entity, entity.body)
                else
                    body = Body.new("", 0);--name, order
                    table.insert(rootbody.children, body);
                end
            end
            
            table.insert(body.polygons, polygon);
        end

        
        if svgpath.childrens then
            self:createSVGRenderPaths(svgpath.childrens, entity, body)
        end
    end
end