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

    local k, c
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