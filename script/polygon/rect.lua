_G.Rect = {}

function Rect.new(x, y, w, h, mode)
    local rect = setmetatable({}, {__index = Rect});
    rect.x = x or 0;
    rect.y = y or 0;
    rect.h = h or 1;
    rect.w = w or 1;

    rect.color = LColor.new(255,255,255,255)

    rect.mode = mode or 'fill';

    rect.renderid = Render.RectId;
    return rect;
end

function Rect:setColor(r, g, b, a)
    self.color.r = r;
    self.color.g = g;
    self.color.b = b;
    self.color.a = a;
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

function Rect:createBox2D(state, ...)
    if self.box2d then
        self.box2d:release();
    end
    self.box2d_state = state;
    self.box2d = Box2dObject:CreateRect(self.x + self.w * 0.5,  self.y +  self.h * 0.5,  self.w,  self.h,state, ...)
 end