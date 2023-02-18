math.randomseed(os.time()%10000)

-- log(math.LeftMove(4321, 3) )

-- log(math.RightMove(47321, 5) )


-- local v = Vector3.new(5,9,2)

-- local Morton = math.MortonCode3( v.x );
-- Morton = math.BitOr(Morton, math.LeftMove(math.MortonCode3( v.y ) ,1));
-- Morton = math.BitOr(Morton, math.LeftMove(math.MortonCode3( v.z ) ,2));

-- log(Morton)

-- log(math.ReverseMortonCode3(math.MortonCode3( v.y )))

local Num = 2684351
local tab = {}
local tab1 = {}
local temp
for i = 1, Num do
    tab[#tab + 1], temp = math.modf(math.random() * 100000)
    tab1[#tab] = tab[#tab]
end

local s1 = os.time()
local result = math.RadixSort32(tab, function(key) 
    return key
 end)

 local s2 = os.time()
 
table.sort(tab1, function(a, b)
    return a > b
end)

local s3 = os.time()

log(#tab, #tab1, s1, s2, s3, s2 - s1, s3-s2)