
local mat = Matrixs.new(3, 3)
mat:SetValue(1, 1, 4)
mat:SetValue(1, 2, 2)
mat:SetValue(1, 3, -5)

mat:SetValue(2, 1, 6)
mat:SetValue(2, 2, 4)
mat:SetValue(2, 3, -9)

mat:SetValue(3, 1, 5)
mat:SetValue(3, 2, 3)
mat:SetValue(3, 3, -7)

mat:EigenVectors()


-- log()
-- log('--------------------')
-- local F011 = FormulaOperator.NewMul(-3, 'x')
-- local F012 = FormulaOperator.NewMul(2, 'y')
-- local F013 = FormulaOperator.NewAdd(F011, F012)

-- local F021 = FormulaOperator.NewMul(3, 'x')
-- local F022 = FormulaOperator.NewMul(-2, 'y')
-- local F023 = FormulaOperator.NewAdd(F021, F022)
-- -- F013:ConvertParameToLeft('x')
-- log('OutOparator: ', F013:ToString())
-- log('OutOparator: ', F023:ToString())

-- local F = Formula.new()
-- F:AddOperator(F013)
-- F:AddOperator(F023)
-- F:CalculateParameterByElimination()
