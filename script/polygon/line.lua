_G.Line = {}

function Line.new(x1, y1, x2, y2, lw)-- lw :line width
    local line = setmetatable({}, {__index = Line});
    line.x1 = x1 or 0;
    line.y1 = y1 or 0;
    line.x2 = x2 or 1;
    line.y2 = y2 or 1;

    line.lw = lw or 2;

    line.color = LColor.new(255,255,255,255)

    line.renderid = Render.LineId ;
    return line;
end

function Line:setColor(r, g, b, a)
    self.color.r = r;
    self.color.g = g;
    self.color.b = b;
    self.color.a = a;
end

function Line:draw()
    -- local r, g, b, a = love.graphics.getColor( );
    Render.RenderObject(self);
    -- love.graphics.setColor(r, g, b, a );
end

-- function Rect:update(e)
    
--  end

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

    line.datas = {}

    line.renderdatas = {}

    line.datas[1]= x1
    line.datas[2]= y1
    line.renderdatas[1]= x1
    line.renderdatas[2]= y1
    local vec = Vector.new(x2 - x1, y2 - y1)
    local offset = 1 / segment
    vec:normalize()

    vec:mul(offset)
    for i = 1, segment do
        line.datas[#line.datas + 1] = math.lerp(x1, x2, offset * i)
        line.datas[#line.datas + 1] = math.lerp(y1, y2, offset * i)

        line.renderdatas[#line.renderdatas + 1] = math.lerp(x1, x2, offset * i)
        line.renderdatas[#line.renderdatas + 1] = math.lerp(y1, y2, offset * i)
        
    end

    line.color = LColor.new(200,0,0, 255)

    line.renderid = Render.NoiseLineId;

    line.tick = 0;

    line.visible = true

    line.power = power or 20

    line.speed = speed or 10
    return line;
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
            self.renderdatas[i] = self.datas[i] + math.noise(self.datas[i], self.tick * self.speed) * self.power
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
