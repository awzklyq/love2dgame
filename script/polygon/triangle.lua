_G.Triangle2D = {}

function Triangle2D.new(p1, p2, p3, linewidth)-- Vector2 or Vector3...
    local tri = setmetatable({}, {__index = Triangle2D});

    tri.P1 = p1
    tri.P2 = p2
    tri.P3 = p3

    tri.Color = LColor.new(255,255,255,255)

    tri.LineWidth = linewidth or 2

    tri.edge1 = Edge2D.new(tri.P1, tri.P2)
    tri.edge2 = Edge2D.new(tri.P2, tri.P3)
    tri.edge3 = Edge2D.new(tri.P3, tri.P1)

    tri.mode = "line"

    tri.vertices = {}
    tri:GetVertices()

    tri.renderid = Render.Triangle2DId ;

    return tri
end

function Triangle2D:SetColor(r, g, b, a)
    self.Color.r = r
    self.Color.g = g
    self.Color.b = b
    self.Color.a = a
end

function Triangle2D:GetVertices()
    self.vertices[#self.vertices + 1] = self.P1.x
    self.vertices[#self.vertices + 1] = self.P1.y

    self.vertices[#self.vertices + 1] = self.P2.x
    self.vertices[#self.vertices + 1] = self.P2.y

    self.vertices[#self.vertices + 1] = self.P3.x
    self.vertices[#self.vertices + 1] = self.P3.y
end

function Triangle2D:draw()
    -- local r, g, b, a = love.graphics.getColor( );
    Render.RenderObject(self);
    -- love.graphics.setColor(r, g, b, a );
end


_G.Triangle2Ds = {}

function Triangle2Ds.new(vertices)-- Vector2 or Vector3...
    local tris = setmetatable({}, {__index = Triangle2Ds});

    tris.Triangles = {}
    if vertices and #vertices > 0 then
    
        local count = math.floor( #vertices / 3) * 3
        if count > 0 then
            for i = 1, count, 3 do
                tris.Triangles[#tris.Triangles + 1] = Triangle2D.new(vertices[i], vertices[i + 1], vertices[i + 2])
            end
        end
    end

    return tris;
end

function Triangle2Ds:GenerateRandomPoints(TriangleCount, StartPoint, EndPoint)
    for i = 1, TriangleCount do
        tris.Triangles[#tris.Triangles + 1] = Triangle2D.new(vertices[i], vertices[i + 1], vertices[i + 2])
    end
end