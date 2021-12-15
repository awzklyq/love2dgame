_G.Grid = {}

function Grid.new(x, y, w, h, size)
    local grid = setmetatable({}, {__index = Grid})

    grid.datas = {}
    grid.wn = math.ceil(w / size)
    grid.hn = math.ceil(w / size)

    for i = 1, grid.wn do
        grid.datas[i] = {}
        for j = 1, grid.hn do
            grid.datas[i][j] = setmetatable({}, {__mode = "kv"});
        end
    end
    grid.neednotCheckForNoiseLine = setmetatable({}, {__mode = "kv"});
    grid.box = Box2D.new(x, y, x + w, y +h)

    grid.w = w
    grid.h = h
    grid.size = size

    grid.renderid = Render.GridDebugViewId

    grid.objs = setmetatable({}, {__mode = "kv"});

    grid.debug_needupdate = false
    grid.debug_filltabs = {}--setmetatable({}, {__mode = "kv"});
    return grid
end

function Grid:addOrChange(obj)
   assert(obj.box and obj.transform)

    if not obj.grids then
        obj.grids= {}
    else
        self:remove(obj)
    end
    local x1, y1, x2, y2 = obj.box:getBoxValueFromObj()

    local startx = math.min(self.wn,math.max(1, math.floor((x1 - self.box.x1) / self.size)))
    local starty = math.min(self.hn,math.max(1, math.floor((y1 - self.box.y1) / self.size)))

    local endx = math.max(1, math.min(self.wn, math.floor((x2 - self.box.x1) / self.size)))
    local endy = math.max(1,math.min(self.hn, math.floor((y2 - self.box.y1) / self.size)))

    startx = math.min(startx, endx)
    starty = math.min(starty, endy)

    endx = math.max(startx, endx)
    endy = math.max(starty, endy)

    assert(endx >= startx and endy >= starty, "error : startx: "..startx.." starty: "..starty .."endx: "..endx.." endy: "..endy)

    if startx == endx and starty == endy then
        self.datas[startx][starty][obj] = obj
        obj[2] = {grid = self.datas[startx][starty], i = startx, j =starty}
        self.debug_filltabs[self.datas[startx][starty]] = {grid = self.datas[startx][starty], i = startx, j = starty}
    else
        for i = startx, endx do
            for j = starty, endy do
                _errorAssert(self.datas[i][j], "self.datas[i][j] is nil ".. i .." "..j)
                self.datas[i][j][obj] = obj;
                obj.grids[#obj.grids +1] = {grid = self.datas[i][j], i = i, j =j}
                self.debug_filltabs[self.datas[i][j]] = { grid = self.datas[i][j], i = i, j = j}
            end
        end

    end

    self.objs[obj] = obj

    self.debug_needupdate = true
end

function Grid:addNeednotCheckForNoiseLine(obj)
    self.neednotCheckForNoiseLine[obj] = obj
end

function Grid:findNearestPointByLine(x1, y1, x2, y2)
    local startx = math.min(self.wn,math.max(1, math.floor((x1 - self.box.x1) / self.size)))
    local starty = math.min(self.hn,math.max(1, math.floor((y1 - self.box.y1) / self.size)))

    local endx = math.max(1, math.min(self.wn, math.floor((x2 - self.box.x1) / self.size)))
    local endy = math.max(1,math.min(self.hn, math.floor((y2 - self.box.y1) / self.size)))

    startx = math.min(startx, endx)
    starty = math.min(starty, endy)

    endx = math.max(startx, endx)
    endy = math.max(starty, endy)

    _errorAssert(endx >= startx and endy >= starty, "findNearestPointByLine error : startx: "..startx.." starty: "..starty .."endx: "..endx.." endy: "..endy)

    local datas = {}
    for i = startx, endx do
        for j = starty, endy do
            _errorAssert(self.datas[i][j], "self.datas[i][j] is nil ".. i .." "..j)
           
            for _, obj in pairs(self.datas[i][j]) do
                if not self.neednotCheckForNoiseLine[obj] and obj.renderid == Render.PolygonId then      
                    table.insert(datas, mlib.polygon.getLineIntersection(x1, y1, x2, y2, obj:getPoints(false, true, false)))
                end
            end
        end
    end

    -- for _, obj in pairs(self.objs) do
    --     if not self.neednotCheckForNoiseLine[obj] and obj.renderid == Render.PolygonId then
    --         table.insert(datas, mlib.polygon.getLineIntersection(x1, y1, x2, y2, obj:getPoints(false, true, false)))
    --     end
    -- end

    local dis = 1000
    local x, y = -1, -1
    for _, tab in pairs(datas) do
        if tab then
            for i = 1, #tab do
               
                local temp = mlib.line.getLength(x1, y1, tab[i][1], tab[i][2]);
                if temp < dis then
                    dis = temp;
                    x, y =  tab[i][1], tab[i][2]
                    
                end
            end
        end
        
    end

    if x == -1 and y == -1 and dis == 1000 then
        return nil
    end

    log("Noise Find NearestPoint From To", x1, y1, x, y)
    return {x = x, y = y, dis = dis}
end

function Grid:remove(obj)
    if not obj.grids then
        return;
    end

    local grids = {}
    for i = 1, #obj.grids do
        obj.grids[i]["grid"][obj] = nil
        grids[obj.grids[i]["grid"]] = obj.grids[i]["grid"]
    end

    obj.grids = {}
    
    self.objs[obj] = nil

    --debug
    for i, v in pairs(grids) do
        self.debug_filltabs[v] = nil
    end

end

function Grid:draw()
    if _G.lovedebug.showgridinfo then
        Render.RenderObject(self);
    end
end

function Grid:renderDebugView()
    if not self.debug_canvas then
        self.debug_canvas = love.graphics.newCanvas(self.w, self.h)
        local lw = love.graphics.getLineWidth();
        local r, g, b, a = love.graphics.getColor( );
        love.graphics.setCanvas(self.debug_canvas)
        love.graphics.clear(0, 0, 0)
        love.graphics.setLineWidth( 5);
        
        for i = 0, self.wn -1 do
            for j = 0, self.hn - 1 do
                local x1 = i * self.size + self.box.x1
                local y1 =  j * self.size + self.box.y1

                local x2 =  (i + 1) * self.size + self.box.x1
                local y2 =  (j + 1) * self.size + self.box.y1
                love.graphics.setColor(0.8,0.8,0.8);
                love.graphics.print("( "..i..", "..j.." )", x1 + 5, y1 + 10)
                love.graphics.setColor(0.8,0.8,0);
                love.graphics.line(x1, y1, x1, y2)
                love.graphics.line(x1, y2, x2, y2)
                love.graphics.line(x2, y2, x2, y1)
                love.graphics.line(x2, y1, x1, y1)
            end
        end
        
        love.graphics.setLineWidth(lw);
        love.graphics.setColor(r, g, b, a);
        love.graphics.setCanvas()
    end

    if self.debug_needupdate then
        if not self.debug_canvas_rect then
            self.debug_canvas_rect = love.graphics.newCanvas(self.w, self.h)
        end
        local r, g, b, a = love.graphics.getColor( );
        love.graphics.setCanvas(self.debug_canvas_rect)
        love.graphics.clear(0, 0, 0, 0)
        
        for i, v in pairs(self.debug_filltabs) do
            local x1 = (v.i -1) * self.size + self.box.x1
            local y1 = (v.j - 1) * self.size + self.box.y1

            local x2 =  v.i * self.size- self.box.x1
            local y2 =  v.j * self.size- self.box.y1

            love.graphics.setColor(0.8,0.8,0.8, 0.4);
            love.graphics.rectangle("fill", x1, y2, x2 -x1, y2 -y1)
        end
        
        love.graphics.setColor(r, g, b, a);
        love.graphics.setCanvas()

        self.debug_needupdate = false
    end
    
    love.graphics.draw(self.debug_canvas, self.box.x1, self.box.y1)
    love.graphics.draw(self.debug_canvas_rect, self.box.x1, self.box.y1)
    -- local r, g, b, a = love.graphics.getColor( );
    -- love.graphics.setColor(0.8,0.8,0.8);
    -- local lw = love.graphics.getLineWidth();
        
    -- love.graphics.setLineWidth( 5);
    -- for i, v in pairs(self.objs) do
    --     local x1, y1, x2, y2 = v.box:getBoxValueFromObj();
    --     for j = 1, #v.grids do
    --         local k = v.grids[j]
    --         -- love.graphics.print("( "..k.i..", "..k.j.." )", x2 + 5, y2)

    --         love.graphics.print("( "..k.i..", "..k.j.." )",x2 + 5, y2 + (j -2) * 10 )
    --     end
    -- end
    -- love.graphics.setColor(r, g, b, a);
    -- love.graphics.setLineWidth(lw);
end


