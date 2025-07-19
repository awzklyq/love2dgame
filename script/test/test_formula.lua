-- -- FileManager.addAllPath("assert")
-- math.randomseed(os.time()%10000)

-- -- (4 -  2*x)  + 3*x + 2 * (2 - 5x )
-- local FO2 = FormulaOperator.NewMul(5, "x")
-- local FO3 = FormulaOperator.NewSub(4, FO2)
-- local FO4 = FormulaOperator.NewMul(6, "x")
-- local FO9 = FormulaOperator.NewSub(FO3, FO4)

-- local FO6 = FormulaOperator.NewMul(5, "y")
-- local FO7 = FormulaOperator.NewSub(2, FO6)
-- local FO10 = FormulaOperator.NewMul(2, FO7)
-- local FO8 = FormulaOperator.NewSub(FO9, FO10)
-- -- log('aaaaa', FO8:ToString())
-- -- local FO5 = FO8:MergeParame()
-- -- if FO5 then 
-- --     log('ttttt', FO5:ToString())
-- -- end

-- -- local ParamesName = FO5:ExtractParamesName()
-- -- for i = 1, #ParamesName do
-- --     log('Has Paraame Name: ', i, ParamesName[i])
-- -- end

-- -- local OutOparator = FO5:ConvertParameToLeft('x')

-- -- if OutOparator then
-- --     log('OutOparator: ', OutOparator:ToString())
-- -- end


-- local F011 = FormulaOperator.NewMul(1, 'x')
-- local F012 = FormulaOperator.NewAdd(F011, 'y')
-- local F013 = FormulaOperator.NewAdd(-3, F012)

-- local F021 = FormulaOperator.NewMul(3, 'x')
-- local F022 = FormulaOperator.NewMul(2, 'y')
-- local F023 = FormulaOperator.NewSub(F021, F022)
-- local F024 = FormulaOperator.NewAdd(-4, F023)

-- -- F013:ConvertParameToLeft('x')
-- log('OutOparator: ', F024:ToString())
-- local ss = F024:ConvertParameToLeft('y')
-- log(ss:ToString())
-- local F = Formula.new()
-- F:AddOperator(F013)
-- F:AddOperator(F024)
-- F:CalculateParameterByElimination()

-- local F11 = FormulaOperator.NewMul(3, "P1")
-- local F12 = FormulaOperator.NewMul(2, "P2")
-- local F13 = FormulaOperator.NewMul(-5, "P3")

-- local F14 = FormulaOperator.NewAdd(F11, F12)
-- local F15 = FormulaOperator.NewAdd(F14, F13)

-- local F21 = FormulaOperator.NewMul(6, "P1")
-- local F22 = FormulaOperator.NewMul(3, "P2")
-- local F23 = FormulaOperator.NewMul(-9, "P3")

-- local F24 = FormulaOperator.NewAdd(F21, F22)
-- local F25 = FormulaOperator.NewAdd(F24, F23)

-- local F31 = FormulaOperator.NewMul(6, "P1")
-- local F32 = FormulaOperator.NewMul(3, "P2")
-- local F33 = FormulaOperator.NewMul(-9, "P3")

-- local F34 = FormulaOperator.NewAdd(F31, F32)
-- local F35 = FormulaOperator.NewAdd(F34, F33)

-- local F = Formula.new()
-- F:AddOperator(F15)
-- F:AddOperator(F25)
-- F:AddOperator(F35)
-- F:CalculateParameterByElimination()

local F01 = FormulaOperator.NewMul(1.3, "P2")
local F02 = FormulaOperator.NewMul(3.3, "P3")

local F03 = FormulaOperator.NewSub(F02, F01)
local F04 = FormulaOperator.NewSub(0, F03)

local F05 = FormulaOperator.NewMul(3, "P3")

local F06 = FormulaOperator.NewSub(F05, F04)
local F07 = FormulaOperator.NewSub(0, F06)

log('aaaaa', F07:ToString())

-- F07:MergeParame()

F07:MergeParame()

log('bbbbbb', F07:ToString())

local OutResult = {}
F07:GetAllParameCoefficient(OutResult)
for i, v in pairs(OutResult) do
    log('aaaaaa', i, #v)
end

F07:MergeSameParameCoefficient(OutResult)
log('cccccccc', F07:ToString())