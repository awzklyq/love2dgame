local Circles = {}
local CircleNum = 10
local num = 5
local angle = 45
local PS = {} -- circle:GetDirectionPoints(Vector.new(1,1), 25, 5)
local Rects = {}
local TargePoint = Rect.new(0,0,1,1)
TargePoint:SetColor(255,0,0)
local GenerateRay

local GenerateCircles = function()
    Circles = {}
    local sw = RenderSet.screenwidth
    local sh = RenderSet.screenheight

    for i = 1, CircleNum do
        local r = math.random(20,100)
        local cx = math.random(r, sw-r)
        local cy = math.random(r, sh-r)

        local circle = Circle.new(r, cx ,cy)
        Circles[#Circles + 1] = circle
    end
end

local SelectRect1 = Rect.new(100, 100, 10, 10)
SelectRect1:SetColor(0,0,255, 255)
SelectRect1:SetMouseEventEable(true)

local ray1 = Vector.new(100,100)

SelectRect1.MouseMoveEvent = function(rect, x, y)
    rect.x = x - rect.w * 0.5
    rect.y = y - rect.h * 0.5

    ray1.x = x
    ray1.y = y
    GenerateRay()
end

local SelectRect2 = Rect.new(200, 200, 10, 10)
SelectRect2:SetColor(255,0,255, 255)
SelectRect2:SetMouseEventEable(true)

local ray2 = Vector.new(200,200)

SelectRect2.MouseMoveEvent = function(rect, x, y)
    rect.x = x - rect.w * 0.5
    rect.y = y - rect.h * 0.5

    ray2.x = x
    ray2.y = y
    GenerateRay()
end

local ray = Ray2D.new(ray2, ray1 - ray2)
ray:SetColor(255,255,0,255)
local ReturnIntersectCircleData
GenerateRay = function()
    ray = Ray2D.new(ray2, ray1 - ray2)
    ray:SetColor(255,255,0,255)
    ReturnIntersectCircleData = ray:FindNearestPointByCircles(Circles)
    if ReturnIntersectCircleData.IsIntersect then
        local p = ReturnIntersectCircleData.IntersectPoint
        TargePoint.x = p.x - 8
        TargePoint.y = p.y - 8
        TargePoint.w = 16
        TargePoint.h = 16
    end
end
app.render(function(dt)

    SelectRect1:draw()
    SelectRect2:draw()

    ray:draw()

    for i = 1, #Circles do
        Circles[i]:draw()
    end

    if ReturnIntersectCircleData and ReturnIntersectCircleData.IsIntersect then
        TargePoint:draw()
    end
end)

GenerateCircles()
local btn = UI.Button.new( 10, 10, 100, 50, 'Reset Circles', 'btn' )

btn:setPressedColor(LColor.new(125, 125, 125))
btn.ClickEvent = function()
    GenerateCircles()
end