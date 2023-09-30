math.randomseed(os.time()%10000)

local bz1 = nil
local bz2 = nil
local hc = nil

local Rects = {}

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
    
    bz1 = BezierCurve.new(P1, P2, P3)
    bz2 = BezierCurve.new(P1, P2, P3, P4)
    hc = HermiteCurve.new(P1, P4, P2, P3)

    for i = 1, #Rects do
        Rects[i]:setColor(255,0,0)

        Rects[i]:SetMouseEventEable(true)

        Rects[i].MouseDownEvent = function(rect, x, y)
            rect._IsSelect = true
        end

        Rects[i].MouseMoveEvent = function(rect, x, y)
            rect.x = x - rw * 0.5
            rect.y = y - rw * 0.5

            if i == 1 then
                bz1.P1.x = x
                bz1.P1.y = y

                bz2.P1.x = x
                bz2.P1.y = y

                hc.P1.x = x
                hc.P1.y = y
            elseif i == 2 then
                bz1.P2.x = x
                bz1.P2.y = y

                bz2.P2.x = x
                bz2.P2.y = y

                hc.PD1.x = x
                hc.PD1.y = y
            elseif i == 3 then
                bz1.P3.x = x
                bz1.P3.y = y

                bz2.P3.x = x
                bz2.P3.y = y

                hc.PD2.x = x
                hc.PD2.y = y
            elseif i == 4 then
                bz2.P4.x = x
                bz2.P4.y = y

                hc.P2.x = x
                hc.P2.y = y
            end

            bz1:GenerateDebugLines()
            bz2:GenerateDebugLines()
            hc:GenerateDebugLines()
        end

        Rects[i].MouseUpEvent = function(rect, x, y)
            rect._IsSelect = false
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
    if SelectIndex == 1 then
        bz1:draw()
    elseif SelectIndex == 2 then
        bz2:draw()
    elseif SelectIndex == 3 then
        hc:draw()
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
    elseif key == "z" then
        SelectIndex = SelectIndex + 1
        if SelectIndex > 3 then
            SelectIndex = 1
        end
    
        if SelecteIndex == 3 then
            SelectName = "HermiteCurve"
        else
            SelectName = "BezierCurve"
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

