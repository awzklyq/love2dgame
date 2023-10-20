local Num = 5

local TaylorExpansion = function(n)
    local te = 1
    local result = 1 + (n - 1) / 2
    return result
end


for i = 1, Num do
    local dd = math.random(0, 200) * 0.05 
    log('aaaa', dd, math.sqrt(dd), TaylorExpansion(dd))
end