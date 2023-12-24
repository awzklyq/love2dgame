_G.Ray2D = {}

function Ray2D.new(orig, dir, lw)
    local ray = setmetatable({}, {__index = Ray2D});

    ray.orig = orig or Vector2.new();
	ray.dir = dir or Vector2.new();

	ray.dir:normalize()

    ray.lw = lw or 2;

    ray.color = LColor.new(255,255,255,255)

	ray.renderid = Render.Ray2DId
    ray.name = 'ray2d'

    return ray
end

function Ray2D:setColor(r, g, b, a)
    self.color.r = r;
    self.color.g = g;
    self.color.b = b;
    self.color.a = a;
end

function Ray2D:SetColor(r, g, b, a)
    self.color.r = r;
    self.color.g = g;
    self.color.b = b;
    self.color.a = a;
end

function Ray2D:IsintersectCircle(circle)
    if circle:CheckPointIn(self.orig) then
        return true
    end
    local v = Vector.new(circle.x - self.orig.x, circle.y - self.orig.y)
    local a2 = v.x * v.x + v.y * v.y
    local r2 = circle.r * circle.r
    local b2 = a2 - r2
    local b = math.sqrt(b2)

    local CosB = b / math.sqrt(a2)

    v:normalize()
    local CosA = Vector.dot(v, self.dir);

    return CosA >= CosB
end


function Ray2D:FindNearestPointByCircle(circle, NeedReflectRay)
    local IntersectCircleData = {}
    IntersectCircleData.IsIntersect = false
    if self:IsintersectCircle(circle) == false then
        return IntersectCircleData
    end

    local k = self.dir.x == 0 and 0 or self.dir.y / self.dir.x

    local kc =  self.orig.y - k * self.orig.x

    local t = kc - circle.y
    local a = k * k + 1
    local b = 2 * k * t - 2 * circle.x
    local c = circle.x * circle.x + t * t - circle.r * circle.r

    local inva2 = a == 0 and 0 or 1 /(2 * a)
    local xx1 = (-b + math.sqrt(b*b - 4 * a * c)) * inva2
    local xx2 = (-b - math.sqrt(b*b - 4 * a * c)) * inva2

    local yy1 = k * xx1 + kc
    local yy2 = k * xx2 + kc

    local v1 = Vector.new(xx1, yy1)
    local v2 = Vector.new(xx2, yy2)
    local dis1 = Vector.Distance(self.orig, v1)
    local dis2 = Vector.Distance(self.orig, v2)
    if dis1 < dis2 then
        IntersectCircleData.IntersectPoint = v1
    else
        IntersectCircleData.IntersectPoint = v2
    end
    IntersectCircleData.IsIntersect = true

    local SelectLineDir = (IntersectCircleData.IntersectPoint - self.orig):normalize()
    local mat = Matrix2D.new()
    mat:MulRotationLeft(90)
    SelectLineDir = SelectLineDir * mat * 10
    local p1 = IntersectCircleData.IntersectPoint + SelectLineDir
    local p2 = IntersectCircleData.IntersectPoint + SelectLineDir

    IntersectCircleData.Selectline = Line.new(p1.x, p1.y, p2.x, p2.y)

    if NeedReflectRay then
        IntersectCircleData.ReflectRay = self:ReflectByLine(IntersectCircleData.Selectline, IntersectCircleData.IntersectPoint)
    end

    return IntersectCircleData
end

function Ray2D:FindNearestPointByCircles(circles)
    local ReturnIntersectCircleData = {}
    ReturnIntersectCircleData.IsIntersect = false

    local distance = math.MaxNumber

    local SelectRect
    for i = 1, #circles do
        local IntersectCircleData = self:FindNearestPointByCircle(circles[i])
        if IntersectCircleData.IsIntersect then
            local dis = Vector.distance(self.orig, IntersectCircleData.IntersectPoint)
            if distance > dis then
                distance = dis

                ReturnIntersectCircleData.IsIntersect = true
                ReturnIntersectCircleData.IntersectPoint = IntersectCircleData.IntersectPoint
                
                ReturnIntersectCircleData.SelectCircle = circles[i]
                ReturnIntersectCircleData.Selectline = IntersectCircleData.Selectline
            end
        end
    end

    if ReturnIntersectCircleData.IsIntersect == true then
        ReturnIntersectCircleData.ReflectRay = self:ReflectByLine(ReturnIntersectCircleData.Selectline, ReturnIntersectCircleData.IntersectPoint)
    end
    
    return ReturnIntersectCircleData
end

-- Return IntersectRectData
function Ray2D:IsIntersectRect(rect)
    local IntersectRectData = {}
    IntersectRectData.IsIntersect = false
    if not self:IsintersectCircle(rect.OutCircle) then
        return IntersectRectData
    end

    local distance = math.MaxNumber
    for i = 1, 4 do
        local IntersectLineData = self:IsintersectLine(rect.Lines[i])
        if IntersectLineData.IsIntersect then
            local dis = Vector.distance(self.orig, IntersectLineData.IntersectPoint)
            if distance > dis then
                IntersectRectData.IsIntersect = true
                IntersectRectData.IntersectPoint = IntersectLineData.IntersectPoint
                distance = dis
                IntersectRectData.MoveDistance = distance
                IntersectRectData.Selectline = rect.Lines[i]
            end
        end
    end

    return IntersectRectData
end

function Ray2D:ReflectByLine(line, point)
    local p = self.orig - point

    local NewPoint = Vector.Copy(self.orig)
    if line.x2 - line.x1 == 0 then
        NewPoint.x = self.orig.x
        if point.y > NewPoint.y then
            NewPoint.y = point.y + math.abs(NewPoint.y - point.y)
        else
            NewPoint.y = point.y - math.abs(NewPoint.y - point.y)
        end
    elseif line.y2 - line.y1 == 0 then
        NewPoint.y = self.orig.y
        if point.x > NewPoint.x then
            NewPoint.x = point.x + math.abs(NewPoint.x - point.x)
        else
            NewPoint.x = point.x - math.abs(NewPoint.x - point.x)
        end
    else
        errorAssert(false, "JB")
    end

    return Ray2D.new(point, NewPoint - point)
end

function Ray2D:FindNearestPointByRects(rects)
    local ReturnIntersectRectData = {}
    ReturnIntersectRectData.IsIntersect = false

    local distance = math.MaxNumber

    local SelectRect
    for i = 1, #rects do
        local IntersectRectData = self:IsIntersectRect(rects[i])
        if IntersectRectData.IsIntersect then
            local dis = Vector.distance(self.orig, IntersectRectData.IntersectPoint)
            if distance > dis then
                distance = dis

                ReturnIntersectRectData.IsIntersect = true
                ReturnIntersectRectData.IntersectPoint = IntersectRectData.IntersectPoint
                
                ReturnIntersectRectData.SelectRect = rects[i]
                ReturnIntersectRectData.Selectline = IntersectRectData.Selectline
            end
        end
    end

    if ReturnIntersectRectData.IsIntersect == true then
        ReturnIntersectRectData.ReflectRay = self:ReflectByLine(ReturnIntersectRectData.Selectline, ReturnIntersectRectData.IntersectPoint)
    end
    
    return ReturnIntersectRectData
end

function Ray2D:IsintersectLine(line)
    local IntersectLineData = {}
    local v1 = Vector.new(line.x1, line.y1)
    local v2 = Vector.new(line.x2, line.y2)
    
    local dv1 = v1 - self.orig
    local dv2 = v2 - self.orig

    dv1:normalize()
    dv2:normalize()

    local dot = Vector.dot(dv1, dv2)

    local dot1 = Vector.dot(dv1, self.dir)
    local dot2 = Vector.dot(dv2, self.dir)

    IntersectLineData.IsIntersect = dot1 > dot and dot2 > dot
    if not IntersectLineData.IsIntersect then
        return IntersectLineData
    end

    local k, c = 0, 0
    local xx, yy
    local k1, c1

    if self.dir.x == 0 then
        k1 = 0
        xx = self.orig.x

    else
        k1 = self.dir.y / self.dir.x
        c1 = self.orig.y - self.orig.x * k1

        k = k1
        c = c1
    end


    local dir2 = (v2 - v1):normalize()

    local k2, c2
    
    if dir2.x == 0 then
        k2 = 0
        xx = v1.x

    else
        k2 = dir2.y / dir2.x
        c2 = v1.y - v1.x * k2

        k = k2
        c = c2
    end

    if self.dir.x ~= 0 and dir2.x ~= 0 then
        xx = (c1 - c2) / (k2 - k1)
    end

    yy = k * xx + c

    IntersectLineData.IntersectPoint = Vector.new(xx, yy)
    return IntersectLineData
end

function Ray2D:draw()
    Render.RenderObject(self);
end