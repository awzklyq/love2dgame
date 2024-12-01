_G.Formula = {}
_G.FormulaOperator = {}

_G.OperatorTyoe = {}
OperatorTyoe.None = 0 
OperatorTyoe.Add = 2
OperatorTyoe.Sub = 3
OperatorTyoe.Mul = 4
OperatorTyoe.Div = 5
OperatorTyoe.Pow = 6

_G.RealTyoe = {}
RealTyoe.Number = 0
RealTyoe.Formula = 1
RealTyoe.Parameter = 2
RealTyoe.FormulaOperator = 3

local metatable_Formula = {}
metatable_Formula.__index = Formula


local metatable_FormulaOperator = {}
metatable_FormulaOperator.__index = FormulaOperator

metatable_FormulaOperator.__concat = function(op1, op2)

end

function FormulaOperator.new(OType, RType, Real, PType, Parame, PName)
    local v = setmetatable({}, metatable_Operator);
    v.OType = OType
    v.RType = RType
    v.Real = Real

    v.PType = PType
    v.Parame = Parame
    v.NextOperator = NextOperator
    v.PName = PName or "" 

    v.renderid = Render.FormulaOperatorId
    return v;
end

function FormulaOperator.Concat(Opt1, Opt2)
    _errorAssert(Opt1.renderid == Render.FormulaOperatorId and Opt2.renderid == Render.FormulaOperatorId, "Operator Concat renderid is Not FormulaOperatorId")

    local v1 = Opt1:GetValue()
    local v2 = Opt2:GetValue()
    local Result
    if Opt1.OType == OperatorTyoe.Add then
        Result = v1 + v2
    elseif Opt1.OType == OperatorTyoe.Sub then
        Result = v1 - v2
    elseif Opt1.OType == OperatorTyoe.Mul then
        Result = v1 * v2
    elseif Opt1.OType == OperatorTyoe.Div then
        Result = v1 / v2
    end


end

function FormulaOperator:GetRealValue()
    local RealValue

    if self.RType == RealTyoe.FormulaOperator then
        RealValue = self.Real:GetParameValue()
    elseif self.RType == RealTyoe.Number then
        RealValue = self.Real
    else
        _errorAssert(false, "Operator GetRealValue PType is not Right")
    end

    return RealValue
end

function FormulaOperator:GetParameValue()
    local ParameValue
    if self.PType == RealTyoe.FormulaOperator then
        ParameValue = self.Parame:GetParameValue()
    elseif self.PType == RealTyoe.Parameter then
        _errorAssert(self.Parame, "Operator GetParameValue PType Parameter is not Value")
        ParameValue = self.Parame
    elseif self.PType == RealTyoe.Number then
        ParameValue = self.Real
    else
        _errorAssert(false, "Operator GetParameValue PType is not Right")
    end

    local RealValue = GetRealValue()

    local Result
    if self.OType == OperatorTyoe.Add then
        Result = RealValue + ParameValue
    elseif self.OType == OperatorTyoe.Sub then
        Result = RealValue - ParameValue
    elseif self.OType == OperatorTyoe.Mul then
        Result = RealValue * ParameValue
    elseif self.OType == OperatorTyoe.Div then
        Result = RealValue / ParameValue
    elseif self.OType == OperatorTyoe.Pow then
        Result = math.pow(ParameValue, RealValue)
    else
        _errorAssert(false, "Operator GetParameValue OType is not Right")
    end

    return Result
end

function FormulaOperator:SetParameValue(PName, PValue)
    if  self.PType == RealTyoe.Parameter and self.PName == PName then
        self.Parame == PValue
    end
end


function Formula.new()
    local v = setmetatable({}, metatable_Formula);

    v.renderid = Render.FormulaId

    v.Operator = {}
    return v;
end

function Formula:AddOperator(p)
    self.Operator[#Operator + 1] = p
end

function Formula:Compute()
    if #self.Operator == 0 then
        return 0 -- or 1
    end

    if self.Operator[1].Type ~= OperatorTyoe.Left then
        _errorAssert(false, "Formula Operator[1] is Not TypeLeft")
    end

    if #self.Operator == 1 then
        return self.Operator[1].Real
    end

    local Result = self.Operator[1].Real

    for i = 2, #self.Operator do
    end

end