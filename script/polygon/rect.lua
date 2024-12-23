_G.Rect = {}

function Rect.new(x, y, w, h, mode)
    local rect = setmetatable({}, {__index = Rect});
    rect.x = x or 0;
    rect.y = y or 0;
    rect.h = h or 1;
    rect.w = w or 1;

    rect.color = LColor.new(255,255,255,255)

    rect.mode = mode or 'fill';

    rect.lw = 2

    rect:Reset()

    rect.renderid = Render.RectId;
    
    return rect;
end

function Rect:Reset()
    self:GeneraOutCircle()

    self:GeneraLines()
end

function Rect:SetColor(r, g, b, a)
    if g ~= nil then
        self.color.r = r;
        self.color.g = g;
        self.color.b = b;
        self.color.a = a;
    else
        self.color:Set(r)
    end
end

Rect.setColor = Rect.SetColor

function Rect:SetMouseEventEable(enable)
    AddEventToPolygonevent(self, enable)
end

function Rect:moveTo(x, y)
    self.x = x; 
    self.y = y;
    if self.box2d then
        self.box2d:setPosition(x, y);
    end
end

function Rect:SetCenterPosition(x, y)
    self.x = x - self.w * 0.5; 
    self.y = y - self.h * 0.5;
    if self.box2d then
        self.box2d:setPosition(self.x, self.y);
    end
end

function Rect:SetImage(name, ...)
    self.img = ImageEx.new(name, ...)
    self.img.renderWidth = self.w - 1
    self.img.renderHeight = self.h - 1

    self.img.x = self.x + 1
    self.img.y = self.y + 1
end

function Rect:draw()
    Render.RenderObject(self);

    if self.img then
        self.img:draw()
    end

    if self.box2d then
        self.box2d:draw()
    end
end

function Rect:update(e)
    if self.box2d and self.box2d_state == 'dynamic' then--self.box2d:isDynamic()
        local x, y =  self.box2d.body:getWorldCenter();
        self.x = x -  self.w * 0.5;
        self.y = y -  self.h * 0.5;
    end
 end

 function Rect:CheckPointInXY(x, y)
    return x >= self.x and x < self.x + self.w and y >= self.y and y < self.y + self.h
 end

function Rect:createBox2D(state, ...)
    if self.box2d then
        self.box2d:release();
    end
    self.box2d_state = state;
    self.box2d = Box2dObject:CreateRect(self.x + self.w * 0.5,  self.y +  self.h * 0.5,  self.w,  self.h,state, ...)
 end

function Rect:GeneraOutCircle()
    local r = math.sqrt(self.w * self.w + self.h * self.h) * 0.5
    local center = Vector.new(self.x + self.w * 0.5,  self.y + self.h * 0.5)

    self.OutCircle = Circle.new(r, center.x , center.y, 50)
    self.OutCircle.Center = center
end

function Rect:GeneraLines()
    self.Lines = {}
    local l1 =  Line.new(self.x, self.y, self.x + self.w, self.y)
    local l2 =  Line.new(self.x + self.w, self.y, self.x + self.w, self.y +  self.h)
    local l3 =  Line.new(self.x + self.w, self.y + self.h, self.x, self.y + self.h)
    local l4 =  Line.new(self.x, self.y  + self.h, self.x, self.y)

    self.Lines[#self.Lines + 1] = l1
    self.Lines[#self.Lines + 1] = l2
    self.Lines[#self.Lines + 1] = l3
    self.Lines[#self.Lines + 1] = l4
end