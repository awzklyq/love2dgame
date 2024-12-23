_G.Cone2D = {}

function Cone2D.new(InPostion, InDirection, InRadius, InAngle, InSegments, InMode)
    local c2d = setmetatable({}, {__index = Cone2D});
    c2d.dir = InDirection or Vector.new(1, 0)
    c2d.pos = InPostion or Vector.new(0, 0)
    c2d.r = InRadius or 1;
    c2d.angle = math.rad(InAngle or 0);

    
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

function Cone2D:CheckPointInXY(x, y)
    return self:CheckPointInVec(Vector.new(x, y))
end

function Cone2D:CheckPointInVec(InVec)
    local TargetDir = (InVec - self.pos):Normalize()
    local angle = Vector.angleClockwise(self.dir, TargetDir)
    if angle > math.pi then
        angle = math.pi * 2 - angle
    end
    return self.angle * 0.5 > angle
end

function Cone2D:MoveVec(InVec)
    self.pos = self.pos + InVec
end

function Cone2D:GetAngle()
    return self.angle
end

function Cone2D:BuildRays()
    local ODir = Vector.copy(self.dir)
    local angle = self.angle * 0.5

    ODir:RotateClockwise(angle)
    self.Ray1 =  Ray2D.new(Vector.copy(self.pos), ODir)

    ODir:Set(self.dir)
    ODir:RotateClockwise(-angle)
    self.Ray2 =  Ray2D.new(Vector.copy(self.pos), ODir)
end

function Cone2D:FindNearestPoint(InStartPoint, InEndPoint)
    local InLine = Line.new(InStartPoint.x, InStartPoint.y, InEndPoint.x, InEndPoint.y)
    local IsintersectLine = {IsIntersect = false}
    if not self.Ray1 or not self.Ray2 then
        return IsintersectLine
    end

    local IntersectLine1 = self.Ray1:IsintersectLine(InLine)
    local IntersectLine2 = self.Ray2:IsintersectLine(InLine)

    IsintersectLine.IsIntersect = IntersectLine1.IsIntersect or IntersectLine2.IsIntersect
    if not IsintersectLine.IsIntersect then
        return IsintersectLine
    end

    if IntersectLine1.IsIntersect then
        IsintersectLine.IntersectPoint = IntersectLine1.IntersectPoint
    end

    if IsintersectLine.IntersectPoint then
        if Vector.distance(IsintersectLine.IntersectPoint, InStartPoint) < Vector.distance(IntersectLine2.IntersectPoint, InStartPoint) then
            IsintersectLine.IntersectPoint = IntersectLine2.IntersectPoint
        end
    else
        IsintersectLine.IntersectPoint = IntersectLine2.IntersectPoint
    end

    return IsintersectLine

end

function Cone2D:draw()
    if not self.Visible then return end

    self:ResetRenderParame()
    Render.RenderObject(self);
end