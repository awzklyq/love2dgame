-- FileManager.addAllPath("assert")
math.randomseed(os.time()%10000)

-- (4 -  2*x)  + 3*x + 2 * (2 - 5x )
local FO2 = FormulaOperator.NewMul(5, "x")
local FO3 = FormulaOperator.NewSub(4, FO2)
local FO4 = FormulaOperator.NewMul(6, "x")
local FO9 = FormulaOperator.NewSub(FO3, FO4)

local FO6 = FormulaOperator.NewMul(5, "y")
local FO7 = FormulaOperator.NewSub(2, FO6)
local FO10 = FormulaOperator.NewMul(2, FO7)
local FO8 = FormulaOperator.NewSub(FO9, FO10)
log('aaaaa', FO8:ToString())
local FO5 = FO8:MergeParame()
if FO5 then 
    log('ttttt', FO5:ToString())
end


