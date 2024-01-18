_G.Triangle3D = {}

function Triangle3D.new(p1, p2, p3, linewidth)-- Vector2 or Vector3...
    local tri = setmetatable({}, {__index = Triangle3D});

    tri.P1 = p1
    tri.P2 = p2
    tri.P3 = p3

    tri.Color = LColor.new(255,255,255,255)

    tri.LineWidth = linewidth or 2

    tri.mode = "line"

    tri.renderid = Render.Triangle3DId;

    return tri
end