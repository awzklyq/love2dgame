
local role = Role.new();
role:setColor(180, 180, 180, 255);

local battery = Battery.new();
battery:moveTo(200, 200);
local x, y, oldx, oldy = 0, 0, 0, 0
local offset = 3;

local bottom = Rect.new(10, 800, 900, 10, "line")
bottom:createBox2D();

local left = Rect.new(10, 0, 10, 790, "line")
left:createBox2D();

local right = Rect.new(890, 0, 10, 790, "line")
right:createBox2D();


local rectl = Rect.new(400, 200, 40, 40, "line")
-- rectl:createBox2D("dynamic",1);

local bullet = Bullet.new(100, 100, 600, 10);
local bulletrect = Rect.new(0, 0, 30, 30, "line");
bullet.polygon:addRect(bulletrect);
bullet:setDirection(1, 1);
-- rectl.box2d:setGravityScale(0.1);
_G.app.update(function(dt)
    x = love.mouse.getX()
    y = love.mouse.getY()
    if math.abs(x - oldx) > offset or math.abs(y - oldy) > offset then
        oldx = x;
        oldy = y;
        role:moveTo(x, y);
        battery:faceTo(x, y);
    end

    bottom:update(dt);
    left:update(dt);
    right:update(dt);

    role:update(dt);
    rectl:update(dt);
end)

local temp = Polygon.new(100, 100);
local svg = temp:createSVG("demo_files/bananicorn.svg");--method-draw-image.svg
sometable = {
    100, 100,
    200, 200,
    300, 100,
    400, 200,
 }

_G.app.render(function(e)
    -- role:draw(e);
    -- bottom:draw();

    -- left:draw();
    -- right:draw();

    -- battery:draw();
    rectl:draw();

 --  temp:draw();

  -- svg:draw(0, 0)
end)

    local buttonB = UIButton:new()
    buttonB:setPos(200, 100)
    buttonB:setText("B")
    buttonB:setIcon("script/ui/img/icon_haha.png")
    buttonB:setAnchor(0, 0)
    mgr.rootCtrl.coreContainer:addChild(buttonB)