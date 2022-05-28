FileManager.addAllPath("assert")

math.randomseed(os.time()%10000)

local font = Font.new"FZBaiZDZ113JW.TTF"
font:Use()

local StartPos = Vector.new(10, 10)
local EndPos = Vector.new(100, 100)
local LineTest = Line.new(StartPos.x, StartPos.y, EndPos.x, EndPos.y, 3)


local RS = Vector.new(10, 10)
local RE = Vector.new(100, 100)
local RectTest = Rect.new(RS.x, RS.y, RE.x - RS.x, RE.x - RS.y, "line")
local OutIntersecPoint = Vector.new()
local NeedRender = false

local CheckRect =  Rect.new(RS.x, RS.y, RE.x - RS.x, RE.x - RS.y)
local CheckRectSize = 8

local function CheckLineAndRectCollision()
    if math.CheckLineAndRectCollision(StartPos, EndPos, RS, RE, OutIntersecPoint) then
        LineTest:setColor(0,255,0,255)
        log("ChengGong")
        NeedRender = true

        CheckRect =  Rect.new(OutIntersecPoint.x - CheckRectSize * 0.5, OutIntersecPoint.y - CheckRectSize * 0.5, CheckRectSize, CheckRectSize)
        CheckRect:setColor(255,255,0,255)
    else
        LineTest:setColor(255,0,0,255)
        NeedRender = false
    end
end
local function ResetLineAndRect()

    StartPos.x = 	math.random(1, 1000)
    StartPos.y = 	math.random(1, 1000)

    EndPos.x = 	math.random(100, 1000)
    EndPos.y = 	math.random(100, 1000)

    RS.x = math.random(1, 300)
    RS.y = math.random(1, 300)

    RE.x = 	RS.x + math.random(1, 600)
    RE.y = 	RS.y + math.random(1, 600)

    -- StartPos = Vector.new(206  ,   637)

    -- EndPos = Vector.new( 597   ,  182)

    -- RS = Vector.new(240  ,   129) 
    -- RE = Vector.new( 740     ,709)

    LineTest = Line.new(StartPos.x, StartPos.y, EndPos.x, EndPos.y, 3)
    RectTest = Rect.new(RS.x, RS.y, RE.x - RS.x, RE.y - RS.y, "line")

    CheckLineAndRectCollision()

end

app.render(function(dt)
    LineTest:draw()
    RectTest:draw()
    if NeedRender then
        CheckRect:draw()
    end
end)


app.keypressed(function(key, scancode, isrepeat)
    if key == "space" then
        ResetLineAndRect()
    elseif key == "a" then
        CheckLineAndRectCollision()
    elseif key == "q" then
        log("StartPos", StartPos.x, StartPos.y)
        log("EndPos", EndPos.x, EndPos.y)
        log("RS", RS.x, RS.y)
        log("RE", RE.x, RE.y)
    end
end)