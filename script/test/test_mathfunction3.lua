math.randomseed(os.time()%10000)

-- log(math.LeftMove(4321, 3) )

-- log(math.RightMove(47321, 5) )


-- local v = Vector3.new(5,9,2)

-- local Morton = math.MortonCode3( v.x );
-- Morton = math.BitOr(Morton, math.LeftMove(math.MortonCode3( v.y ) ,1));
-- Morton = math.BitOr(Morton, math.LeftMove(math.MortonCode3( v.z ) ,2));

-- log(Morton)

-- log(math.ReverseMortonCode3(math.MortonCode3( v.y )))

-- local Num = 2684351
-- local tab = {}
-- local tab1 = {}
-- local temp
-- for i = 1, Num do
--     tab[#tab + 1], temp = math.modf(math.random() * 100000)
--     tab1[#tab] = tab[#tab]
-- end

-- local s1 = os.time()
-- local result = math.RadixSort32(tab, function(key) 
--     return key
--  end)

--  local s2 = os.time()
 
-- table.sort(tab1, function(a, b)
--     return a > b
-- end)

-- local s3 = os.time()

-- log(#tab, #tab1, s1, s2, s3, s2 - s1, s3-s2)

local offset = Vector3.new(64, 64, 64)

local min1 = Vector3.new(0,0,0)
local min2 = Vector3.new(211,211,211)
local min3 = Vector3.new(666,666,100)
local b1 = BoundBox.buildFromMinMax(min1, min1 + offset)

local b2 = BoundBox.buildFromMinMax(min2, min2 + offset)

local b3 = BoundBox.buildFromMinMax(min3, min3 + offset)

local tabs = {}

local splitbox = function(box, tabs)
    local halfv = box.center - box.min

    local min = box.min
    local max = box.max
    local c = box.center

    local index = #tabs + 1;
    tabs[#tabs + 1] = { box = BoundBox.buildFromMinMax(min, c), index1 = index, index2 =#tabs + 1}

    tabs[#tabs + 1] = { box = BoundBox.buildFromMinMax(Vector3.new(min.x + halfv.x, min.y, min.z), Vector3.new(c.x + halfv.x, c.y, c.z)), index1 = index, index2 =#tabs + 1}
    tabs[#tabs + 1] = { box = BoundBox.buildFromMinMax(Vector3.new(min.x + halfv.x, min.y  + halfv.y, min.z), Vector3.new(c.x + halfv.x, c.y + halfv.y, c.z)), index1 = index, index2 =#tabs + 1}

    tabs[#tabs + 1] = { box = BoundBox.buildFromMinMax(Vector3.new(min.x, min.y  + halfv.y, min.z), Vector3.new(c.x, c.y + halfv.y, c.z)), index1 = index, index2 =#tabs + 1}

    tabs[#tabs + 1] = { box = BoundBox.buildFromMinMax(c, max), index1= index, index2 =#tabs + 1}

    tabs[#tabs + 1] = { box = BoundBox.buildFromMinMax(Vector3.new(c.x - halfv.x, c.y, c.z), Vector3.new(max.x - halfv.x, max.y, max.z)), index1 = index, index2 =#tabs + 1}
    tabs[#tabs + 1] = { box = BoundBox.buildFromMinMax(Vector3.new(c.x - halfv.x, c.y - halfv.y, c.z), Vector3.new(max.x - halfv.x, max.y - halfv.y, max.z)), index1 = index, index2 =#tabs + 1}

    tabs[#tabs + 1] = { box = BoundBox.buildFromMinMax(Vector3.new(c.x, c.y - halfv.y, c.z), Vector3.new(max.x, max.y  - halfv.y, max.z)), index1 = index, index2 =#tabs + 1}
end

splitbox(b1, tabs)
splitbox(b2, tabs)
splitbox(b3, tabs)

local TN = #tabs
for i = 1, 100 do
    local r1, _ = math.modf(math.random() * TN + 1) % TN + 1
    local r2, _ = math.modf(math.random() * TN + 1) % TN + 1
    if r1 ~= r2 then
        local temp = tabs[r1]
        tabs[r1] = tabs[r2]
        tabs[r2]= temp
    end
end

for i = 1, #tabs do
    log(tabs[i].index1, tabs[i].index2,  tabs[i].box.center:GetMortonCode3())
end

local result = math.RadixSort32(tabs, function(key) 
    return key.box.center:GetMortonCode3()
 end)

 log("ssssssssssssssssssssss")
 for i = 1, #result do
    log(result[i].index1, result[i].index2, result[i].box.center:GetMortonCode3())
end

log("aaaaaaaaaaaaaaaaaaaa")
for i = 1, #result do
   log(result[i].index1, result[i].box.center.x, result[i].box.center.y, result[i].box.center.z)
end