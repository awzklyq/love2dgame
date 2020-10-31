_G.Level1Group = {}

function Level1Group.new()
    local group = setmetatable({}, {__index = Level1Group});
    return group;
end

function Level1Group:init()
    self.levelres = Entity.new()
    self.level1 = Polygon.new(100, 100);
    self.level1:createSVG("levels/level1.svg", self.levelres);--method-draw-image.svg

    self.me = Me.new()
    self.level1:createSVG("demo_files/me.svg", self.me);--method-draw-image.svg

    self.me:init();

    local button = self:createUI("Button")
    button:setPos(200, 200);
    button:setText("Game");
    button.click = function()
        _G.GroupManager.releaseGroup(self)
    end
end

function Level1Group:createUI(typename, ...)
    return UIHelper.createGroupUI("Level1", typename, ...);
end

function Level1Group:clearUI()
    return UIHelper.clearGroupUI("Level1");
end

function Level1Group:release()
    self:clearUI();
end

function Level1Group:update(dt)
    -- if self.level1 then
    --     self.level1:draw(dt);
    -- end

    if self.levelres then
        self.levelres:update();
    end

    if self.me then
        self.me:update();
    end
end

function Level1Group:draw(dt)
    -- if self.level1 then
    --     self.level1:draw(dt);
    -- end

    if self.levelres then
        self.levelres:draw();
    end

    if self.me then
        self.me:draw();
    end
end