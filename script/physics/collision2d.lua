_G.Collision2D = {}
local TempRay = Ray2D.new(Vector.new(), Vector.new())
Collision2D.CheckRectAndRect = function(rect1, rect2)
    if Vector.Distance(rect1.OutCircle.Center, rect2.OutCircle.Center) >=  rect1.OutCircle.r + rect2.OutCircle.r then
        return false
    end

    return rect1:CheckPointInXY(rect2.x, rect2.y) or rect1:CheckPointInXY(rect2.x + rect2.w, rect2.y) or rect1:CheckPointInXY(rect2.x + rect2.w, rect2.y + rect2.h) or rect1:CheckPointInXY(rect2.x, rect2.y + rect2.h)
end

Collision2D.CheckCircleAndCircle = function(c1, c2)
    return Vector.Distance(c1, c2) <=  c1.r + c2.r 
end

Collision2D.CheckMoveCircleAndRect = function(circle, rect, MoveDir)
    TempRay.orig.x = circle.x
    TempRay.orig.y = circle.y

    TempRay.dir.x = dir.x
    TempRay.dir.y = dir.x

    local IntersectRectData = TempRay:IsIntersectRect(rect)

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

