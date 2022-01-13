FileManager.addAllPath("assert")
math.randomseed(os.time()%10000)
local font = Font.new"minijtls.TTF"
font:Use()

local OW = 500
local OH = 500
local R1 = Rect.new(1, 1, OW, OH, "line")

local Area = OW * OH

local SUBW = 100
local SUBh = 100
local startx = 1
local starty = 1
local R2  = Rect.new(startx, starty, SUBW, SUBh, "line")

local SUBArea = SUBW  * SUBh

R2:setColor(255, 255, 0, 255)

local MatchRects = {}
app.render(function(dt)
    R1:draw()

    R2:draw()

    for i = 1, #MatchRects do
        MatchRects[i]:draw()
    end
end)

local step = 1000
local GR = 0
function Match()
    local total = 0
    MatchRects = {}
    for i= 1, step do
        local xi = math.random() * OW
        local yi = math.random() * OH
        MatchRects[#MatchRects + 1] = Rect.new(xi - 1,  yi -1, 2, 2)
        MatchRects[#MatchRects]:setColor(255,0,0,255)
        if xi >= startx and xi <= SUBW + startx and yi >= starty and yi <= starty + SUBh then
            total = total + 1
        end
    end

    GR = total / step
    log("差值", math.abs(SUBArea / Area - GR))
    log(" 比例值: ",  GR, SUBArea / Area)
    log(" 面积值: ", Area * GR, SUBArea)
    log()
end

app.keypressed(function(key, scancode, isrepeat)
    if key == "space" then
        Match()
    elseif key == "a" then
        step = step + 1000
        log("step", step)
    elseif key == "z" then
        step = step - 1000
        log("step", step)
    end
end)