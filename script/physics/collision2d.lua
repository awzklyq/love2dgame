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

local PointsNumber = 5
local OffsetAngle = 45 
Collision2D.CheckMoveCircleAndRect = function(circle, rect, MoveDir, MoveDistance)
    local Points = circle:GetDirectionPoints(MoveDir, OffsetAngle, PointsNumber)
    local distance = nil

    local ReturnIntersectRectData = {}
    ReturnIntersectRectData.IsIntersect = false

    local GetRay = Ray2D.new(Vector.new(), Vector.new())
    for i = 1, PointsNumber do
        TempRay.orig.x = Points[i].x
        TempRay.orig.y = Points[i].y

        TempRay.dir = (Points[i] - MoveDir):normalize()

        local IntersectRectData = TempRay:IsIntersectRect(rect)

        if IntersectRectData.IsIntersect then
            local dis = Vector.distance(TempRay.orig, IntersectRectData.IntersectPoint)
            if MoveDistance >= dis then
                if not distance or distance > dis then
                    distance = dis

                    ReturnIntersectRectData.IsIntersect = true
                    ReturnIntersectRectData.IntersectPoint = IntersectRectData.IntersectPoint
                    
                    ReturnIntersectRectData.SelectRect = rect
                    ReturnIntersectRectData.Selectline = IntersectRectData.Selectline

                    GetRay.orig.x =  TempRay.orig.x 
                    GetRay.orig.y =  TempRay.orig.y 

                    GetRay.dir.x =  TempRay.dir.x 
                    GetRay.dir.y =  TempRay.dir.y 

                end
            end
        end 
    end

    if ReturnIntersectRectData.IsIntersect == true then
        ReturnIntersectRectData.ReflectRay = GetRay:ReflectByLine(ReturnIntersectRectData.Selectline, ReturnIntersectRectData.IntersectPoint)
    end

    return ReturnIntersectRectData
end

