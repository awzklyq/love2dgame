_G.Triangle3D = {}

function Triangle3D.new(p1, p2, p3, linewidth)-- Vector2 or Vector3...
    local tri = setmetatable({}, {__index = Triangle3D});

    tri.P1 = p1
    tri.P2 = p2
    tri.P3 = p3

    tri.Color = LColor.new(255,255,255,255)

    tri.LineWidth = linewidth or 2

    tri.mode = "line"

    tri.Edge1 = Edge3D.new(tri.P2, tri.P3)
    tri.Edge2 = Edge3D.new(tri.P1, tri.P3)
    tri.Edge3 = Edge3D.new(tri.P1, tri.P2)

    tri.renderid = Render.Triangle3DId;

    return tri
end

function Triangle3D:GenerateDrawLines()
    self._DrawLines = {}

    self._DrawLines[1] = MeshLine.new(self.P1, self.P2)
    self._DrawLines[2] = MeshLine.new(self.P2, self.P3)
    self._DrawLines[3] = MeshLine.new(self.P3, self.P1)
end

function Triangle3D:SetBaseColor(InColor)
    if not  self._DrawLines then
        self:GenerateDrawLines()
    end
    self._DrawLines[1]:SetBaseColor(InColor)
    self._DrawLines[2]:SetBaseColor(InColor)
    self._DrawLines[3]:SetBaseColor(InColor)
end

function Triangle3D:LogDebugPoint()
    log('Triangle3D Debug Point:')
    log(self.P1.x,self.P1.y, self.P1.z)
    log(self.P2.x, self.P2.y, self.P2.z)
    log(self.P3.x, self.P3.y, self.P3.z)
    log()
end

function Triangle3D:draw()
    if not  self._DrawLines then
        self:GenerateDrawLines()
    end
    for i = 1, #self._DrawLines do
        self._DrawLines[i]:draw()
    end
end