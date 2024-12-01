-- FileManager.addAllPath("assert")
math.randomseed(os.time()%10000)

--((x + 4) * (x - 2)) / y^2
local FO1 = FormulaOperator.NewAdd(4, "x")
local FO2 = FormulaOperator.NewAdd(-2, "x")
local FO3 = FormulaOperator.NewMul(FO1, FO2)

local FO4 = FormulaOperator.NewPow(2, "y")
local FO5 = FormulaOperator.NewDiv(FO3, FO4)

log(FO5:ToString())
FO5:SetParameValue('x', 5)
FO5:SetParameValue('y', 4)
-- log(FO3:GetParameValue() ,FO5:GetParameValue())

--x^4 + 2x - 7
local FO11 = FormulaOperator.NewPow(4, "x")
local FO21 = FormulaOperator.NewMul(2, "x")
local FO31 = FormulaOperator.NewAdd(FO11, FO21)

local FO41 = FormulaOperator.NewAdd(-7, FO31)

-- FO41:SetParameValue('x', 2)
-- log(FO41:GetParameValue())

-- --4*x^3+2
-- log(FO41:Derivative('x', 3))

-- local FO51 = FO41:Derivative("x")
-- --12*x^2
-- log(FO51:Derivative('x', 3))

-- --24*x^1
-- local FO61 = FO51:Derivative("x")
-- log(FO61:Derivative('x', 4))



