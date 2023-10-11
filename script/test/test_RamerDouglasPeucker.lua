
math.randomseed(os.time()%10000)

local bz2 = nil

local Rects = {}

local DebugLines = {}

local OptRamerDouglasPeucker = function()
    DebugLines = {}
    local NewPoint = RamerDouglasPeucker.Process2D(bz2.DebugPoints)
    for i = 1, #NewPoint - 1 do
        local line = Line.new(NewPoint[i], NewPoint[i + 1])
        line:setColor(0, 255, 255)
        DebugLines[#DebugLines + 1] = line
    end
end

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
    
    bz2 = BezierCurve.new(P1, P2, P3, P4)

    for i = 1, #Rects do
        Rects[i]:setColor(255,0,0)

        Rects[i]:SetMouseEventEable(true)

        Rects[i].MouseDownEvent = function(rect, x, y)
            rect._IsSelect = true
        end

        Rects[i].MouseMoveEvent = function(rect, x, y)
            rect.x = x - rw * 0.5
            rect.y = y - rw * 0.5

            bz2.P3.x = x
            bz2.P3.y = y

            bz2:GenerateDebugLines()

            OptRamerDouglasPeucker()
        end

        Rects[i].MouseUpEvent = function(rect, x, y)
            rect._IsSelect = false
        end
    end

    OptRamerDouglasPeucker();
end

GenerateData()

-- DelaunayTriangles[#DelaunayTriangles + 1] = Triangle2D.new(Vector.new(2560 , 0), Vector.new(1232, 1055), Vector.new(1133, 515))
-- DelaunayTriangles[#DelaunayTriangles + 1] = Triangle2D.new(Vector.new(0, 0), Vector.new(1232, 1055), Vector.new(1133, 515))

-- local edge = DelaunayTriangles[1]:FindOneEdge(DelaunayTriangles[2])
-- edge:Log("test")

local SelectIndex = 1
local SelectName = "BezierCurve"
app.render(function(dt)
    if SelectIndex == 1 then
        bz2:draw()
    elseif SelectIndex == 2 then
        for i = 1, #DebugLines do
            DebugLines[i]:draw()
        end
    end

    for i = 1, #Rects do
        Rects[i]:draw()

        love.graphics.print( "Index: " .. tostring(i), Rects[i].x, Rects[i].y - 20)
    end
    love.graphics.print( "Press Key Z.  Change SelecteIndex" ..SelectName .. " "..tostring(SelectIndex) .. " ThresholdDistance: " .. tostring(RamerDouglasPeucker.ThresholdDistance) .. " bz2.DebugPoints & DebugLines" .. tostring(#bz2.DebugPoints) .." & " .. tostring(#DebugLines), 10, 10)
end)

local deletep = nil
app.keypressed(function(key, scancode, isrepeat)
    if key == "space" then
        
        GenerateData()
    elseif key == "z" then
        SelectIndex = SelectIndex + 1
        if SelectIndex > 2 then
            SelectIndex = 1
        end
    elseif key == "up" then
        RamerDouglasPeucker.ThresholdDistance = RamerDouglasPeucker.ThresholdDistance + 1
        OptRamerDouglasPeucker()
    elseif key == "down" then
        RamerDouglasPeucker.ThresholdDistance = RamerDouglasPeucker.ThresholdDistance - 1
        OptRamerDouglasPeucker()
    end
end)

-- app.mousepressed(function(x, y, button, istouch)
--     for i = 1, #DelaunayTriangles do
--         if DelaunayTriangles[i]:CheckPointIn(Vector.new(x, y)) then
--             log('ssssssssss')
--         end
--     end
-- end)

