_G.Polygon = {}

function Polygon.new(x ,y)
    local polygon = setmetatable({}, Polygon);
    -- polygon.mode1 = 'fill';

    polygon.color = LColor.new(255,255,255,255)

    polygon.renderid = Render.PolygonId;

    polygon.circles = {};

    polygon.rects = {};

    polygon.vertices = {};

    polygon.triangles = {};

    polygon.svgpaths = {};

    polygon.usesvgpaths = false;

    polygon.transform =  Matrix.new();

    polygon.transform.obj = polygon;

    polygon.box = Box.new()

    -- polygon.revisexy = Vector.new() --TODO for triangles box2d position..

    --polygon.box2d
    return polygon;
end

Polygon.__index = function(tab, key)
    local body = rawget(tab, "body")
    if key == 'parent' and  body then
        return  tab["body"]["parent"];
    end

    if body then
        if key == 'parent' then
            return  body["parent"];
        elseif key == "name" then
            return "Polygon_"..body[key]
        elseif key == "needparentposition" then
            return body[key]
        elseif key == "needparentoffsetpos" then
            return body[key]
        end 
    end

    if Polygon[key] then
        return Polygon[key];
    end

    return rawget(tab, key);
end

Polygon.__newindex = function(tab, key, value)
    rawset(tab, key, value);
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

function Polygon:getWorldPointsBox2d(...)
    if self.box2d then
        return self.box2d:getWorldPoints(...)
    end

    return nil
end

function Polygon:getPoints(needparentposition, needparentoffsetpos, needall)
    local points  = {}
    if self.vertices and #self.vertices > 1 then
        for i = 1, #self.vertices, 2 do
            local x, y = self.transform:transformPoint(self.vertices[i], self.vertices[i + 1],needparentposition, needparentoffsetpos, needall)
            
            points[#points + 1] = x
            points[#points + 1] = y
        end
    end
    return points
end

function Polygon:hasBox2d()
    return self.box2d ~= nil
end

function Polygon:update(e)
    --同步物理信息
    if  self.phytype == "dynamic" and self.box2d then

        local x, y = self.box2d:getWorldCenter( )
        local angle = self.box2d:getAngle( )
        if self.oldbox2dx and self.oldbox2dy and self.oldbox2dangle then
            if math.abs(self.oldbox2dx - x) < 0.000001 and math.abs(self.oldbox2dy - y) < 0.000001 and math.abs(self.oldbox2dangle - angle) < 0.000001 then
                return;
            end
        end 

        if not self.box2doffsetx or not self.box2doffsety then
            local x1, y1 = self.box2d:getPosition()
            self.box2doffsetx = x1 - x;
            self.box2doffsety = y1 - y;
        end

        self.oldbox2dx = x;
        self.oldbox2dy = y;
        -- self.transform:reset();
 
        -- self.transform:rotateLeft(angle - (self.oldbox2dangle or 0))
        self.oldbox2dangle = angle;
    

        local posx, posy = self.transform:getPositionXY()
        local offsetx, offsety = self.transform:getOffsetPosXY();
        self.transform:reset()
        -- if self.isConvex == false then
        --     self.transform:moveTo(x - self.revisexy.x, y - self.revisexy.y );
        -- else
            self.transform:moveTo(x, y);
        -- end
        
        self.transform:rotateLeft(angle)

        local newpos = self.transform:getPosition()
        -- if self.isConvex == false then
        --     self.transform.offsetpos.x = offsetx + newpos.x - posx - self.revisexy.x
        --     self.transform.offsetpos.y = offsety + newpos.y - posy - self.revisexy.y
        -- else
            self.transform.offsetpos.x = offsetx + newpos.x - posx
            self.transform.offsetpos.y = offsety + newpos.y - posy
        -- end

    end
end

function Polygon:draw()

    -- local r, g, b, a = love.graphics.getColor( );
    -- love.graphics.setColor(self.color.r, self.color.g, self.color.b, self.color.a );
    Render.RenderObject(self);
    -- love.graphics.setColor(r, g, b, a );
    -- -- Matrix.reset()
    -- if self.box2d then
    --     self.box2d:draw();
    -- end
    if self.crossline then
        self.crossline:draw();
    end
    self.box:draw()
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
       if entity then
        -- entity:setBodyParent();
       end
    end

    self.debugsvg = svg; --TODO
    return svg;
end


function Polygon:createSVGRenderPaths(svgpaths, entity, rootbody)
    
    for i, v in pairs(svgpaths) do
        local svgpath = svgpaths[i];
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
            local polygon = Polygon.new(0, 0);
    
            local transform = Matrix.new()
            if svgpath.matrix then
                transform.transform = transform.transform:apply(svgpath.matrix);
                -- polygon.transform.transform = svgpath.matrix

            end
            
            if svgpath.translate then
                transform:moveTo(svgpath.translate.x, svgpath.translate.y)
            end

            if svgpath.scale then
                transform:scale(svgpath.scale.x, svgpath.scale.y)
            end

            if svgpath.rotate then
                transform:rotateLeft(svgpath.rotate.a);

                -- polygon.transform:translate(svgpath.rotate.x, svgpath.rotate.y);
                -- polygon.transform:rotate(svgpath.rotate.a);
                -- polygon.transform:translate(-svgpath.rotate.x, -svgpath.rotate.y);
            end
    
            if svgpath.skewx then
                transform:shear(svgpath.skewx, 0);

            end
            if svgpath.skewy then
                transform:shear(0, svgpath.skewy);
            end

            
            local vertices = {}


            if v.typename == 'path' then
                table.remove(svgpath.rendervertices,#svgpath.rendervertices)
                table.remove(svgpath.rendervertices,#svgpath.rendervertices)
            end
            for n = 1, #svgpath.rendervertices, 2 do
                local localX, localY = transform:transformPoint( svgpath.rendervertices[n], svgpath.rendervertices[n+1] );
                table.insert(polygon.vertices, localX);
                table.insert(polygon.vertices, localY);
            end
            

            polygon.isConvex = love.math.isConvex(polygon.vertices);
            

            if svgpath.stroke_paint and svgpath.paths then
   
                polygon.stroke_width = svgpath.stroke_width or 2;
                polygon.stroke_paint = svgpath.stroke_paint;--todo;
    
                -- if svgpath.paths and svgpath.rendervertices and #svgpath.rendervertices > 4 then
                --     love.graphics.polygon("line", svgpath.rendervertices );
                -- end
            end
    
            if svgpath.fill_paint then
               
                polygon.fill_paint = svgpath.fill_paint;--todo;
            end
           
            if polygon.isConvex then
                if v.paths and v["user_phytype"] then
                    if v.typename == 'rect' then
                        polygon.box2d = Box2dObject:newPolygon(polygon.vertices);
                    
                        polygon.box2d:setType(v["user_phytype"] == "1" and 'static' or 'dynamic');
                    elseif v.typename == 'ellipse' or  v.typename == 'path' then
                        if #polygon.vertices <= 32 then
                            polygon.box2d = Box2dObject:newPolygon(polygon.vertices);
                        else
                            local vertices = {}
                            local count = #polygon.vertices / 2;
                            local op =math.ceil(count / 16);

                            for offset =1,#polygon.vertices ,op * 2 do 
                                table.insert(vertices, polygon.vertices[offset] );
                                table.insert(vertices, polygon.vertices[offset + 1] );
                            end
                            
                            polygon.box2d = Box2dObject:newPolygon(vertices);
                        end

                        polygon.box2d:setType(v["user_phytype"] == "1" and 'static' or 'dynamic');
                    -- elseif v.typename == 'path' then
                    end
                end 
            end
         
            polygon['svg_typename'] = v.typename
            if not body then
                if not rootbody then --没有body的时候 创建rootbody
                    rootbody = Body.new(v["name"], 0);--name, order
                    entity:setBody(rootbody);
                    body = rootbody;
                else
                    body = Body.new(v["name"], 0);--name, order
                    rootbody:addBody(body);
                end

                if v["parentname"] and v["parentname"]  ~= ""then
                    body.parentname = v["parentname"];
                end
            end

            for m, n in pairs(v) do
                if string.find(m, "user_") then
                    body[string.gsub(m, "user_", "")] = n
                end
            end
 
            if polygon.isConvex == false then
                local centerx, centery = 0, 0
                local num = #polygon.vertices
                for i = 1, num, 2 do
                    centerx = centerx + polygon.vertices[i];
                    centery = centery + polygon.vertices[i +1]
                end
        
                centerx = centerx / (num / 2)
                centery = centery / (num / 2)
        
                for i = 1, num, 2 do
                    local triangle = {}
                    table.insert(triangle, polygon.vertices[i])
                    table.insert(triangle, polygon.vertices[i +1])
        
                    table.insert(triangle, centerx)
                    table.insert(triangle, centery)
        
                    if i + 1 == num then
                        table.insert(triangle, polygon.vertices[1])
                        table.insert(triangle, polygon.vertices[2])
                        
                    else
                        table.insert(triangle, polygon.vertices[i +2])
                        table.insert(triangle, polygon.vertices[i +3])
                    end
        
                    table.insert(polygon.triangles, triangle)
                end

                if v.paths and v["user_phytype"] then
                    --polygon.triangles[1][3], polygon.triangles[1][4]  -> centerx, centery
                    polygon.box2d = Box2dObject:newPolygon(polygon.triangles[1]);
                    local box2d1 = polygon.box2d
                    for i = 2, #polygon.triangles, 2 do
                        local box2d2 = Box2dObject:newPolygon(polygon.triangles[i]);
                        local joine = polygon.box2d:addJoint('WeldJoint', box2d1, box2d2, polygon.triangles[1][3], polygon.triangles[1][4], true)
                        box2d1 = box2d2
                    end
                end
            end

            body:setPolygon(polygon);

            polygon.phytype = v["user_phytype"] == "1" and 'static' or 'dynamic';
        end

        
        if svgpath.childrens then
            self:createSVGRenderPaths(svgpath.childrens, entity, body)
        end
    end
end