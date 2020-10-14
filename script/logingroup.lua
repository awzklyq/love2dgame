_G.LoginGroup = {}

function LoginGroup.new()
    local group = setmetatable({}, {__index = LoginGroup});
    return group;
end

function LoginGroup:init()
    local button = LoginGroup:createUI("Button")
    button:setPos(200, 200);
    button:setText("Login");
    button.click = function()
        _G.GroupManager.releaseGroup(self)
        _G.GroupManager.loadGroup("Level1");
    end
end

function LoginGroup:createUI(typename, ...)
    return UIHelper.createGroupUI("login", typename, ...);
end

function LoginGroup:clearUI()
    return UIHelper.clearGroupUI("login");
end

function LoginGroup:release()
    self:clearUI();
end