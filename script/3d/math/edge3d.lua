
_G.Edge3D = {}


local metatable_Edge3D = {}
metatable_Edge3D.__index = Edge3D

metatable_Edge3D.__eq = function(myvalue, value)
    return (myvalue.P1 == value.P1 and  myvalue.P2 == value.P2) or (myvalue.P1 == value.P2 and  myvalue.P2 == value.P1)
end

function Edge3D.new(p1, p2)
    local edge = setmetatable({}, metatable_Edge3D);

    edge.P1 = p1
    edge.P2 = p2

    edge.renderid = Render.Edge3DId
    
    return edge
end