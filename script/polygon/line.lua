_G.Line = {}

function Line.new(x1, y1, x2, y2, lw)-- lw :line width
    local line = setmetatable({}, {__index = Line});
    if type(x1) == "table" and type(y1) == "table" then
        line.x1 = x1.x
        line.y1 = x1.y

        line.x2 = y1.x
        line.y2 = y1.y

        line.lw = x2 or 2;
    else
        line.x1 = x1 or 0;
        line.y1 = y1 or 0;
        line.x2 = x2 or 1;
        line.y2 = y2 or 1;
    
        line.lw = lw or 2;
    end
    
    line.color = LColor.new(255,255,255,255)

    line:GeneraOutCircle()
    line.renderid = Render.LineId ;

    line.IsDrawOutCircle = false
    return line;
end

function Line:setColor(r, g, b, a)
    self.color.r = r;
    self.color.g = g;
    self.color.b = b;
    self.color.a = a;
end

function Line:IsEqual(line)
    if self.x1 == line.x1 and self.y1 == line.y1 and  self.x2 == line.x2 and self.y2 == line.y2 then
        return true
    end

    if self.x1 == line.x2 and self.y1 == line.y2 and  self.x2 == line.x1 and self.y2 == line.y1 then
        return true
    end
    return false
end


Line.SetColor = Line.setColor

function Line:GeneraOutCircle()
    local x =  self.x2 - self.x1
    local y =  self.y2 - self.y1

    local r = math.sqrt(x * x + y * y) * 0.5

    local center = Vector.new((self.x2 + self.x1) * 0.5, (self.y2 + self.y1) * 0.5)

    self.OutCircle = Circle.new(r, center.x ,center.y, 50)
end

function Line:draw()
    -- local r, g, b, a = love.graphics.getColor( );
    Render.RenderObject(self);
    -- love.graphics.setColor(r, g, b, a );
    if self.IsDrawOutCircle then
        self.OutCircle:draw()    
    end
end

--https://deepnight.net/tutorial/bresenham-magic-raycasting-line-of-sight-pathfinding/
function Line:GeneratePoints()
    local ps = {}
    local x0 = self.x1
    local y0 = self.y1

    local x1 = self.x2
    local y1 = self.y2

    local swapXY = math.abs(y1 - y0) > math.abs(x1 - x0)
    if swapXY then
        x0 = self.y1
        y0 = self.x1

        x1 = self.y2
        y1 = self.x2
    end

    if x0 > x1 then
        local temp = x0
        x0 = x1
        x1 = temp

        temp = y0
        y0 = y1
        y1 = temp
    end

    local deltax = x1 - x0
    local deltay = math.floor( math.abs(y1 - y0) )
    local _error = math.floor( deltax * 0.5 )
    local y = y0
    local ystep = y1 > y0 and 1 or -1
    for x = x0 - 1, x1 do
        if swapXY then
            ps[#ps + 1] = Point2D.new(y, x)
        else
            ps[#ps + 1] = Point2D.new(x, y)
        end

        _error = _error - deltay
        if _error < 0 then
            y = y + ystep
            _error = _error + deltax
        end
    end
    local points = Point2DCollect.new(ps)
    return points
end

_G.Lines = {}

function Lines.new( )-- lw :line width
    local lines = setmetatable({}, {__index = Lines});
    
    lines.color = LColor.new(255,255,255,255)

    lines.renderid = Render.LinesId ;
    lines.lw = 2;
    lines.values = {}
    return lines;
end

function Lines:addValue(x, y)
    self.values[#self.values + 1] = {x = x, y = y}
end

function Lines:clearValues()
    self.values = {}
end

function Lines:removeValueFromIndex(i)
    table.remove(self.values, i)
end

function Lines:setColor(r, g, b, a)
    self.color.r = r;
    self.color.g = g;
    self.color.b = b;
    self.color.a = a;
end

function Lines:draw()
    -- local r, g, b, a = love.graphics.getColor( );
    Render.RenderObject(self);
    -- love.graphics.setColor(r, g, b, a );
end
-- function Rect:update(e)
    
--  end

function cross(a, b, c, d)
    return (b.x - a.x)*(d.y - c.y) - (b.y - a.y)*(d.x - c.x)
end

function Lines:IsIntersectLine(line)
    local d1 = cross(a, b, c)
    local d2 = cross(a, b, d)
    local d3 = cross(c, d, a)
    local d4 = cross(c, d, b)
    if d1*d2 < 0 and d3*d4 < 0 then
        return true
    end
    return false
end


_G.CrossLine = {}
function CrossLine.new(x, y, w, h, lw)-- lw :line width
    local line = setmetatable({}, {__index = CrossLine});
    line.x = x or 0;
    line.y = y or 0;
    line.w = w or 1;
    line.h = h or 1;

    line.lw = lw or 2;

    line.color = LColor.new(200,0,0, 255)

    line.renderid = Render.CrossLineId ;
    return line;
end

function CrossLine:setColor(r, g, b, a)
    self.color.r = r;
    self.color.g = g;
    self.color.b = b;
    self.color.a = a;
end

function CrossLine:draw()
    Render.RenderObject(self);
end


_G.NoiseLine = {}
function NoiseLine.new(x1, y1, x2, y2, lw, segment, power, speed)-- random
    local line = setmetatable({}, {__index = NoiseLine});
    line.x1 = x1 or 0;
    line.y1 = y1 or 0;
    line.x2 = x2 or 1;
    line.y2 = y2 or 1;

    line.lw = lw or 2;

    line.color = LColor.new(200,0,0, 255)

    line.renderid = Render.NoiseLineId;

    line.tick = 0;

    line.visible = true

    line.power = power or 20

    line.speed = speed or 10

    line.segment = segment

    line:resetData(x1, y1, x2, y2)

    line.mode = "x"
    return line;
end

function NoiseLine:resetData(x1, y1, x2, y2)
    self.datas = {}

    self.renderdatas = {}

    self.datas[1]= x1
    self.datas[2]= y1
    self.renderdatas[1]= x1
    self.renderdatas[2]= y1
    local offset = 1 / self.segment

    for i = 1, self.segment do
        self.datas[#self.datas + 1] = math.lerp(x1, x2, offset * i)
        self.datas[#self.datas + 1] = math.lerp(y1, y2, offset * i)

        self.renderdatas[#self.renderdatas + 1] = math.lerp(x1, x2, offset * i)
        self.renderdatas[#self.renderdatas + 1] = math.lerp(y1, y2, offset * i)
        
    end
end

function NoiseLine:setMode(mode)
    self.mode = mode
end

function NoiseLine:setColor(r, g, b, a)
    self.color.r = r;
    self.color.g = g;
    self.color.b = b;
    self.color.a = a;
end

function NoiseLine:update(e)
    if self.visible then
        for i = 3,  #self.renderdatas - 2, 2 do
            if self.mode == "x" then
                self.renderdatas[i] = self.datas[i] + math.noise(self.datas[i], self.tick * self.speed) * self.power
            else
                self.renderdatas[i + 1] = self.datas[i + 1] + math.noise(self.datas[i +1], self.tick * self.speed) * self.power
            end
            -- self.renderdatas[i + 1] = self.datas[i + 1] + math.noise(self.datas[i], self.tick * 10) * 100
        end
        self.tick = self.tick + e

    end

end

function NoiseLine:draw()
    if self.visible then
        Render.RenderObject(self);
    end
end
