_G.Rect = {}

local EventRects = {}
function Rect.new(x, y, w, h, mode)
    local rect = setmetatable({}, {__index = Rect});
    rect.x = x or 0;
    rect.y = y or 0;
    rect.h = h or 1;
    rect.w = w or 1;

    rect.color = LColor.new(255,255,255,255)

    rect.mode = mode or 'fill';

    rect:GeneraOutCircle()

    rect:GeneraLines()

    rect.renderid = Render.RectId;
    
    return rect;
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
    if enable then
        local needadd = true
        for i = 1, #EventRects do
            if EventRects[i] == self then
                needadd = false
                break
            end
        end
        if needadd then
            EventRects[#EventRects + 1] = self
        end
    else
        for i = 1, #EventRects do
            if EventRects[i] == self then
                table.remove( EventRects, i)
                break
            end
        end
    end
end

function Rect:moveTo(x, y)
    self.x = x; 
    self.y = y;
    if self.box2d then
        self.box2d:setPosition(x, y);
    end
end

function Rect:draw()
    local r, g, b, a = love.graphics.getColor( );
    Render.RenderObject(self);

    -- for i = 1, 4 do
    --     self.Lines[i]:draw()
    -- end
    love.graphics.setColor(r, g, b, a );
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

 local SelectRects = {}
app.mousepressed(function(x, y, button, istouch)
    for i = 1, #EventRects do
        if EventRects[i]:CheckPointInXY(x, y) then
            local SelectRect = EventRects[i]
            SelectRects[#SelectRects + 1] = SelectRect
            if SelectRect.MouseDownEvent then
                SelectRect.MouseDownEvent(SelectRect, x, y, button, istouch)
            end
        end
    end
end)

app.mousemoved(function(x, y, button, istouch)
    for i = 1, #SelectRects do
        local SelectRect = SelectRects[i]
        if SelectRect.MouseMoveEvent then
            SelectRect.MouseMoveEvent(SelectRect, x, y, button, istouch)
        end
    end
end)

app.mousereleased(function(x, y, button, istouch)
    for i = 1, #SelectRects do
        local SelectRect = SelectRects[i]
        if SelectRect.MouseUpEvent then
            SelectRect.MouseUpEvent(SelectRect, x, y, button, istouch)
        end
    end

    SelectRects = {}
end)