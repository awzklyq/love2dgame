
local num = 7
local angle = 25
local PS = {} -- circle:GetDirectionPoints(Vector.new(1,1), 25, 5)
local Rects = {}

local CollisionRects = {}
local RectNum = 1

local SelectRect = Rect.new(100, 100, 10, 10)
SelectRect:SetColor(0,0,255, 255)
SelectRect:SetMouseEventEable(true)

local CheckDis = 1000
local GenerateData 
local CreateCircle = function(...)
    local cc = Circle.new(...)
    cc:SetMouseEventEable(true)
    
    cc.MouseDownEvent = function(c, x, y)
        c.sx = x
        c.sy = y
    end
    cc.MouseMoveEvent = function(c, x, y)
        if c.sx == nil or c.sy == nil then return end
        c.x = c.x + (x - c.sx)
        c.y = c.y + (y - c.sy)

        c.sx = x
        c.sy = y
        local dir = Vector.new(SelectRect.x - c.x, SelectRect.y - c.y)
        GenerateData(dir)
        ReturnIntersectRectData = Collision2D.CheckMoveCircleAndRects(c, CollisionRects, dir, CheckDis)
        if ReturnIntersectRectData.IsIntersect then
            log("ReturnIntersectRectData.IsIntersect", ReturnIntersectRectData.MoveDistance, CheckDis)
        end
    end
    cc.MouseUpEvent = function(c, x, y)
        c.sx = nil
        c.sy = nil
    end

    return cc
end

local DebugRay = {}
local circle = CreateCircle(100,300,300)
GenerateData = function(dir)

    local w = RenderSet.screenwidth
    local h = RenderSet.screenheight
    -- circle = CreateCircle(80, w * 0.5,h * 0.5)
    PS = circle:GetDirectionPoints(dir, angle, num)

    Rects = {}
    DebugRay = {}
    for i = 1, #PS do
        local rect = Rect.new(PS[i].x - 4, PS[i].y - 4, 8, 8)
        rect:SetColor(255,0,0)
        Rects[#Rects + 1] = rect
        
        local dr =  Ray2D.new(PS[i], dir)
        dr.ld = CheckDis
        dr:SetColor(255,255,0)
        DebugRay[#DebugRay + 1] = dr
    end
end

local GenerateCollisionRects = function()
    CollisionRects = {}
    local w = RenderSet.screenwidth
    local h = RenderSet.screenheight
    local size = 50
    for i = 1, RectNum do
        local x = math.random(size, w - size)
        local y = math.random(size, h - size)
        local rect = Rect.new( x, y, size, size)
        CollisionRects[#CollisionRects + 1] = rect
    end
end

GenerateCollisionRects()

local ReturnIntersectRectData = {}
ReturnIntersectRectData.IsIntersect = false
SelectRect.MouseMoveEvent = function(rect, x, y)
    rect.x = x - rect.w * 0.5
    rect.y = y - rect.h * 0.5
    local dir = Vector.new(rect.x - circle.x, rect.y - circle.y)
    GenerateData(dir)
    ReturnIntersectRectData = Collision2D.CheckMoveCircleAndRects(circle, CollisionRects, dir, CheckDis)
end


GenerateData(Vector.new(-1,1))
local IsRenderRects = true
app.render(function(dt)
    circle:draw()

    if IsRenderRects then
        for i = 1, #Rects do
            Rects[i]:draw()
        end
    end

    for i = 1, #CollisionRects do
        CollisionRects[i]:draw()
    end

    if ReturnIntersectRectData.IsIntersect and ReturnIntersectRectData.ReflectRay then
        ReturnIntersectRectData.ReflectRay:draw()
        ReturnIntersectRectData.DebugLine:draw()
    end

    for i = 1, #DebugRay do
        DebugRay[i]:draw()
    end

    SelectRect:draw()

end)

app.resizeWindow(function(w, h)
    GenerateData(Vector.new(-1,1))
end)

local scrollbar = UI.ScrollBar.new( 'Collision Rects', 10, 10, 200, 40, 1, 20, 1)
scrollbar.Value = RectNum
scrollbar.ChangeEvent = function(v)
    RectNum = v
    GenerateCollisionRects()
end

local scrollbar2 = UI.ScrollBar.new( 'CheckDis', 220, 10, 200, 40, 0.05, 200, 0.05)
scrollbar2.Value = CheckDis
scrollbar2.ChangeEvent = function(v)
    CheckDis = v
    local dir = Vector.new(SelectRect.x - circle.x, SelectRect.y - circle.y)
    GenerateData(dir)
    ReturnIntersectRectData = Collision2D.CheckMoveCircleAndRects(circle, CollisionRects, dir, CheckDis)
    if ReturnIntersectRectData.IsIntersect then
        log("ReturnIntersectRectData.IsIntersect", ReturnIntersectRectData.MoveDistance, CheckDis)
    end
end

local checkb = UI.CheckBox.new( 440, 10, 20, 20, "IsRenderRects" )
checkb.IsSelect = IsRenderRects
checkb.ChangeEvent = function(Enable)
    IsRenderRects = Enable
end

