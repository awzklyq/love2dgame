local CheckFunc1 = function(x1, x2, x3)
    local value = 8 * x1 - 3 * x2 + 2 * x3
    return value == 20
end

local CheckFunc2 = function(x1, x2, x3)
    local value = 4 * x1 + 11 * x2 - x3
    return value == 33
end

local CheckFunc3 = function(x1, x2, x3)
    local value = 6 * x1 + 3 * x2 + 12 * x3
    return value == 36
end

local x1, x2, x3 = 3, 2, 1
if CheckFunc1(x1, x2, x3) and CheckFunc1(x1, x2, x3) and CheckFunc1(x1, x2, x3) then
    -- log('AAAAAAAAAAAAAAAAA', x1, x2, x3)
end

local GetX1 = function(x2k, x3k)
    return (-(-3 * x2k + 2 * x3k) + 20) / 8
end

local GetX2 = function(x1k, x3k)
    return (-(4 * x1k - x3k) + 33) / 11
end

local GetX3 = function(x1k, x2k)
    return (-(6 * x1k + 3 * x2k) + 36) / 12
end

local xk1, xk2, xk3 = 0, 0, 0

local step = 30

--Jacobi
for i = 1, step do
    local xt1 = GetX1(xk2, xk3)
    local xt2 = GetX2(xk1, xk3)
    local xt3 = GetX3(xk1, xk2)

    xk1, xk2, xk3 = xt1, xt2, xt3

    if i % 5 == 0 then
        -- log('Jacobi ', i, xk1, xk2, xk3, x1 - xk1, x2 - xk2, x3 - xk3)
    end
end

log()

xk1, xk2, xk3 = 0, 0, 0
--Gauss-Seide
for i = 1, step do
    local xt1 = GetX1(xk2, xk3)
    local xt2 = GetX2(xt1, xk3)
    local xt3 = GetX3(xt1, xt2)

    xk1, xk2, xk3 = xt1, xt2, xt3

    if i % 5 == 0 then
        -- log('Gauss-Seide ', i, xk1, xk2, xk3, x1 - xk1, x2 - xk2, x3 - xk3)
    end
end

local a = 2
local b = -3
local c = -9

local GetTestFunction1 = function(x)
    return (-c) / (a * x + b)
end

local inx = 0
for i = 1, 20 do
    inx = GetTestFunction1(inx)
    -- log(inx)
end

a = 4
b = 3
c = -19

local GetTestFunction2 = function(x)
    return (-c) / (a * x + b)
end
inx = 0
for i = 1, 50 do
    inx = GetTestFunction2(inx)
    log(inx)
end
