_G.CollisionManager = {}

local Groups = {}
local GroupsHelper = {}-- setmetatable({}, {__mode = "kv"})

_G.CollisionManager.Add = function(binder)
    local index
    if not GroupsHelperp[binder.GroupName] then
        index = #Groups + 1
        GroupsHelperp[binder.GroupName] = index
    else
        index = GroupsHelperp[binder.GroupName] 
    end

    local SelfGroup
    if not Groups[index] then
        SelfGroup =  Collisionbinder.new(binder.GroupName)
        Groups[index] =  SelfGroup
    else
        SelfGroup = Groups[index]
    end

    SelfGroup.AddBinder(binder)
end

_G.CollisionManager.Remove = function(binder)
    
    local index = GroupsHelperp[binder.GroupName]
    if not index then
        return
    end

    local SelfGroup = Groups[index]
    if SelfGroup.RemoveBinder(binder) then
        GroupsHelperp[binder.GroupName] = nil
        table.remove(Groups, index)
    end
end

_G.CollisionManager.Update = function(e)

end

app.update(function(dt)
    CollisionManager.Update(dt)
end)
