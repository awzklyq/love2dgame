_G.Cone2D = {}

function Cone2D.new(InPostion, InDirection, InRadius, InAngle, InSegments, InMode)
    local c2d = setmetatable({}, {__index = Cone2D});
    c2d.dir = InDirection;
    c2d.pos = InPostion
    c2d.r = InRadius;
    c2d.angle = math.rad(InAngle);

    
    c2d.seg = InSegments or 100;

    c2d.mode = InMode or "line"
    c2d.color = LColor.new(255,255,255,255)
    c2d.Visible = true

    c2d.DefaultDirection = Vector.new(1, 0)

    c2d.renderid = Render.Cone2DId;
    return c2d;
end

function Cone2D:setColor(r, g, b, a)
    if g then
        self.color.r = r;
        self.color.g = g;
        self.color.b = b;
        self.color.a = a;
    else
        self.color:Set(r)
    end
end

Cone2D.SetColor = Cone2D.setColor

function Cone2D:ResetRenderParame()
    local dir = Vector.copy(self.dir)
    dir.y = dir.y * -1
    local angle = Vector.angleClockwise(self.DefaultDirection, dir)
    self.angle1 = angle - self.angle * 0.5
    self.angle2 = angle + self.angle * 0.5
end

function Cone2D:draw()
    if not self.Visible then return end

    self:ResetRenderParame()
    Render.RenderObject(self);
end