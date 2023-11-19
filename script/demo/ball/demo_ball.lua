math.randomseed(os.time()%10000)

local Rect1
local Rect2
local rayMian
local Rects = {}
local RectSeleted = {}
local PointSeleted = {}
local RaySeleted = {}
local VE = MovedEntity.new()

-- VE:AddTimeAndVelocity(2, 4)
-- VE:AddTimeAndVelocity(4, 2)
-- VE:AddTimeAndVelocity(6, 1)
-- VE:AddTimeAndVelocity(10, 5)

VE:AddTimeAndDistance(  0       ,       0       )
VE:AddTimeAndDistance(  0.22213521126761        ,       498.51858037578 )
VE:AddTimeAndDistance(  0.24239049295775        ,       536.848434238   )
VE:AddTimeAndDistance(  0.50638204225352        ,       958.24634655532 )
VE:AddTimeAndDistance(  0.53012535211268        ,       990.14947807933 )
VE:AddTimeAndDistance(  0.83597323943662        ,       1334.4267223382 )
VE:AddTimeAndDistance(  0.86320457746479        ,       1359.903131524  )
VE:AddTimeAndDistance(  1.1804577464789 ,       1607.51565762   )
VE:AddTimeAndDistance(  1.5036496478873 ,       1789.8956158664 )
VE:AddTimeAndDistance(  1.5328732394366 ,       1801.5866388309 )
VE:AddTimeAndDistance(  1.8954665492958 ,       1908.1419624217 )
VE:AddTimeAndDistance(  1.9321690140845 ,       1915.8246346555 )
VE:AddTimeAndDistance(  2.4212112676056 ,       1981.9624217119 )
VE:AddTimeAndDistance(  2.4660158450704 ,       1985.3027139875 )
VE:AddTimeAndDistance(  3       ,       2000    )

VE:Log('VE')

local CircleRole
local MCE 
local Size = 40

local RayNum = 10
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

        RaySeleted = {}

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
        if MCE:IsMove() == false then
            local Index = 1
            MCE.ArrviedEvent = function(Circle, Target, Dir)
                Index = Index + 1
                if Index <= #PointSeleted then
                    MCE:SetTarget(PointSeleted[Index])
                end

                if MCE.ErrorDis ~= 0 then
                    MCE:MoveActive(MCE.ErrorDis)
                end
            end

            CircleRole.x = Rect1.x
            CircleRole.y = Rect1.y

            MCE:SetTarget(PointSeleted[Index])
            MCE:Start()

           
        end
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
    CircleRole = Circle.new(20, Rect1.x, Rect1.y)
    CircleRole:SetColor(0,255,0)

    MCE = MotionCircleEntity.new(CircleRole, VE)

    local xn = math.ceil(width / Size) - 1
    local yn = math.ceil(height / Size) - 1
    for i = 1, xn do
        for j = 1, yn do
            local Need = false
            if i == 1 or i == xn or j == 1 or j == yn then
                Need = true
            else
                local r = math.random(0, 100)
                if r > 60 then
                    Need = true
                end
            end

            if Need then
                local rect = Rect.new(i * Size, j * Size, Size, Size)
                Rects[#Rects + 1] = rect
            end
        end
    end
end

GenerateFunc()
app.render(function(dt)
    for i = 1, #Rects do
        Rects[i]:draw()
        -- Rects[i].OutCircle:draw()
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

    CircleRole:draw()

end)

local deletep = nil
app.keypressed(function(key, scancode, isrepeat)
    if key == "space" then
        
        GenerateFunc()
    end
end)