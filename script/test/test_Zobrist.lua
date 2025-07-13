local Test1 = 12345678

local Temp = 1010101
local Test2 = math.BitXor(Test1, Temp)

log('aaaaaaaaaaaaa', Test2)

local Test3 = math.BitXor(Test2, Temp)

log('bbbbbb', Test3)