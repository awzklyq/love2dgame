
_G.Me = {}
_G.__setParentClass(Me, Entity)
function Me.new()
    local me = setmetatable({}, {__index = Me});
    _G.__setParentObject(me, Entity);
    return me;
end