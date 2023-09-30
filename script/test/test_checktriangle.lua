math.randomseed(os.time()%10000)

local tri1
local tri2
local GenerateData = function()
    local width = love.graphics.getPixelWidth()
    local height = love.graphics.getPixelHeight()

    local v1 = Vector.new(math.random( 1, width), math.random( 1, height))
    local v2 = Vector.new(math.random( 1, width), math.random( 1, height))
    local v3 = Vector.new(math.random( 1, width), math.random( 1, height))

    tri1 = Triangle2D.new(v1, v2, v3)

    v1 = Vector.new(math.random( 1, width), math.random( 1, height))
    v2 = Vector.new(math.random( 1, width), math.random( 1, height))
    v3 = Vector.new(math.random( 1, width), math.random( 1, height))

    tri2 = Triangle2D.new(v1, v2, v3)

    local edge1, edge2 = tri1:IntersectTriangleNotSampePoint(tri2)
    if edge1 then
        log("xiang jiao")
        tri1:SetColor(255,0,0)
        tri2:SetColor(255,0,0)
    else
        log("bu xiang jiao")
        tri1:SetColor(255,255,255)
        tri2:SetColor(255,255,255)
    end
end

GenerateData()


app.render(function(dt)
    tri1:draw()
    tri2:draw()
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

