local Logic = dofile('script/demo/ball/demo_ball_logic.lua')
local Size = 40
Logic.Size = Size
local RayNum = 10
local rw = 10

local Common = {}


local AddIntersectionData = function(BallDatas, ray)
    local IntersectRectData =  ray:FindNearestPointByRects(BallDatas.Rects)
    if IntersectRectData.IsIntersect then
        BallDatas.RectSeleted[#BallDatas.RectSeleted + 1] = IntersectRectData.SelectRect
        -- IntersectRectData.SelectRect:SetColor(255,0,0)
        BallDatas.PointSeleted[#BallDatas.PointSeleted + 1] = IntersectRectData.IntersectPoint
        BallDatas.RaySeleted[#BallDatas.RaySeleted + 1] = IntersectRectData.ReflectRay
        -- IntersectRectData.ReflectRay:SetColor(0,255,0)
        ray.ld = Vector.distance(IntersectRectData.IntersectPoint, ray.orig)
    end

    return IntersectRectData
end


local InitEvent = function(BallDatas, rect)
    rect:SetMouseEventEable(true)

    rect.MouseDownEvent = function(rect, x, y)
        rect._IsSelect = true
    end

    rect.MouseMoveEvent = function(rect, x, y)
        rect.x = x - rw * 0.5
        rect.y = y - rw * 0.5

        BallDatas.rayMian = Ray2D.new(Vector.new(BallDatas.Rect1.x, BallDatas.Rect1.y), Vector.new(BallDatas.Rect2.x - BallDatas.Rect1.x, BallDatas.Rect2.y - BallDatas.Rect1.y ))

        -- for i = 1, #BallDatas.RectSeleted do
        --     BallDatas.RectSeleted[i]:SetColor(255,255,255)
        -- end

        BallDatas.RectSeleted = {}
        BallDatas.PointSeleted = {}

        BallDatas.RaySeleted = {}

        local index = 1
        local ray = BallDatas.rayMian
        while index <= RayNum do
            
            local IntersectRectData = AddIntersectionData(BallDatas, ray)

            if not IntersectRectData.IsIntersect then
                break
            end

            ray = IntersectRectData.ReflectRay
            index = index + 1
        end
        
        
    end

    rect.MouseUpEvent = function(rect, x, y)
        rect._IsSelect = false
        if BallDatas.MCE:IsMove() == false then
            local Index = 1
            BallDatas.MCE.ArrviedEvent = function(Circle, Target, Dir)
                Index = Index + 1
                if Index <= #BallDatas.PointSeleted then
                    BallDatas.MCE:SetTarget(BallDatas.PointSeleted[Index])
                else
                    BallDatas.MCE.ErrorDis = 0
                end

                if BallDatas.MCE.ErrorDis ~= 0 then
                    BallDatas.MCE:MoveActive(BallDatas.MCE.ErrorDis)
                end

                Logic.ChangeRoleAndRect(Circle, BallDatas.RectSeleted[Index - 1])
            end

            BallDatas.CircleRole.x = BallDatas.Rect1.x
            BallDatas.CircleRole.y = BallDatas.Rect1.y

            BallDatas.MCE:SetTarget(BallDatas.PointSeleted[Index])
            BallDatas.MCE:Start()

           
        end
    end
end

Common.GenerateRects = function(BallDatas, offset)
    BallDatas.Rects = {}
    BallDatas.RectSeleted = {}
    BallDatas.RectTypes = {}

    local width = love.graphics.getPixelWidth()
    local height = love.graphics.getPixelHeight()

    BallDatas.Rect1 = Rect.new(width * 0.5, height * 0.5, rw, rw)
    BallDatas.Rect1:SetColor(255,0,0)
    BallDatas.Rect2 = Rect.new(width - 50, height - 50, rw, rw)
    BallDatas.Rect2:SetColor(255,0,0)

    BallDatas.rayMian = Ray2D.new(Vector.new(BallDatas.Rect1.x, BallDatas.Rect1.y), Vector.new(BallDatas.Rect2.x - BallDatas.Rect1.x, BallDatas.Rect2.y - BallDatas.Rect1.y ))

    InitEvent(BallDatas, BallDatas.Rect1)
    InitEvent(BallDatas, BallDatas.Rect2)
    BallDatas.CircleRole = Circle.new(20, BallDatas.Rect1.x, BallDatas.Rect1.y)
    BallDatas.CircleRole:SetColor(0,255,0)
    Logic.SetRectType(BallDatas.CircleRole,  BallDatas.RectType[1])

    BallDatas.MCE = MotionCircleEntity.new(BallDatas.CircleRole, BallDatas.VE)

    BallDatas.MCE.StopEvent = function()
        Logic.CheckAndRemove(BallDatas)
    end
    
    if not offset then
        offset = 3
    end
    local xn = math.ceil(height / Size) - 1
    local yn = math.ceil(width / Size) - 1
    for i = 1, xn do
        BallDatas.RectTypes[i] = {}
        for j = 1, yn do
            local Need = false
            if (i <= offset or i >=  xn - offset) or (j <= offset or j >=  yn -offset) then
                Need = true
            end

            BallDatas.RectTypes[i][j] = nil
            if Need then
                local rect = Rect.new( j * Size, i * Size, Size, Size)
                rect.i = i
                rect.j = j
                local rn = math.clamp(math.random(1.001, 5.9), 1, 5)
                local index = math.floor(rn)
                Logic.SetRectType(rect,  BallDatas.RectType[index])
                BallDatas.Rects[#BallDatas.Rects + 1] = rect
                BallDatas.RectTypes[i][j] = rect
            end
            
        end
    end

    for i = 1, #BallDatas.Rects do
        local rect =  BallDatas.Rects[i]
        local LeftJJ, RightJJ, RCount = Logic.CheckRow(BallDatas, rect) 
        local LeftII, LeftII, CCount = Logic.CheckColumn(BallDatas, rect) 
        while RCount >=3 or CCount >= 3 do
            rect.RectType = BallDatas.RectType[rect.RectType.Type % #BallDatas.RectType + 1]
            -- log('cccccccccc', i, rect.RectType.Type )
            Logic.SetRectType(rect,  BallDatas.RectType[rect.RectType.Type % #BallDatas.RectType + 1])
            LeftJJ, RightJJ, RCount = Logic.CheckRow(BallDatas, rect) 
            LeftII, LeftII, CCount = Logic.CheckColumn(BallDatas, rect) 
        end
    end
end

return Common