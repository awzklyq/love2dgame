math.randomseed(os.time()%10000)

local Points = {}
local Rects = {}
local DelaunayTriangles = {}
local DelaunayLines= {}

local c1 = Circle.new(20, 0, 20)
c1:SetColor(255, 0, 0, 255)
c1.mode = 'fill'

local c2 = Circle.new(20, 0, 20)
c2:SetColor(255, 0, 0, 255)
c2.mode = 'fill'

local c3 = Circle.new(20, 0, 20)
c3:SetColor(255, 0, 0, 255)
c3.mode = 'fill'


local Num = 4
local rw = 8

local gsize = 150

local FirstTriangle

local ForceUseOutCircle = false
local GenerateDataLines = function()
    DelaunayLines = {}

    local Edge2Ds = {}

    local IsInEdge2Ds = function(edge)
        for i = 1, #Edge2Ds do
            if Edge2Ds[i] == edge then
                return true
            end
        end

        return false
    end

    local AddTriToEdge = function(edge, tri)

        local Result = nil
        for i = 1, #Edge2Ds do
            if Edge2Ds[i] == edge then
                Result = Edge2Ds[i]
            end
        end

        if not Result then
            Result = edge
        end
        
        if not Result.Triangles then
            Result.Triangles = {}
        end

        Result.Triangles[#Result.Triangles + 1] = tri
    end

    for i = 1, #DelaunayTriangles do
        local tri = DelaunayTriangles[i]
        if IsInEdge2Ds(tri.edge1) == false then
            Edge2Ds[#Edge2Ds + 1] = Edge2D.Copy(tri.edge1)
        end

        if IsInEdge2Ds(tri.edge2) == false then
            Edge2Ds[#Edge2Ds + 1] = Edge2D.Copy(tri.edge2)
        end

        if IsInEdge2Ds(tri.edge3) == false then
            Edge2Ds[#Edge2Ds + 1] = Edge2D.Copy(tri.edge3)
        end

        AddTriToEdge(tri.edge1, tri )
        AddTriToEdge(tri.edge2, tri )
        AddTriToEdge(tri.edge3, tri )
    end

    local AddLines = function(line)
        local IsNeed = true
        for i = 1, #DelaunayLines do
            if line:IsEqual(DelaunayLines[i]) then
                IsNeed = false
                break
            end
        end

        if IsNeed then
            DelaunayLines[#DelaunayLines + 1] = line
        end
    end

    for i = 1, #Edge2Ds do
        local edge = Edge2Ds[i]
        if #edge.Triangles == 2 then
          
            local t1 = edge.Triangles[1]
            local t2 = edge.Triangles[2]
            local c1
            if ForceUseOutCircle or t1:CheckPointInXY(t1.OutCircle.x, t1.OutCircle.y) then
                c1 = Vector.new(t1.OutCircle.x, t1.OutCircle.y)
            else
                c1 = (t1.P1 + t1.P2 + t1.P3) / 3
            end

            if ForceUseOutCircle or t2:CheckPointInXY(t2.OutCircle.x, t2.OutCircle.y) then
                c2 = Vector.new(t2.OutCircle.x, t2.OutCircle.y)
                log('sssssssssss')
            else
                c2 = (t2.P1 + t2.P2 + t2.P3) / 3
                log('aaaaaaaaa')
            end

            
            if math.IntersectLine(edge.P1, edge.P2, c1, c2) then
                local el = Line.new(c1.x, c1.y, c2.x, c2.y)
                AddLines(el)
            else
                local c = (edge.P1 + edge.P2) * 0.5
                local l1 = Line.new(c1.x, c1.y, c.x, c.y)
                local l2 = Line.new(c2.x, c2.y, c.x, c.y)
                AddLines(l1)
                AddLines(l2)
            end

            -- local c1 = (t1.P1 + t1.P2 + t1.P3) / 3
            -- local c2 = (t2.P1 + t2.P2 + t2.P3) / 3
            -- local l = Line.new(c1.x, c1.y, c2.x, c2.y)
        else
            _errorAssert(#edge.Triangles == 1, "Edge2Ds error")
        end
    end


end

local GenerateData = function()
    local width = love.graphics.getPixelWidth()
    local height = love.graphics.getPixelHeight()

    local LW = width
    local LH = height
    local v1 = Vector.new(0, -100)
    local v2 = Vector.new(LW, -100)
    local v3 = Vector.new(LW * 0.5, LH + 100)
    

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
    GenerateDataLines()
end

GenerateData()

-- DelaunayTriangles[#DelaunayTriangles + 1] = Triangle2D.new(Vector.new(2560 , 0), Vector.new(1232, 1055), Vector.new(1133, 515))
-- DelaunayTriangles[#DelaunayTriangles + 1] = Triangle2D.new(Vector.new(0, 0), Vector.new(1232, 1055), Vector.new(1133, 515))

-- local edge = DelaunayTriangles[1]:FindOneEdge(DelaunayTriangles[2])
-- edge:Log("test")

local SelectIndex = 1
local IsDrawOutCircle= false
local IsDrawPointCircle= false
local IsDrawDelaunayTriangles = true
app.render(function(dt)
    for i = 1, #Rects do
        Rects[i]:draw()
    end

    if IsDrawDelaunayTriangles then
        for i = 1, #DelaunayTriangles do
            DelaunayTriangles[i]:draw()
        end
    else
        for i = 1, #DelaunayLines do
            DelaunayLines[i]:draw()
        end
    end


    if IsDrawOutCircle and SelectIndex <= #DelaunayTriangles then
        DelaunayTriangles[SelectIndex].OutCircle:draw()
    end

    if IsDrawPointCircle and SelectIndex <= #DelaunayTriangles then
        c1:draw()
        c2:draw()
        c3:draw()
    end
end)

local check_DrawOutCircle = UI.CheckBox.new( 10, 10, 20, 20, "DrawOutCircle" )
check_DrawOutCircle.ChangeEvent = function(Enable)
    IsDrawOutCircle = Enable
end

local SelectIndexText = UI.Text.new( "0", 100, 50, 50, 50 )
SelectIndexText:SetNormalColor(255, 255, 255, 255)
SelectIndexText.w = SelectIndexText.ow
SelectIndexText.h = SelectIndexText.oh

local btn = UI.Button.new( 10, 50, 80, 30, 'SelectIndex', 'btn' )
btn.ClickEvent = function()
    if SelectIndex <= #DelaunayTriangles then
        DelaunayTriangles[SelectIndex]:SetColor(255,255,255)
    end

    SelectIndex = SelectIndex + 1
    if SelectIndex > #DelaunayTriangles then
        SelectIndex = 1
    end

    DelaunayTriangles[SelectIndex]:SetColor(255,0,0)

    SelectIndexText.text = 'SelectIndex : ' .. tostring(SelectIndex)
    SelectIndexText.w = SelectIndexText.ow
    SelectIndexText.h = SelectIndexText.oh

    c1.x = DelaunayTriangles[SelectIndex].P1.x
    c1.y = DelaunayTriangles[SelectIndex].P1.y

    c2.x = DelaunayTriangles[SelectIndex].P2.x
    c2.y = DelaunayTriangles[SelectIndex].P2.y

    c3.x = DelaunayTriangles[SelectIndex].P3.x
    c3.y = DelaunayTriangles[SelectIndex].P3.y
end

local btn_log = UI.Button.new( 10, 100, 80, 30, 'Log SelectIndex', 'btn' )
btn_log.ClickEvent = function()
    DelaunayTriangles[SelectIndex]:Log("SelectIndex")
end

local btn_reset = UI.Button.new( 10, 140, 80, 30, 'Reset', 'btn' )
btn_reset.ClickEvent = function()
    GenerateData()
end

local check_DrawPointCircle = UI.CheckBox.new( 10, 180, 20, 20, "DrawPointCircle" )
check_DrawPointCircle.ChangeEvent = function(Enable)
    IsDrawPointCircle = Enable
end

local check_DrawDelaunayTriangles = UI.CheckBox.new( 10, 200, 20, 20, "DrawDelaunayTriangles" )

check_DrawDelaunayTriangles.IsSelect = true
check_DrawDelaunayTriangles.ChangeEvent = function(Enable)
    IsDrawDelaunayTriangles = Enable
end

local check_ForceUseOutCircle = UI.CheckBox.new( 10, 230, 20, 20, "ForceUseOutCircle" )

check_ForceUseOutCircle.IsSelect = ForceUseOutCircle
check_ForceUseOutCircle.ChangeEvent = function(Enable)
    ForceUseOutCircle = Enable
    GenerateDataLines()
end

local deletep = nil
app.keypressed(function(key, scancode, isrepeat)
    if key == "z" then
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
        GenerateDataLines()
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
        GenerateDataLines()
    elseif key == "x" then
        deletep =  Points[#Points]
        table.remove( Points, #Points)
        table.remove( Rects, #Rects)
        DelaunayTriangles = Voronoi.Process(Points, FirstTriangle)
        GenerateDataLines()
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

