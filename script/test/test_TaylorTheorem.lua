local X = - 1/10
--local a = 0
log(math.exp(X))

-- When X = 0, so a = 0, math.exp(a) = 1
-- Taylor series: f(x) = math.exp(x), f(x)' = math.exp(x)

--Taylor series
function  Func1(x)
    return 1 + x + x * x / 2 + x * x * x / 6
end

--Taylor Theorem， 多了N介余项
function  Func2(x, c)
    return 1 + x + x * x / 2 + c * x * x * x / 6
end

local f1 = math.exp(X)* 1000 - Func1(X) * 1000
local f2 = math.exp(X)* 1000 - Func2(X, math.exp(X * 0.5)) * 1000

log(math.abs(f1) < math.abs(f2) and "f1 < f2" or "f1 > f2")
