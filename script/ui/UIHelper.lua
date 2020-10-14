require "script/ui/catui"
_G.UIHelper = {}
local groupuis = {}
_G.mgr = UIManager:getInstance()

_G.UIHelper.mouseUp = function(x, y, button, isTouch)
    mgr:mouseUp(x, y, button, isTouch);
end

_G.UIHelper.keypressed = function(key, scancode, isrepeat)
    mgr:keyDown(key, scancode, isrepeat);
end

_G.UIHelper.keyreleased = function(key)
    mgr:keyUp(key);
end

_G.UIHelper.wheelmoved = function(x, y)
    mgr:whellMove(x, y);
end

_G.UIHelper.textinput = function(text)
    mgr:textInput(text);
end

_G.UIHelper.update = function(dt)
    mgr:update(dt);
end

_G.UIHelper.draw = function()
    mgr:draw();
end

_G.UIHelper.mouseDown = function(x, y, button, istouch)
    mgr:mouseDown(x, y, button, isTouch);
end

_G.UIHelper.mousemoved = function(x, y, dx, dy, istouch)
    mgr:mouseMove(x, y, dx, dy);
end

UIHelper.createGroupUI = function(groupname,typename, ...)
    local ui = _G["UI"..typename]:new(...);
    mgr.rootCtrl.coreContainer:addChild(ui);
    if not groupuis[groupname] then
        groupuis[groupname] = {}
    end
    groupuis[groupname][ui] = ui;
    -- table.insert(groupuis[groupname], ui)
    return ui;
end

UIHelper.removeGroupUI = function(groupname, ui)
    if not groupuis[groupname] then return end; --TODO.. assert
    mgr.rootCtrl.coreContainer:removeChild(ui);
    groupuis[groupname][ui] = nil
end

UIHelper.clearGroupUI = function(groupname)
    if not groupuis[groupname] then return end; --TODO.. assert
    for i, v in pairs(groupuis[groupname]) do 
        mgr.rootCtrl.coreContainer:removeChild(v);
    end
    groupuis[groupname] = nil;
end
    --  function love.load()
--     love.window.setMode( 1024,960 )
--     _G.app.load();
--  end