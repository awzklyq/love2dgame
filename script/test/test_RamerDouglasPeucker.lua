
math.randomseed(os.time()%10000)

local bz2 = nil
local bz1 = nil
local Rects = {}

local MaxV = 2000

local MaxT = 3

local MaxX
local MinX

local MaxY
local MinY

local P1, P2, P3, P4, P5

local DebugLines = {}
local DebugPoints = {}
local OptRamerDouglasPeucker = function()
    DebugLines = {}
    DebugPoints = {}

    local NewPoint = RamerDouglasPeucker.Process2D(bz1.DebugPoints)
    for i = 1, #NewPoint - 1 do
        local line = Line.new(NewPoint[i], NewPoint[i + 1])
        line:setColor(0, 255, 255)
        DebugLines[#DebugLines + 1] = line
        DebugPoints[#DebugPoints + 1] = NewPoint[i]
    end

    --DebugPoints[#DebugPoints + 1] = NewPoint[#NewPoint]

    NewPoint = RamerDouglasPeucker.Process2D(bz2.DebugPoints)
    for i = 1, #NewPoint - 1 do
        local line = Line.new(NewPoint[i], NewPoint[i + 1])
        line:setColor(0, 255, 255)
        DebugLines[#DebugLines + 1] = line

        DebugPoints[#DebugPoints + 1] = NewPoint[i]
    end

    DebugPoints[#DebugPoints + 1] = NewPoint[#NewPoint]

    MaxX = DebugPoints[1].x
    MinX = DebugPoints[1].x
    MaxY = DebugPoints[1].y
    MinY = DebugPoints[1].y
    for i = 1, #DebugPoints do
        MaxX = math.max(MaxX, DebugPoints[i].x)
        MinX = math.min(MinX, DebugPoints[i].x)

        MaxY = math.max(MaxY, DebugPoints[i].y)
        MinY = math.min(MinY, DebugPoints[i].y)
    end
    
end

local GenerateData = function(IsReset)
    local width = love.graphics.getPixelWidth()
    local height = love.graphics.getPixelHeight()

    -- local P1 = Vector.new(math.random( 1, width - 1), math.random( 1, height -1))
    -- local P2 = Vector.new(math.random( 1, width - 1), math.random( 1, height -1))
    -- local P3 = Vector.new(math.random( 1, width - 1), math.random( 1, height -1))
    -- local P4 = Vector.new(math.random( 1, width - 1), math.random( 1, height -1))

    log('aaaaaaaaaaa', lovefile.DefaultForder .. "test_RamerDouglasPeucker_test.lua")
    local isexists =  true--lovefile.exists(lovefile.DefaultForder .. "test_RamerDouglasPeucker_test.lua")
    if isexists and not IsReset then
        P1, P2, P3, P4, P5 = dofile(lovefile.DefaultForder .. "test_RamerDouglasPeucker_test.lua")
    else
        P1 = Vector.new(1, height * 0.75)
        P2 = Vector.new(width * 0.2, height * 0.75)
        P3 = Vector.new(width * 0.4, height * 0.75)
        P4 = Vector.new(width * 0.6, height * 0.75)
        P5 = Vector.new(width * 0.9, height * 0.75)
    end
    

    local rw = 8
    Rects = {}
    Rects[#Rects + 1] = Rect.new(P1.x - rw * 0.5, P1.y - rw * 0.5, rw, rw)
    Rects[#Rects + 1] = Rect.new(P2.x - rw * 0.5, P2.y - rw * 0.5, rw, rw)
    Rects[#Rects + 1] = Rect.new(P3.x - rw * 0.5, P3.y - rw * 0.5, rw, rw)
    Rects[#Rects + 1] = Rect.new(P4.x - rw * 0.5, P4.y - rw * 0.5, rw, rw)
    Rects[#Rects + 1] = Rect.new(P5.x - rw * 0.5, P5.y - rw * 0.5, rw, rw)

    Rects[1].P = P1
    Rects[2].P = P2
    Rects[3].P = P3
    Rects[4].P = P4
    Rects[5].P = P5
    
    bz1 = BezierCurve.new(P1, P2, P3)
    bz2 = BezierCurve.new(P3, P4, P5)
    for i = 1, #Rects do
        Rects[i]:setColor(255,0,0)

        Rects[i]:SetMouseEventEable(true)

        Rects[i].MouseDownEvent = function(rect, x, y)
            rect._IsSelect = true
        end

        Rects[i].MouseMoveEvent = function(rect, x, y)
            rect.x = x - rw * 0.5
            rect.y = y - rw * 0.5

            rect.P.x = x
            rect.P.y = y

            bz2:GenerateDebugLines()
            bz1:GenerateDebugLines()
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
        bz1:draw()
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
    love.graphics.print( "Press Key Z.  Change SelecteIndex" ..SelectName .. " "..tostring(SelectIndex) .. " ThresholdDistance: " .. tostring(RamerDouglasPeucker.ThresholdDistance) .. " bz2.DebugPoints & DebugLines" .. tostring(#bz2.DebugPoints + #bz2.DebugPoints) .." & " .. tostring(#DebugLines + 1), 10, 10)
end)

local deletep = nil
app.keypressed(function(key, scancode, isrepeat)
    if key == "space" then
        
        GenerateData(true)
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
    elseif key == "a" then
        -- test_RamerDouglasPeucker_test

        local str = ""

        str = str .. 'local P1 = Vector.new(' .. tostring(P1.x) .. ', ' .. tostring(P1.y) .. ') \n'
        str = str .. 'local P2 = Vector.new(' .. tostring(P2.x) .. ', ' .. tostring(P2.y) .. ') \n'
        str = str .. 'local P3 = Vector.new(' .. tostring(P3.x) .. ', ' .. tostring(P3.y) .. ') \n'
        str = str .. 'local P4 = Vector.new(' .. tostring(P4.x) .. ', ' .. tostring(P4.y) .. ') \n'
        str = str .. 'local P5 = Vector.new(' .. tostring(P5.x) .. ', ' .. tostring(P5.y) .. ') \n'
        str = str .. 'return P1, P2, P3, P4, P5 \n'

        lovefile.write('test_RamerDouglasPeucker_test.lua', str)

        local xx = MaxX - MinX
        local yy = MaxY - MinY
        for i = 1, #DebugPoints do
            local t = ((DebugPoints[i].x - MinX) / xx) * MaxT
            local v = ((DebugPoints[i].y - MinY) / yy) * MaxV

            log("VE:AddTimeAndDistance(",t, ',', MaxV - v,")")
        end
    end
end)

-- app.mousepressed(function(x, y, button, istouch)
--     for i = 1, #DelaunayTriangles do
--         if DelaunayTriangles[i]:CheckPointIn(Vector.new(x, y)) then
--             log('ssssssssss')
--         end
--     end
-- end)

