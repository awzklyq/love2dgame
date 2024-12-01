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



function IsFormulaOperator(fp)
    return type(fp) == 'table' and fp.renderid == Render.FormulaOperatorId
end

function GetRealType(Real)
    local RType
    if IsNumber(Real) then
        RType = RealTyoe.Number
    elseif IsFormulaOperator(Real) then
        RType = RealTyoe.FormulaOperator
    else
        log('FormulaError', Real)
        _errorAssert(false, "GetRealType is Not Right Type")
    end

    return RType
end

function GetParameType(ParameValue)
    local PType
    if IsString(ParameValue) then
        PType = RealTyoe.Parameter
    elseif IsFormulaOperator(ParameValue) then
        PType = RealTyoe.FormulaOperator
    else
        _errorAssert(false, "GetParameType is Not Right Type")
    end

    return PType
end

function CopyReal(RType, Real)
    if RType == RealTyoe.Number then
        return Real
    elseif RType == RealTyoe.FormulaOperator then
        return FormulaOperator.Copy(Real)
    end

    _errorAssert(false, "FormulaOperator CopyReal Error")
end

function CopyParame(PType, Parame)
    if PType == RealTyoe.Parameter then
        return Parame
    elseif PType == RealTyoe.FormulaOperator then
        return FormulaOperator.Copy(Parame)
    end

    _errorAssert(false, "FormulaOperator CopyParame Error")
end

function FormulaOperator.new(OType, RType, Real, PType, Parame, PName)
    local v = setmetatable({}, metatable_FormulaOperator);
    v.OType = OType
    v.RType = RType
    v.Real = Real

    v.PType = PType
    v.Parame = Parame
    v.PName = PName or "" 

    v.renderid = Render.FormulaOperatorId
    return v;
end

function FormulaOperator.Copy(FO)
    local NewFO = setmetatable({}, metatable_FormulaOperator);
    NewFO.renderid = Render.FormulaOperatorId

    NewFO.OType = FO.OType
    NewFO.RType = FO.RType
    NewFO.PType = FO.PType

    NewFO.PName = FO.PName
    NewFO.Parame = CopyParame(FO.PType, FO.Parame)
    NewFO.Real = CopyReal(FO.RType, FO.Real)

    return NewFO
end

function FormulaOperator.CreateFromDiffParame(OType, RType, Real, PType, Parame)
    if PType == RealTyoe.FormulaOperator then
        return FormulaOperator.new(OType, RType, Real, PType, Parame)
    else
        return FormulaOperator.new(OType, RType, Real, PType, nil, Parame)
    end
end

function FormulaOperator.NewAdd(Real, Parame)
    local OType = OperatorTyoe.Add
    local RType = GetRealType(Real)
    local PType = GetParameType(Parame)
    return FormulaOperator.CreateFromDiffParame(OType, RType, Real, PType, Parame)
end

function FormulaOperator.NewSub(Real, Parame)
    local OType = OperatorTyoe.Sub
    local RType = GetRealType(Real)
    local PType = GetParameType(Parame)
    return FormulaOperator.CreateFromDiffParame(OType, RType, Real, PType, Parame)
end

function FormulaOperator.NewMul(Real, Parame)
    local OType = OperatorTyoe.Mul
    local RType = GetRealType(Real)
    local PType = GetParameType(Parame)
    return FormulaOperator.CreateFromDiffParame(OType, RType, Real, PType, Parame)
end

function FormulaOperator.NewDiv(Real, Parame)
    local OType = OperatorTyoe.Div
    local RType = GetRealType(Real)
    local PType = GetParameType(Parame)
    return FormulaOperator.CreateFromDiffParame(OType, RType, Real, PType, Parame)
end

function FormulaOperator.NewPow(Real, Parame)
    local OType = OperatorTyoe.Pow
    local RType = GetRealType(Real)
    local PType = GetParameType(Parame)
    return FormulaOperator.CreateFromDiffParame(OType, RType, Real, PType, Parame)
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

    local RealValue = self:GetRealValue()

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
        self.Parame = PValue
    elseif self.PType == RealTyoe.FormulaOperator then
        self.Parame:SetParameValue(PName, PValue)
    end

    if self.RType == RealTyoe.FormulaOperator then
        self.Real:SetParameValue(PName, PValue)
    end
end

function FormulaOperator:HasParame(PName)
    local IsHas = false
    if  self.PType == RealTyoe.Parameter and self.PName == PName then
        IsHas = true
    end

    if IsHas == false then
        if self.PType == RealTyoe.FormulaOperator then
            IsHase = self.Parame:HasParame(PName)
        end
    end

    if IsHas == false then
        if self.RType == RealTyoe.FormulaOperator then
            IsHas = self.Real:HasParame(PName)
        end
    end

    return IsHas
end

function FormulaOperator:IsHasParame(PName)
    local IsHas = false
    if  self.PType == RealTyoe.Parameter then
        IsHas = true
    end

    if IsHas == false then
        if self.PType == RealTyoe.FormulaOperator then
            IsHase = self.Parame:IsHasParame(PName)
        end
    end

    if IsHas == false then
        if self.RType == RealTyoe.FormulaOperator then
            IsHas = self.Real:IsHasParame(PName)
        end
    end

    return IsHas
end

function FormulaOperator:IsHasOtherParame(PName)
    local IsHas = false
    if  self.PType == RealTyoe.Parameter then
        IsHas = self.PName ~= PName
    end

    if IsHas == false then
        if self.PType == RealTyoe.FormulaOperator then
            IsHase = self.Parame:IsHasParame(PName)
        end
    end

    if IsHas == false then
        if self.RType == RealTyoe.FormulaOperator then
            IsHas = self.Real:IsHasParame(PName)
        end
    end

    return IsHas
end

function FormulaOperator:ReplaceParamWithFormula(PName, FO)
    _errorAssert(IsFormulaOperator(FO), "ReplaceParamWithFormula FO is not Right")

    if  self.PType == RealTyoe.Parameter and self.PName == PName then
        self.Parame = FormulaOperator.Copy(FO)
        self.PType = RealTyoe.FormulaOperator
    elseif self.PType == RealTyoe.FormulaOperator then
        self.Parame:ReplaceParamWithFormula(PName, FO)
    end

    if self.RType == RealTyoe.FormulaOperator then
        self.Real:ReplaceParamWithFormula(PName, FO)
    end
end

function FormulaOperator:Derivative(PName, PValue)
    if PValue == nil then
        local MinNumber = 0.001--math.MinNumber
        local NewFO = FormulaOperator.NewAdd(MinNumber, PName)
        local FO1 = FormulaOperator.Copy(self)
        FO1:ReplaceParamWithFormula(PName, NewFO)

        local FO2 = FormulaOperator.Copy(self)

        local FO3 = FormulaOperator.NewSub(FO1, FO2)
        local FO4 = FormulaOperator.NewMul(1 / MinNumber, FO3)

        return FO4
        
    elseif self:IsHasOtherParame(PName) then
        local FO1 = FormulaOperator.Copy(self)
        FO1:SetParameValue(PName, PValue + math.MinNumber)

        local FO2 = FormulaOperator.Copy(self)
        FO2:SetParameValue(PName, PValue)

        local FO3 = FormulaOperator.NewSub(FO1, FO2)
        local FO4 = FormulaOperator.NewMul(1 / math.MinNumber, FO3)

        return FO4
    else
       self:SetParameValue(PName, PValue + math.MinNumber)
       local V1 = self:GetParameValue()

       self:SetParameValue(PName, PValue)
       local V2 = self:GetParameValue()

       return (V1 - V2) / math.MinNumber

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
    
end