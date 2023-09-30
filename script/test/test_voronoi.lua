math.randomseed(os.time()%10000)

local Points = {}
local Rects = {}
local DelaunayTriangles = {}

local Num = 4
local rw = 8

local gsize = 300

local FirstTriangle

local GenerateData = function()
    local width = love.graphics.getPixelWidth()
    local height = love.graphics.getPixelHeight()

    local LW = width
    local LH = height
    local v1 = Vector.new(0, 0)
    local v2 = Vector.new(LW, 0)
    local v3 = Vector.new(LW * 0.5, LH)
    

    local numw = width / gsize
    local numh = height / gsize
    FirstTriangle = Triangle2D.new(v1, v2, v3)
    Points = {}
    Rects = {}
    for i = 1, numw do
        for j = 1, numh do
            local offsetx = i * gsize
            local offsety = j * gsize
            local v = Vector.new(offsetx + math.random( 0.001, gsize), offsety + math.random( 0.001, gsize))
            if FirstTriangle:CheckPointIn(v) then
                Points[#Points + 1] = v

                local rect = Rect.new(v.x - rw * 0.5, v.y - rw * 0.5, rw, rw)
                rect:setColor(255, 255, 0, 255)
                Rects[#Rects + 1] = rect
            end
        end
    end
    -- for i = 1, Num do
    --     local v = Vector.new(math.random( 1, width), math.random( 1, height))
    --     if FirstTriangle:CheckPointIn(v) then
    --         Points[#Points + 1] = v

    --         local rect = Rect.new(v.x - rw * 0.5, v.y - rw * 0.5, rw, rw)
    --         rect:setColor(255, 255, 0, 255)
    --         Rects[#Rects + 1] = rect
    --     end

    -- end

    DelaunayTriangles = Voronoi.Process(Points, FirstTriangle)
end

GenerateData()

-- DelaunayTriangles[#DelaunayTriangles + 1] = Triangle2D.new(Vector.new(2560 , 0), Vector.new(1232, 1055), Vector.new(1133, 515))
-- DelaunayTriangles[#DelaunayTriangles + 1] = Triangle2D.new(Vector.new(0, 0), Vector.new(1232, 1055), Vector.new(1133, 515))

-- local edge = DelaunayTriangles[1]:FindOneEdge(DelaunayTriangles[2])
-- edge:Log("test")

local SelectIndex = 1
local IsDrawOutCircle= false
app.render(function(dt)
    for i = 1, #Rects do
        Rects[i]:draw()
    end

    for i = 1, #DelaunayTriangles do
        DelaunayTriangles[i]:draw()
    end

    if IsDrawOutCircle then
        DelaunayTriangles[SelectIndex].OutCircle:draw()
    end
end)

local deletep = nil
app.keypressed(function(key, scancode, isrepeat)
    if key == "space" then
        
        DelaunayTriangles[SelectIndex]:SetColor(255,255,255)

        SelectIndex = SelectIndex + 1
        if SelectIndex > #DelaunayTriangles then
            SelectIndex = 1
        end

        DelaunayTriangles[SelectIndex]:SetColor(255,0,0)
    elseif key == "a" then
        IsDrawOutCircle = not IsDrawOutCircle
    elseif key == "z" then
        local width = love.graphics.getPixelWidth()
        local height = love.graphics.getPixelHeight()
        local v = deletep == nil and Vector.new(math.random( 1, width), math.random( 1, height)) or deletep
        if FirstTriangle:CheckPointIn(v) then
            Points[#Points + 1] = v

            local rect = Rect.new(v.x - rw * 0.5, v.y - rw * 0.5, rw, rw)
            rect:setColor(255, 0, 0, 255)
            Rects[#Rects]:setColor(255, 255, 0, 255)
            Rects[#Rects + 1] = rect
            DelaunayTriangles = Voronoi.Process(Points, FirstTriangle)
        end

        deletep = nil
    elseif key == "g" then
        local width = love.graphics.getPixelWidth()
        local height = love.graphics.getPixelHeight()
        local v = deletep == nil and Vector.new(math.random( 1, width), math.random( 1, height)) or deletep
        if FirstTriangle:CheckPointIn(v) then
            Points[#Points + 1] = v

            local rect = Rect.new(v.x - rw * 0.5, v.y - rw * 0.5, rw, rw)
            rect:setColor(255, 0, 0, 255)
            if #Rects > 0 then
                Rects[#Rects]:setColor(255, 255, 0, 255)
               
            end
            Rects[#Rects + 1] = rect
            DelaunayTriangles = Voronoi.AddPoint(v, FirstTriangle)
        end

        deletep = nil
    elseif key == "x" then
        deletep =  Points[#Points]
        table.remove( Points, #Points)
        table.remove( Rects, #Rects)
        DelaunayTriangles = Voronoi.Process(Points, FirstTriangle)
    elseif key == "s" then
        GenerateData()
    elseif key == "d" then
        DelaunayTriangles[SelectIndex]:Log("SelectIndex")
        Voronoi.Test11 = not Voronoi.Test11

    elseif key == "f" then
        for i = 1, #DelaunayTriangles do
            DelaunayTriangles[i]:Log("DelaunayTriangles["..tostring(i)..']')
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

