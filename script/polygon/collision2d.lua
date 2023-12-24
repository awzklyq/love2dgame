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

local PointsNumber = 7
local OffsetAngle = 25 
Collision2D.CheckMoveCircleAndRect = function(circle, rect, MoveDir, MoveDistance)
    local ReturnIntersectRectData = {}
    ReturnIntersectRectData.IsIntersect = false

    local CircleToRectOutCircleDis = Vector.distance(rect.OutCircle, circle)
    if rect.OutCircle.r + circle.r + MoveDistance < CircleToRectOutCircleDis then
        return ReturnIntersectRectData
    end

    MoveDir:normalize()
    TempRay.dir = MoveDir
    local Points = circle:GetDirectionPoints(MoveDir, OffsetAngle, PointsNumber)
    local distance = nil

    local debugi = 0
    local GetRay = Ray2D.new(Vector.new(), Vector.new())
    for i = 1, PointsNumber do
        TempRay.orig.x = Points[i].x
        TempRay.orig.y = Points[i].y

        local IntersectRectData = TempRay:IsIntersectRect(rect)

        if IntersectRectData.IsIntersect then
            local dis = Vector.distance(TempRay.orig, IntersectRectData.IntersectPoint)
            if MoveDistance >= dis then
                if not distance or distance > dis then
                    distance = dis
                    debugi = i
                    ReturnIntersectRectData.IsIntersect = true
                    ReturnIntersectRectData.IntersectPoint = IntersectRectData.IntersectPoint
                    
                    ReturnIntersectRectData.DebugLine = Line.new(TempRay.orig.x, TempRay.orig.y, IntersectRectData.IntersectPoint.x, IntersectRectData.IntersectPoint.y)
                    ReturnIntersectRectData.SelectRect = rect
                    ReturnIntersectRectData.Selectline = IntersectRectData.Selectline
                    ReturnIntersectRectData.MoveDistance = dis
                    ReturnIntersectRectData.ErrorDis = math.max(MoveDistance - dis, 0)
                    GetRay.orig.x =  TempRay.orig.x 
                    GetRay.orig.y =  TempRay.orig.y 

                    GetRay.dir.x =  TempRay.dir.x 
                    GetRay.dir.y =  TempRay.dir.y
                end
            end
        end 
    end

    if ReturnIntersectRectData.IsIntersect == true then
        -- log('cccccccccccccccccc', ReturnIntersectRectData.MoveDistance, MoveDistance, ReturnIntersectRectData.SelectRect, debugi )
        ReturnIntersectRectData.ReflectRay = GetRay:ReflectByLine(ReturnIntersectRectData.Selectline, ReturnIntersectRectData.IntersectPoint)
    end

    return ReturnIntersectRectData
end

Collision2D.CheckMoveCircleAndRects = function(circle, rects, MoveDir, MoveDistance)
    local ReturnIntersectRectData = {}
    ReturnIntersectRectData.IsIntersect = false
    if #rects == 0 then
        return ReturnIntersectRectData
    elseif #rects == 1 then
        return Collision2D.CheckMoveCircleAndRect(circle, rects[1], MoveDir, MoveDistance)
    end

    -- #Rects > 1
    for i = 1, #rects do
        local TempIntersectRectData = Collision2D.CheckMoveCircleAndRect(circle, rects[i], MoveDir, MoveDistance)
        if TempIntersectRectData and TempIntersectRectData.IsIntersect then
            if ReturnIntersectRectData.IsIntersect == false then
                ReturnIntersectRectData = TempIntersectRectData
            elseif TempIntersectRectData.MoveDistance < ReturnIntersectRectData.MoveDistance then
                ReturnIntersectRectData = TempIntersectRectData
            end
        end
    end

    return ReturnIntersectRectData
end

