_G.CollisionBinder = {}

function CollisionBinder.new(binder, groupname)
    local obj = setmetatable({}, {__index = CollisionBinder})

    obj.Binder = binder
    obj.GroupName = groupname

    CollisionManager.Add(obj)

    return obj
end

function CollisionBinder:Release( )
    obj.Binder = nil
end