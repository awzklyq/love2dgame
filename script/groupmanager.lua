_G.GroupManager = {}

_G.GroupManager.currentgroup = nil;
_G.GroupManager.groups = {};

_G.GroupManager.loadGroup = function(name)
    if not _G[name..'Group'] then
        dofile("script/"..name..'Group.lua');
    end
    local group = _G[name..'Group'].new();
    group:init();
    _G.GroupManager.groups[group] = group;

    
    _G.GroupManager.currentgroup = group;

    return group
end

_G.GroupManager.releaseGroup = function(group)
    group:release();
    _G.GroupManager.groups[group] = nil;
end

app.render(function(dt)
    for i, v in pairs(_G.GroupManager.groups) do
        if v.draw then
            v:draw(dt);
        end
    end
end)