FileManager.addAllPath("assert")
math.randomseed(os.time()%10000)

local aixs = Aixs.new(0,0,0, 150)

local font = Font.new"FZBaiZDZ113JW.TTF"
font:Use()



local MatchRects = {}
app.render(function(dt)
    aixs:draw()

    for i = 1, #MatchRects do
        MatchRects[i]:draw()
    end
end)

local length = 100
local GenerateSphereXYZ = function(xx, yy)
    -- local x = math.sin(math.rad(xx))*math.cos(math.rad(yy))
    -- local y = math.cos(math.rad(xx))*math.cos(math.rad(yy))

    local x = math.sin(math.rad(xx))
    local y = math.cos(math.rad(xx))


    local z = math.sin(math.rad(yy))

    local v = Vector3.new(x, y, z)
    v:normalize()

    log(v.x, ',', v.y, ',',v.z)
    return v * length
end

local step = 8
function MatchRandom()
    local total = 0
    MatchRects = {}
    for i= 1, step do
        local xi = math.random() * 360
        local yi = math.random() * 180

        local v = GenerateSphereXYZ(xi, yi)
        local meshline = MeshLine.new(Vector3.new(0 ,0 ,0), v)
        MatchRects[#MatchRects + 1] = meshline
        MatchRects[#MatchRects]:setBaseColor(LColor.new(255,255,0,255))
    end

    log("aaa Lines Numbers", #MatchRects)
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
            local xi = QudiXULie(i, 10) * 360
            local yi = QudiXULie(j, 10) * 180
            local v = GenerateSphereXYZ(xi, yi)
            local meshline = MeshLine.new(Vector3.new(0 ,0 ,0), v)
            MatchRects[#MatchRects + 1] = meshline
            MatchRects[#MatchRects]:setBaseColor(LColor.new(255,255,0,255))
        end
    end

    log("bbb Lines Numbers", #MatchRects)
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
        local xi = QudiXULie(i, 2) * 360
        local yi = QudiXULie(i, 3) * 180
        local v = GenerateSphereXYZ(xi, yi)
        local meshline = MeshLine.new(Vector3.new(0 ,0 ,0), v)
        MatchRects[#MatchRects + 1] = meshline
        MatchRects[#MatchRects]:setBaseColor(LColor.new(255,255,0,255))
    end

    log("ccc Lines Numbers", #MatchRects)
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
        local xi = Hammersley(0, i, step) * 360
        local yi = Hammersley(1, i, step) * 180
        local v = GenerateSphereXYZ(xi, yi)
        
        local meshline = MeshLine.new(Vector3.new(0 ,0 ,0), v)
        MatchRects[#MatchRects + 1] = meshline
        MatchRects[#MatchRects]:setBaseColor(LColor.new(255,255,0,255))
    end

    log("ddd Lines Numbers", #MatchRects)
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
    elseif key == 'space' then
        log(currentCamera3D.eye.x, currentCamera3D.eye.y, currentCamera3D.eye.z)
        log(currentCamera3D.look.x, currentCamera3D.look.y, currentCamera3D.look.z)
    end
end)

currentCamera3D.eye = Vector3.new(-7.4594615326513    ,    322.34970312651 ,328.63626745128)
currentCamera3D.look = Vector3.new( 0   ,    0   ,    -1)