FileManager.addAllPath("assert")
math.randomseed(os.time()%10000)
local font = Font.new"FZBaiZDZ113JW.TTF"
font:Use()

local OW = 500
local OH = 500
local R1 = Rect.new(1, 1, OW, OH, "line")

local Area = OW * OH

local SUBW = 100
local SUBh = 100
local startx = 100
local starty = 100
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

local step = 15
local GR = 0
function MatchRandom()
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
    log("aaa cha zhi", math.abs(SUBArea / Area - GR))
    log("aaa bi li zhi: ",  GR, SUBArea / Area)
    log("aaa mian ji zhi: ", Area * GR, SUBArea)
    log()
end

local QudiXULie = function (e, base)
    local C = base
    local Total = 0
    local Nums = {}
    while(e > C) do
        --C = C * 10
        Nums[#Nums + 1] = e % C

        e = (e - Nums[#Nums]) / base
    end

    Nums[#Nums + 1] = e % C

    local Result = 0
    local Di = 1 / math.pow(base, #Nums)
    for i = #Nums, 1, -1 do
        Result = Result + Di * Nums[i]
        Di = Di * base
    end

    return Result
end
-----Van der Corput
function MatchRandom2()
    local total = 0
    MatchRects = {}
    local SqrtSetp, _ = math.modf(math.sqrt(step))
    for i= 1, SqrtSetp * 2, 2 do
        for j = 1, SqrtSetp * 2, 2 do
            local xi = QudiXULie(i, 10) * OW
            local yi = QudiXULie(j, 10) * OH
            MatchRects[#MatchRects + 1] = Rect.new(xi - 1,  yi -1, 2, 2)
            MatchRects[#MatchRects]:setColor(255,0,0,255)
            if xi >= startx and xi <= SUBW + startx and yi >= starty and yi <= starty + SUBh then
                total = total + 1
            end
        end
    end

    GR = total / step
    log("bbb cha zhi", math.abs(SUBArea / Area - GR))
    log("bbb  bi li zhi: ",  GR, SUBArea / Area)
    log("bbb mian ji zhi: ", Area * GR, SUBArea)
    log()
end

-- 2, 3, 5, 7, 11,
-- 13, 17, 19, 23,
-- 29, 31, 37, 41,
-- 43, 47, 53, 59,
-- 61, 67, 71, 73 
-----Halton序列
function MatchRandom3()
    local total = 0
    MatchRects = {}
    local SqrtSetp, _ = math.modf(math.sqrt(step))
    for i= 1, step do
        local xi = QudiXULie(i, 2) * OW
        local yi = QudiXULie(i, 3) * OH
        MatchRects[#MatchRects + 1] = Rect.new(xi - 1,  yi -1, 2, 2)
        MatchRects[#MatchRects]:setColor(255,0,0,255)
        if xi >= startx and xi <= SUBW + startx and yi >= starty and yi <= starty + SUBh then
            total = total + 1
        end
    end

    GR = total / step
    log("ccc cha zhi", math.abs(SUBArea / Area - GR))
    log("ccc  bi li zhi: ",  GR, SUBArea / Area)
    log("ccc mian ji zhi: ", Area * GR, SUBArea)
    log()
end

local Hammersley = function(dimension, index, numSamples)
    if dimension == 0 then
        return index / numSamples;
    else
        return QudiXULie(index, 2);
    end
end

--Hammersley 序列
function MatchRandom4()
    local total = 0
    MatchRects = {}
    for i= 1, step do
        local xi = Hammersley(0, i, step) * OW
        local yi = Hammersley(1, i, step) * OH
        MatchRects[#MatchRects + 1] = Rect.new(xi - 1,  yi -1, 2, 2)
        MatchRects[#MatchRects]:setColor(255,0,0,255)
        if xi >= startx and xi <= SUBW + startx and yi >= starty and yi <= starty + SUBh then
            total = total + 1
        end
    end

    GR = total / step
    log("ddd cha zhi", math.abs(SUBArea / Area - GR))
    log("ddd  bi li zhi: ",  GR, SUBArea / Area)
    log("ddd mian ji zhi: ", Area * GR, SUBArea)
    log()
end

app.keypressed(function(key, scancode, isrepeat)
    if key == "q" then
        MatchRandom()
    elseif key == "w" then
        MatchRandom2()
    elseif key == "e" then
        MatchRandom3()
    elseif key == "r" then
        MatchRandom4()
    elseif key == "a" then
        step = step + 100
        log("step", step)
    elseif key == "z" then
        step = step - 100
        log("step", step)
    end
end)