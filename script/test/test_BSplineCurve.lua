math.randomseed(os.time()%10000)

local bz1 = nil
local bz2 = nil
local hc = nil

local TempPoints = {}
local Rects = {}
local K = 2
local TempObj = nil

local GenerateData = function()
    local width = love.graphics.getPixelWidth()
    local height = love.graphics.getPixelHeight()

    -- local P1 = Vector.new(math.random( 1, width - 1), math.random( 1, height -1))
    -- local P2 = Vector.new(math.random( 1, width - 1), math.random( 1, height -1))
    -- local P3 = Vector.new(math.random( 1, width - 1), math.random( 1, height -1))
    -- local P4 = Vector.new(math.random( 1, width - 1), math.random( 1, height -1))

    local P1 = Vector.new(20, height * 0.75)
    local P2 = Vector.new(width * 0.35, height * 0.25)
    local P3 = Vector.new(width * 0.85, height * 0.25)
    local P4 = Vector.new(width - 10, height * 0.75)

    local rw = 8
    Rects = {}
    Rects[#Rects + 1] = Rect.new(P1.x - rw * 0.5, P1.y - rw * 0.5, rw, rw)
    Rects[#Rects + 1] = Rect.new(P2.x - rw * 0.5, P2.y - rw * 0.5, rw, rw)
    Rects[#Rects + 1] = Rect.new(P3.x - rw * 0.5, P3.y - rw * 0.5, rw, rw)
    Rects[#Rects + 1] = Rect.new(P4.x - rw * 0.5, P4.y - rw * 0.5, rw, rw)
    
    TempPoints = {}
    TempPoints[#TempPoints + 1] = P1
    TempPoints[#TempPoints + 1] = P2
    TempPoints[#TempPoints + 1] = P3
    TempPoints[#TempPoints + 1] = P4

    TempObj = BSplineCurve.new(TempPoints, K)
    TempObj:GenerateDebugLines()
    for i = 1, #Rects do
        Rects[i]:setColor(255,0,0)

        Rects[i]:SetMouseEventEable(true)

        Rects[i].MouseDownEvent = function(rect, x, y)
            rect._IsSelect = true
        end

        Rects[i].MouseMoveEvent = function(rect, x, y)
            rect.x = x - rw * 0.5
            rect.y = y - rw * 0.5
            
        end

        Rects[i].MouseUpEvent = function(rect, x, y)
            rect._IsSelect = false

            TempPoints[i] =  Vector.new(rect.x, rect.y)
            log('bbbb', #TempPoints, TempPoints[1].x, TempPoints[1].y)
            TempObj = BSplineCurve.new(TempPoints, K)
            TempObj:GenerateDebugLines()
        end
    end
end

GenerateData()

-- DelaunayTriangles[#DelaunayTriangles + 1] = Triangle2D.new(Vector.new(2560 , 0), Vector.new(1232, 1055), Vector.new(1133, 515))
-- DelaunayTriangles[#DelaunayTriangles + 1] = Triangle2D.new(Vector.new(0, 0), Vector.new(1232, 1055), Vector.new(1133, 515))

-- local edge = DelaunayTriangles[1]:FindOneEdge(DelaunayTriangles[2])
-- edge:Log("test")

local SelectIndex = 1
local SelectName = "BezierCurve"
app.render(function(dt)
    
    if TempObj then
        TempObj:draw()
    end
    for i = 1, #Rects do
        Rects[i]:draw()

        love.graphics.print( "Index: " .. tostring(i), Rects[i].x, Rects[i].y - 20)
    end
    love.graphics.print( "Press Key Z.  Change SelecteIndex(1 - BezierCurve 3, 2 - BezierCurve 4, 3 - HermiteCurve): " ..SelectName .. " "..tostring(SelectIndex), 10, 10)
end)

local deletep = nil
app.keypressed(function(key, scancode, isrepeat)
    if key == "space" then
        
        GenerateData()
    
    end
end)

-- app.mousepressed(function(x, y, button, istouch)
--     for i = 1, #DelaunayTriangles do
--         if DelaunayTriangles[i]:CheckPointIn(Vector.new(x, y)) then
--             log('ssssssssss')
--         end
--     end
-- end)

