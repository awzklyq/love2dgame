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
-- log('aaaaa', FO8:ToString())
-- local FO5 = FO8:MergeParame()
-- if FO5 then 
--     log('ttttt', FO5:ToString())
-- end

-- local ParamesName = FO5:ExtractParamesName()
-- for i = 1, #ParamesName do
--     log('Has Paraame Name: ', i, ParamesName[i])
-- end

-- local OutOparator = FO5:ConvertParameToLeft('x')

-- if OutOparator then
--     log('OutOparator: ', OutOparator:ToString())
-- end


local F011 = FormulaOperator.NewMul(1, 'x')
local F012 = FormulaOperator.NewAdd(F011, 'y')
local F013 = FormulaOperator.NewAdd(-3, F012)

local F021 = FormulaOperator.NewMul(3, 'x')
local F022 = FormulaOperator.NewMul(2, 'y')
local F023 = FormulaOperator.NewSub(F021, F022)
local F024 = FormulaOperator.NewAdd(-4, F023)

-- F013:ConvertParameToLeft('x')
log('OutOparator: ', F024:ToString())
local ss = F024:ConvertParameToLeft('y')
log(ss:ToString())
local F = Formula.new()
F:AddOperator(F013)
F:AddOperator(F024)
F:CalculateParameterByJacobi()
