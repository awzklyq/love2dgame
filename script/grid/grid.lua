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

    grid.box = Box.new(x, y, x + w, y +h)

    grid.w = w
    grid.h = h
    grid.size = size

    grid.renderid = Render.GridDebugViewId

    grid.objs = setmetatable({}, {__mode = "kv"});
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

    local startx = math.ceil((x1 - self.box.x1) / self.size)
    local starty = math.ceil((y1 - self.box.y1) / self.size)

    local endx = math.ceil((x2 - self.box.x1) / self.size)
    local endy = math.ceil((y2 - self.box.y1) / self.size)

    assert(endx >= startx and endy >= starty, "error : startx: "..startx.." starty: "..starty .."endx: "..endx.." endy: "..endy)

    obj.grids[1] = 1
    if startx == endx and starty == endy then
        self.datas[i][j][obj] = obj
        obj[2] = {grid = self.datas[i][j], i = i, j =j}
    else
        for i = startx, endx do
            for j = starty, endy do
                self.datas[i][j][obj] = obj;
                obj.grids[#obj.grids +1] = {grid = self.datas[i][j], i = i, j =j}
            end
        end

    end

    self.objs[obj] = obj
end

function Grid:remove(obj)
    if not obj.grids then
        return;
    end

    for i = 2, obj.grids[1] do
        obj.grids[i]["grid"][obj] = nil
    end

    obj.grids = {}
    self.objs[obj] = nil
end

function Grid:draw()
    if _G.lovedebug.showgridinfo then
        Render.RenderObject(self);
    end
end

function Grid:renderDebugView()
    if not self.canvas then
        self.canvas = love.graphics.newCanvas(self.w, self.h)
        local lw = love.graphics.getLineWidth();
        local r, g, b, a = love.graphics.getColor( );
        love.graphics.setCanvas(self.canvas)
        love.graphics.setLineWidth( 5);
        
    


        for i = 0, self.wn -1 do
            for j = 0, self.hn - 1 do
                local x1 = i * self.size
                local y1 =  j * self.size

                local x2 =  (i + 1) * self.size
                local y2 =  (j + 1) * self.size
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
    
    love.graphics.draw(self.canvas, self.box.x1, self.box.y1)

    local r, g, b, a = love.graphics.getColor( );
    love.graphics.setColor(0.8,0.8,0.8);
    local lw = love.graphics.getLineWidth();
        
    love.graphics.setLineWidth( 5);
    for i, v in pairs(self.objs) do
        local x1, y1, x2, y2 = v.box:getBoxValueFromObj();
        for j = 2, #v.grids do
            local k = v.grids[j]
            -- love.graphics.print("( "..k.i..", "..k.j.." )", x2 + 5, y2)
            love.graphics.print('ssssssssssssssssssssssssssss',x2 + 5, y2 + (j -2) * 10 )
        end
    end
    love.graphics.setColor(r, g, b, a);
    love.graphics.setLineWidth(lw);
end


