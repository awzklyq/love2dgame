
_G.Edge2D = {}


local metatable_Edge2D = {}
metatable_Edge2D.__index = Edge2D

metatable_Edge2D.__eq = function(myvalue, value)
    return (myvalue.P1 == value.P1 and  myvalue.P2 == value.P2) or (myvalue.P1 == value.P2 and  myvalue.P2 == value.P1)
end

function Edge2D.new(p1, p2)
    local edge = setmetatable({}, metatable_Edge2D);

    edge.P1 = p1
    edge.P2 = p2

    if not edge.P1.Edges then
        edge.P1.Edges = {}
    end

    if not edge.P2.Edges then
        edge.P2.Edges = {}
    end

    edge.P1.Edges[#edge.P1.Edges + 1] = edge
    edge.P2.Edges[#edge.P2.Edges + 1] = edge

    return edge
end