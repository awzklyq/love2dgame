_G.Circle = {}

function Circle.new(r, x ,y, segments)
    local circle = setmetatable({}, {__index = Circle});
    circle.r = r;
    circle.x = x;
    circle.y = y;

    circle.seg = segments or 100;

    circle.color = LColor.new(255,255,255,255)

    circle.mode = 'line';

    circle.Visible = true

    circle.renderid = Render.CircleId;
    return circle;
end

function Circle:setColor(r, g, b, a)
    if g then
        self.color.r = r;
        self.color.g = g;
        self.color.b = b;
        self.color.a = a;
    else
        self.color:Set(r)
    end
end

Circle.SetColor = Circle.setColor

function Circle:CheckPointIn(p)
    return self:CheckPointInXY(p.x, p.y)
end

function Circle:CheckPointInXY(x, y)
    local xx = x - self.x
    local yy = y - self.y

    return xx * xx + yy * yy < self.r * self.r
end

function Circle:GetDirectionPoints(dir, angle, num)
    dir:normalize()
    local ps = {}
    if num == 0 then
        return ps
    end

    local p1 = dir * self.r 

    ps[#ps + 1] = Vector.new( p1.x + self.x, p1.y + self.y)
    if num == 1 then
        return ps
    end

    num = num - 1

    local AddAngle = 0
    local SubAngle = 0
    
    local mat = Matrix2D.new()
    for i = 1, num do
        mat:SetTranslation(self.x, self.y)
        if i % 2 == 0 then
            AddAngle = AddAngle +  angle
            mat:MulRotationLeft(AddAngle)
        else
            SubAngle = SubAngle - angle
            
            mat:MulRotationLeft(SubAngle)
        end
        
        ps[#ps + 1] = p1 * mat
    end

   
    return ps
end

function Circle:SetMouseEventEable(enable)
    AddEventToPolygonevent(self, enable)
end



function Circle:draw()
    if not self.Visible then return end

    Render.RenderObject(self);

    if self.box2d then
        self.box2d:draw()
    end
end