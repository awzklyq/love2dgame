_G.CollisionPhysics = {}


function CollisionPhysics.new(m, F, damping, friction)
    local obj = setmetatable({}, {__index = CollisionPhysics})

    Obj.Mass = m
    obj.F = F
    obj.Damping = damping

    Obj.Friction = friction 
    return obj
end