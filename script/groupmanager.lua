_G.GroupManager = {}

_G.GroupManager.currentgroup = nil;
_G.GroupManager.groups = {};

_G.GroupManager.loadGroup = function(name)
    if not _G[name..'Group'] then
        if love.filesystem.exists("script/"..name..'Group.lua') then
            dofile("script/"..name..'Group.lua');
        else
            dofile("script/groups/"..name..'Group.lua');
        end
    end

    local group = _G[name..'Group'].new();
    
    _G.GroupManager.groups[group] = group;

    
    _G.GroupManager.currentgroup = group;
    group:init();
    return group
end

_G.GroupManager.releaseGroup = function(group)
    group:release();
    _G.GroupManager.groups[group] = nil;
end

app.update(function(dt)
    for i, v in pairs(_G.GroupManager.groups) do
        if v.update then
            v:update(dt);
        end
    end
end)

app.beforrender(function(dt)
    for i, v in pairs(_G.GroupManager.groups) do
        if v.firstdraw then
            v:firstdraw(dt);
        end
    end
end)

app.render(function(dt)
    for i, v in pairs(_G.GroupManager.groups) do
        if v.draw then
            v:draw(dt);
        end
    end
end)

app.afterrender(function(dt)
    for i, v in pairs(_G.GroupManager.groups) do
        if v.afterdraw then
            v:afterdraw(dt);
        end
    end
end)

app.mousepressed(function(x, y, button, istouch)
    for i, v in pairs(_G.GroupManager.groups) do
        if v.mousepressed then
            v:mousepressed(x, y, button, istouch);
        end
    end
end)

app.keypressed(function(key, scancode, isrepeat)
    for i, v in pairs(_G.GroupManager.groups) do
        if v.keypressed then
            v:keypressed(key, scancode, isrepeat);
        end
    end
end)
