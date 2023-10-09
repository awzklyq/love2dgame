math.randomseed(os.time()%10000)

local Rect1
local Rect2
local rayMian
local Rects = {}
local RectSeleted = {}
local PointSeleted = {}
local RaySeleted = {}
local RMin = 25

local RMax = 50

local Num = 40

local RayNum = 4
local rw = 10

local AddIntersectionData = function(ray)
    local IntersectRectData =  ray:FindNearestPointByRects(Rects)
    if IntersectRectData.IsIntersect then
        RectSeleted[#RectSeleted + 1] = IntersectRectData.SelectRect
        IntersectRectData.SelectRect:SetColor(255,0,0)
        PointSeleted[#PointSeleted + 1] = IntersectRectData.IntersectPoint
        RaySeleted[#RaySeleted + 1] = IntersectRectData.ReflectRay
        IntersectRectData.ReflectRay:SetColor(0,255,0)
        ray.ld = Vector.distance(IntersectRectData.IntersectPoint, ray.orig)
    end

    return IntersectRectData
end


local InitEvent = function(rect)
    rect:SetMouseEventEable(true)

    rect.MouseDownEvent = function(rect, x, y)
        rect._IsSelect = true
    end

    rect.MouseMoveEvent = function(rect, x, y)
        rect.x = x - rw * 0.5
        rect.y = y - rw * 0.5

        rayMian = Ray2D.new(Vector.new(Rect1.x, Rect1.y), Vector.new(Rect2.x - Rect1.x, Rect2.y - Rect1.y ))

        for i = 1, #RectSeleted do
            RectSeleted[i]:SetColor(255,255,255)
           
        end

        RectSeleted = {}
        PointSeleted = {}
        --for i = 1, #Rects do
            -- if rayMian:IsintersectCircle(Rects[i].OutCircle) then
            --     Rects[i].OutCircle:SetColor(255,255,0)
            --     local bIsIntersect, IntersectPoint = rayMian:IsIntersectRect(Rects[i])
            --     if bIsIntersect then
            --         RectSeleted[#RectSeleted + 1] = Rects[i]
            --         PointSeleted[#PointSeleted + 1] = IntersectPoint
            --         Rects[i]:SetColor(255,0,0)
            --     end
            -- else
                --Rects[i].OutCircle:SetColor(255,0, 0)
            -- end
        --end

        RaySeleted = {}
        -- local IntersectRectData =  rayMian:FindNearestPointByRects(Rects)
        -- if IntersectRectData.IsIntersect then
        --     RectSeleted[#RectSeleted + 1] = IntersectRectData.SelectRect
        --     IntersectRectData.SelectRect:SetColor(255,0,0)
        --     PointSeleted[#PointSeleted + 1] = IntersectRectData.IntersectPoint
        --     RaySeleted[#RaySeleted + 1] = IntersectRectData.ReflectRay
        --     IntersectRectData.ReflectRay:SetColor(0,255,0)
        -- end

        local index = 1
        local ray = rayMian
        while index <= RayNum do
            
            local IntersectRectData = AddIntersectionData(ray)

            if not IntersectRectData.IsIntersect then
                break
            end

            ray = IntersectRectData.ReflectRay
            index = index + 1
        end
        
        
    end

    rect.MouseUpEvent = function(rect, x, y)
        rect._IsSelect = false
    end
end

local GenerateFunc = function()
    Rects = {}
    RectSeleted = {}

    local width = love.graphics.getPixelWidth()
    local height = love.graphics.getPixelHeight()

    Rect1 = Rect.new(width * 0.5, height * 0.5, rw, rw)
    Rect1:SetColor(255,0,0)
    Rect2 = Rect.new(width - 50, height - 50, rw, rw)
    Rect2:SetColor(255,0,0)

    rayMian = Ray2D.new(Vector.new(Rect1.x, Rect1.y), Vector.new(Rect2.x - Rect1.x, Rect2.y - Rect1.y ))

    InitEvent(Rect1)
    InitEvent(Rect2)
 
    for i = 1, Num do
        local x = math.random(1, width - 1)
        local y = math.random(1, height - 1)
        local w = math.random(RMin, RMax)
        local h = math.random(RMin, RMax)
        local rect = Rect.new(x, y, w, h)

        if rayMian:IsintersectCircle(rect.OutCircle) then
            rect.OutCircle:SetColor(255,255,0)
        else
            rect.OutCircle:SetColor(255,0, 0)
        end
        
        Rects[#Rects + 1]  = rect
    end
end

GenerateFunc()
app.render(function(dt)
    for i = 1, #Rects do
        Rects[i]:draw()
        Rects[i].OutCircle:draw()
    end


    Rect1:draw()
    Rect2:draw()
    rayMian:draw()

    for i = 1, #RaySeleted do
        RaySeleted[i]:draw()
    end

    for i = 1, #PointSeleted do
        PointSeleted[i]:draw()
    end

end)

local deletep = nil
app.keypressed(function(key, scancode, isrepeat)
    if key == "space" then
        
        GenerateFunc()
    end
end)