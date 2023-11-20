--https://www.zhihu.com/question/37031188/answer/411760828
local Points = {}

local Rects = {}

local iteration_num = 300

local Ray1



local ProcessLeastSquare = function()
    local GetAVaue = function(b)
        local xyn = 0
        local xn = 0
        local x2n = 0
        for i = 1, #Points do
            xyn = xyn + Points[i].y * Points[i].x
            xn = xn + Points[i].x
            x2n = x2n + Points[i].x * Points[i].x
        end

        return (xyn - xn * b) / x2n
    end

    local GetBVaue = function(a)
        local yn = 0
        local xn = 0
        local x2n = 0
        for i = 1, #Points do
            yn = yn + Points[i].y
            xn = xn + Points[i].x
        end

        return (yn - a * xn) / #Points
    end

    -- local GetBVaue = function(a)
    --     local xyn = 0
    --     local xn = 0
    --     local x2n = 0
    --     for i = 1, #Points do
    --         xyn = xyn + Points[i].y * Points[i].x
    --         xn = xn + Points[i].x
    --         x2n = x2n + Points[i].x * Points[i].x
    --     end

    --     return (xyn - x2n * a) / xn
    -- end

    -- local GetAVaue = function(b)
    --     local yn = 0
    --     local xn = 0
    --     local x2n = 0
    --     for i = 1, #Points do
    --         yn = yn + Points[i].y
    --         xn = xn + Points[i].x
    --     end

    --     return (yn - b  * #Points) / xn
    -- end

    local ra = 0
    local rb = 0
    for i = 1, iteration_num do
        local a = GetAVaue(rb)
        local b = GetBVaue(ra)

        ra = a
        rb = b
    end

    local dir = Vector.new(1, ra)
    dir:normalize()
    Ray1 = Ray2D.new(Vector.new(0, rb), dir, 2)
    Ray1:SetColor(255,0,0)
    return ra, rb
end


local GenerateFunc = function()
    Points = {}

    -- local xof = 10
    -- local yof = 2
    -- Points[#Points + 1] = Vector.new(25 * xof, 110 * yof)
    -- Points[#Points + 1] = Vector.new(27 * xof, 115 * yof)
    -- Points[#Points + 1] = Vector.new(31 * xof, 155 * yof)
    -- Points[#Points + 1] = Vector.new(33 * xof, 160 * yof)
    -- Points[#Points + 1] = Vector.new(35 * xof, 180 * yof)

    local xsize = math.random(100, RenderSet.screenwidth * 0.5)
    local ysize = math.random(100, RenderSet.screenheight * 0.5)

    local xoffset = math.random(1, RenderSet.screenwidth - xsize)
    local yoffset = math.random(1, RenderSet.screenheight - ysize)
    local Number = 20
    for i = 1, Number do
        Points[#Points + 1] = Vector.new(math.random(xoffset, xoffset + xsize), math.random(yoffset, yoffset + ysize))
    end

    Rects = {}
    for i = 1, #Points do
        local rect = Rect.new(Points[i].x - 4, Points[i].y - 4, 8, 8)
        rect:SetColor(255, 0, 0)
        Rects[#Rects + 1] = rect
    end

    
    ProcessLeastSquare()
end

GenerateFunc()

local scrollbar = UI.ScrollBar.new( 'LeastSquare iteration_num', 10, 60, 200, 40, 10, 1000, 10)
scrollbar.Value = iteration_num
scrollbar.ChangeEvent = function(v)
    iteration_num = v
    ProcessLeastSquare()
end

local btn = UI.Button.new( 10, 10, 100, 50, 'Reset', 'btn' )

btn.ClickEvent = function()
    GenerateFunc()
end


local  ra, rb = 7.2, -73

local dir = Vector.new(1, ra)
dir:normalize()
local Ray2 = Ray2D.new(Vector.new(0, rb), dir, 2)

app.render(function(dt)
    for i = 1, #Rects do
        Rects[i]:draw()
    end

    if Ray1 then
        Ray1:draw()
    end

    if Ray2 then
        Ray2:draw()
    end
end)