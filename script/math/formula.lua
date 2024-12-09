_G.Formula = {}
_G.FormulaOperator = {}

_G.OperatorType = {}
OperatorType.None = 0 
OperatorType.Add = 2
OperatorType.Sub = 3
OperatorType.Mul = 4
OperatorType.Div = 5
OperatorType.Pow = 6

_G.RealType = {}
RealType.Number = 0
RealType.Formula = 1
RealType.Parameter = 2
RealType.FormulaOperator = 3

_G.EquationType = {}
EquationType.Equation = 0
EquationType.Greater = 1
EquationType.Less = 2
EquationType.GreaterAndEquation = 3
EquationType.LessAndEquation = 4

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
        RType = RealType.Number
    elseif IsFormulaOperator(Real) then
        RType = RealType.FormulaOperator
    else
        log('FormulaError', Real)
        _errorAssert(false, "GetRealType is Not Right Type")
    end

    return RType
end

function GetParameType(ParameValue)
    local PType
    if IsString(ParameValue) or ParameValue == nil then
        PType = RealType.Parameter
    elseif IsFormulaOperator(ParameValue) then
        PType = RealType.FormulaOperator
    else
        log(ParameValue)
        _errorAssert(false, "GetParameType is Not Right Type " ..  tostring(ParameValue))
    end

    return PType
end

function CopyReal(RType, Real)
    if RType == RealType.Number then
        return Real
    elseif RType == RealType.FormulaOperator then
        return FormulaOperator.Copy(Real)
    end

    _errorAssert(false, "FormulaOperator CopyReal Error")
end

function CopyParame(PType, Parame)
    if PType == RealType.Parameter then
        return Parame
    elseif PType == RealType.FormulaOperator then
        return FormulaOperator.Copy(Parame)
    end

    _errorAssert(false, "FormulaOperator CopyParame Error")
end

function IsNeedBracket(FO)
    return FO.OType == OperatorType.Add or  FO.OType == OperatorType.Sub
end

function ToStringReal(FO)
    if FO.RType == RealType.Number then
        return tostring(FO.Real)
    elseif  FO.RType == RealType.FormulaOperator then
        if IsNeedBracket(FO.Real) then
            return " (" .. FO.Real:ToString() .. ")"
        else
            return FO.Real:ToString()
        end
    end

    _errorAssert(false, "FormulaOperator ToStringReal Error")
end

function ToStringParame(FO)
    if FO.PType == RealType.Parameter then
        return FO.PName.."(" .. tostring(FO.Parame)..") "
    elseif  FO.PType == RealType.FormulaOperator then
        if IsNeedBracket(FO.Parame) then
            return " (" .. FO.Parame:ToString() .. ")"
        else
            return FO.Parame:ToString()
        end
    end

    _errorAssert(false, "FormulaOperator ToStringParame Error")
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
    if PType == RealType.FormulaOperator then
        return FormulaOperator.new(OType, RType, Real, PType, Parame)
    else
        return FormulaOperator.new(OType, RType, Real, PType, nil, Parame)
    end
end

function FormulaOperator.NewAdd(Real, Parame)
    local OType = OperatorType.Add
    local RType = GetRealType(Real)
    local PType = GetParameType(Parame)
    return FormulaOperator.CreateFromDiffParame(OType, RType, Real, PType, Parame)
end

function FormulaOperator.NewSub(Real, Parame)
    local OType = OperatorType.Sub
    local RType = GetRealType(Real)
    local PType = GetParameType(Parame)
    return FormulaOperator.CreateFromDiffParame(OType, RType, Real, PType, Parame)
end

function FormulaOperator.NewMul(Real, Parame)
    local OType = OperatorType.Mul
    local RType = GetRealType(Real)
    local PType = GetParameType(Parame)
    return FormulaOperator.CreateFromDiffParame(OType, RType, Real, PType, Parame)
end

function FormulaOperator.NewDiv(Real, Parame)
    local OType = OperatorType.Div
    local RType = GetRealType(Real)
    local PType = GetParameType(Parame)
    return FormulaOperator.CreateFromDiffParame(OType, RType, Real, PType, Parame)
end

function FormulaOperator.NewPow(Real, Parame)
    local OType = OperatorType.Pow
    local RType = GetRealType(Real)
    local PType = GetParameType(Parame)
    return FormulaOperator.CreateFromDiffParame(OType, RType, Real, PType, Parame)
end

function FormulaOperator.IsSampleParameByName(FO1, FO2)
    return FO1.PName ~= "" and FO1.PName == FO2.PName
end

function FormulaOperator:GetRealValue()
    local RealValue

    if self.RType == RealType.FormulaOperator then
        RealValue = self.Real:GetParameValue()
    elseif self.RType == RealType.Number then
        RealValue = self.Real
    else
        _errorAssert(false, "Operator GetRealValue PType is not Right")
    end

    return RealValue
end

function FormulaOperator:GetParameValue()
    local ParameValue
    if self.PType == RealType.FormulaOperator then
        ParameValue = self.Parame:GetParameValue()
    elseif self.PType == RealType.Parameter then
        _errorAssert(self.Parame, "Operator GetParameValue PType Parameter is not Value")
        ParameValue = self.Parame
    elseif self.PType == RealType.Number then
        ParameValue = self.Real
    else
        _errorAssert(false, "Operator GetParameValue PType is not Right")
    end

    local RealValue = self:GetRealValue()

    local Result
    if self.OType == OperatorType.Add then
        Result = RealValue + ParameValue
    elseif self.OType == OperatorType.Sub then
        Result = RealValue - ParameValue
    elseif self.OType == OperatorType.Mul then
        Result = RealValue * ParameValue
    elseif self.OType == OperatorType.Div then
        Result = RealValue / ParameValue
    elseif self.OType == OperatorType.Pow then
        Result = math.pow(ParameValue, RealValue)
    else
        _errorAssert(false, "Operator GetParameValue OType is not Right")
    end

    return Result
end

function FormulaOperator:SetParameValue(PName, PValue)
    if  self.PType == RealType.Parameter and self.PName == PName then
        self.Parame = PValue
    elseif self.PType == RealType.FormulaOperator then
        self.Parame:SetParameValue(PName, PValue)
    end

    if self.RType == RealType.FormulaOperator then
        self.Real:SetParameValue(PName, PValue)
    end
end

function FormulaOperator:HasParame(PName)
    local IsHas = false
    if  self.PType == RealType.Parameter and self.PName == PName then
        IsHas = true
    end

    if IsHas == false then
        if self.PType == RealType.FormulaOperator then
            IsHas = self.Parame:HasParame(PName)
        end
    end

    if IsHas == false then
        if self.RType == RealType.FormulaOperator then
            IsHas = self.Real:HasParame(PName)
        end
    end

    return IsHas
end

function FormulaOperator:IsHasParame()
    local IsHas = false
    if  self.PType == RealType.Parameter then
        IsHas = true
    end

    if IsHas == false then
        if self.PType == RealType.FormulaOperator then
            IsHase = self.Parame:IsHasParame()
        end
    end

    if IsHas == false then
        if self.RType == RealType.FormulaOperator then
            IsHas = self.Real:IsHasParame()
        end
    end

    return IsHas
end

function FormulaOperator:IsHasOtherParame(PName)
    local IsHas = false
    if  self.PType == RealType.Parameter then
        IsHas = self.PName ~= PName
    end

    if IsHas == false then
        if self.PType == RealType.FormulaOperator then
            IsHase = self.Parame:IsHasParame(PName)
        end
    end

    if IsHas == false then
        if self.RType == RealType.FormulaOperator then
            IsHas = self.Real:IsHasParame(PName)
        end
    end

    return IsHas
end

function FormulaOperator:ReplaceParamWithFormula(PName, FO)
    _errorAssert(IsFormulaOperator(FO), "ReplaceParamWithFormula FO is not Right")

    if  self.PType == RealType.Parameter and self.PName == PName then
        self.Parame = FormulaOperator.Copy(FO)
        self.PType = RealType.FormulaOperator
    elseif self.PType == RealType.FormulaOperator then
        self.Parame:ReplaceParamWithFormula(PName, FO)
    end

    if self.RType == RealType.FormulaOperator then
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

function FormulaOperator:IsHasSubFormula()
    return not (self.RType == RealType.Number and self.PType == RealType.Parameter)
end

function FormulaOperator:MergeOperatorAddInner(RealFormula, ParameFormula, InOType, IsReverse)
    local IsNeedReverse = not not IsReverse
    if RealFormula.OType == OperatorType.Mul then
        if not RealFormula:IsHasSubFormula() then
            -- a*x + b*x
            if not IsNeedReverse and ParameFormula.OType == OperatorType.Mul and (not ParameFormula:IsHasSubFormula()) and FormulaOperator.IsSampleParameByName(RealFormula, ParameFormula) then
                
                if InOType == OperatorType.Add  then
                    return FormulaOperator.NewMul(RealFormula.Real + ParameFormula.Real, ParameFormula.PName)
                elseif InOType == OperatorType.Sub then
                    return FormulaOperator.NewMul(RealFormula.Real - ParameFormula.Real, ParameFormula.PName)
                end
            -- a*x + (c + b*x)
            elseif ParameFormula.OType == OperatorType.Add or ParameFormula.OType == OperatorType.Sub then
                if ParameFormula.RType == RealType.Number and ParameFormula.PType == RealType.FormulaOperator and ParameFormula.Parame.OType == OperatorType.Mul and (not ParameFormula.Parame:IsHasSubFormula()) then
                    if FormulaOperator.IsSampleParameByName(RealFormula, ParameFormula.Parame) then
                        if InOType == OperatorType.Add  then
                            local FO1
                            --a*x + (c + b*x)
                            if ParameFormula.OType == OperatorType.Add then
                                FO1 = FormulaOperator.NewMul(RealFormula.Real + ParameFormula.Parame.Real, RealFormula.PName)
                            else -- ParameFormula.OType == OperatorType.Sub
                                --a*x + (c - b*x)
                                FO1 = FormulaOperator.NewMul(RealFormula.Real - ParameFormula.Parame.Real, RealFormula.PName)
                            end

                            local FO2  = FormulaOperator.NewAdd(ParameFormula.Real, FO1)
                            return FO2
                        else --if self.OType == OperatorType.Sub  then
                            local K = 1.0
                            if  IsNeedReverse then
                                K = -1.0
                            end
                            local FO1
                            --a*x - (c + b*x)
                            if ParameFormula.OType == OperatorType.Add then
                                FO1 = FormulaOperator.NewMul(K*(RealFormula.Real - ParameFormula.Parame.Real), RealFormula.PName)
                            else
                                --a*x - (c - b*x)
                                FO1 = FormulaOperator.NewMul(K* (RealFormula.Real + ParameFormula.Parame.Real), RealFormula.PName)
                            end
                            local FO2  = FormulaOperator.NewAdd(-1 * K * ParameFormula.Real, FO1)
                            return FO2
                           
                        end
                    end
                end
            end
        end 
    elseif  (RealFormula.OType == OperatorType.Add or RealFormula.OType == OperatorType.Sub) and (ParameFormula.OType == OperatorType.Add or ParameFormula.OType == OperatorType.Sub) then
        if RealFormula:IsHasSubFormula() and RealFormula.PType == RealType.FormulaOperator and RealFormula.Parame.OType == OperatorType.Mul and (not RealFormula.Parame:IsHasSubFormula()) then
            
            local NewFO 
            if RealFormula.OType == OperatorType.Add then
                if InOType == OperatorType.Sub then
                    local CFO = FormulaOperator.Copy(ParameFormula)
                    -- CFO:MulNumber(-1)
                    -- log('ssss5555', CFO:ToString())
                    NewFO = self:MergeOperatorAddInner(RealFormula.Parame, CFO, InOType)
                else
                    NewFO = self:MergeOperatorAddInner(RealFormula.Parame, ParameFormula, InOType)
                end
                
            else --RealFormula.OType == OperatorType.Sub
                local RP = FormulaOperator.Copy(RealFormula.Parame)
                RP.Real = -1 * RP.Real
                if InOType == OperatorType.Sub then
                    local CFO = FormulaOperator.Copy(ParameFormula)
                    -- CFO:MulNumber(-1)
                    NewFO = self:MergeOperatorAddInner(RP, CFO, InOType)
                else
                    NewFO = self:MergeOperatorAddInner(RP, ParameFormula, InOType)
                end
               
            end
            
            if NewFO then
                NewFO.Real = NewFO.Real + RealFormula.Real
                if  IsNeedReverse then
                    NewFO:MulNumber(-1)
                end
                return NewFO
            end
        end
    end

    return nil
end

function FormulaOperator:MergeOperatorAdd()

    if self.RType == RealType.FormulaOperator then
        self.Real:MergeOperatorAdd()
    end

    if self.PType == RealType.FormulaOperator then
        self.Parame:MergeOperatorAdd()
    end

    if self.OType ~= OperatorType.Add and self.OType ~= OperatorType.Sub then
        return self
    end
  
    if self.RType ~= RealType.FormulaOperator or self.PType ~= RealType.FormulaOperator then
        return self
    end
    
    local Result = self:MergeOperatorAddInner(self.Real, self.Parame, self.OType)
    if not Result then
        Result = self:MergeOperatorAddInner(self.Parame, self.Real, self.OType, true)
    end
   
    if Result then
        self:Set(FormulaOperator.Copy(Result))
    end

    return self
end

function FormulaOperator:MergeParame()
    self:MergeOperatorMul()
    self:MergeOperatorAdd()

    return self
end

function FormulaOperator:Set(FO)
    self.OType = FO.OType
    self.RType = FO.RType
    self.PType = FO.PType

    self.PName = FO.PName
    self.Parame = CopyParame(FO.PType, FO.Parame)
    self.Real = CopyReal(FO.RType, FO.Real)
end

function FormulaOperator:MulNumber(n)
    _errorAssert(IsNumber(n), "MulNumber Operate is Error")

    local Result = false
    if self.RType == RealType.Number then
        if self.OType == OperatorType.Add or self.OType == OperatorType.Sub or self.OType == OperatorType.Mul or self.OType == OperatorType.Div then
            self.Real = self.Real * n
            Result = true
        elseif self.OType == OperatorType.Pow then
            local FO = FormulaOperator.NewMul(n, FormulaOperator.Copy(self))
            self:Set(FO)
            Result = true
        end
    else
        Result = self.Real:MulNumber(n)
    end

    if self.PType == RealType.Parameter then
        if self.OType == OperatorType.Add or self.OType == OperatorType.Sub then
            self.Parame = FormulaOperator.NewMul(n, self.PName)
            self.PType = RealType.FormulaOperator
            Result = true
        end
    else
        if self.OType == OperatorType.Add or self.OType == OperatorType.Sub then
            if self.Parame:MulNumber(n) then
                Result = true
            end
        end
    end

    return Result
end

function FormulaOperator:MergeOperatorMul()
    local Result = nil
    
    if self.PType == RealType.FormulaOperator then
        self.Parame:MergeOperatorMul()
    end

    if self.RType == RealType.FormulaOperator then
        self.Real:MergeOperatorMul()
    end

    if self.RType == RealType.Number then
        if self.OType == OperatorType.Mul then
            if self.PType == RealType.FormulaOperator then
                if self.Parame:MulNumber(self.Real) then
                    self:Set(FormulaOperator.Copy(self.Parame))
                end
            end
        end
    else
        self.Real:MergeOperatorMul()
    end
end

function FormulaOperator:CheckAndAddParameName(InParameName, OutParames)
    local IsNeedAdd = true
    for i = 1, #OutParames do
        if OutParames[i] == InParameName then
            IsNeedAdd = false
            break
        end
    end
    
    if IsNeedAdd then
        OutParames[#OutParames + 1] = InParameName
    end
end

function FormulaOperator:ExtractParamesNameInner(Parames)
    if self.RType == RealType.FormulaOperator then
        self.Real:ExtractParamesNameInner(Parames)
    end

    if self.PType == RealType.FormulaOperator then
        self.Parame:ExtractParamesNameInner(Parames)
    else
        self:CheckAndAddParameName(self.PName, Parames)
    end
    
end

function FormulaOperator:ExtractParamesName()
    local Parames = {}
    self:ExtractParamesNameInner(Parames)
    return Parames
end

function FormulaOperator:CheckParameName(InParameName)
    local ExtraParames = self:ExtractParamesName()
    local IsHas = false
    for i = 1, #ExtraParames do
        if ExtraParames == InParameName then
            IsHas = true
            break
        end
    end
    
    return IsHas
end

function FormulaOperator:InvertOperatorParame(OutOparator)
    InOType = self.OType

    local InParame
    if self.PType == RealType.FormulaOperator then
        InParame = FormulaOperator.Copy(self.Parame)
    else
        InParame = self.PName
    end 

    if InOType == OperatorType.Add then
        Result = (not OutOparator)  and FormulaOperator.NewMul(-1, InParame) or FormulaOperator.NewSub(OutOparator, InParame)
    elseif  InOType == OperatorType.Sub then
        Result = (not OutOparator)  and FormulaOperator.NewMul(-1, InParame) or FormulaOperator.NewAdd(OutOparator, InParame)
    elseif InOType == OperatorType.Mul then
        Result = (not OutOparator)  and FormulaOperator.NewDiv(1, InParame) or  FormulaOperator.NewDiv(OutOparator, InParame)
    elseif InOType == OperatorType.Div then
        Result = (not OutOparator)  and FormulaOperator.NewMul(1, InParame) or FormulaOperator.NewMul(OutOparator, InParame)
    elseif InOType == OperatorType.Pow then
        Result = FormulaOperator.NewPow(FormulaOperator.NewDiv(1, self.Real), OutOparator)
       
    end

    _errorAssert(not not Result , "Operator InvertOperatorParame OType is not Right")

    return Result
end

function FormulaOperator:InvertOperatorReal(OutOparator)
    InOType = self.OType

    local InReal
    if self.RType == RealType.FormulaOperator then
        InReal = FormulaOperator.Copy(self.Real)
    else
        InReal = self.Real
    end 

    -- log('aaaa', OutOparator, InReal, InOType)
    local Result
    if InOType == OperatorType.Add then
      --  Result = (not OutOparator) and InReal or FormulaOperator.NewSub(OutOparator, InReal)
        if not OutOparator then
            Result = -InReal
        else
            if IsNumber(InReal) then
                if IsNumber(OutOparator) then
                    Result = OutOparator - InReal
                else
                    Result = FormulaOperator.NewAdd(-1 * InReal, OutOparator)
                end
            else
                InReal:MulNumber(-1)
                Result = FormulaOperator.NewAdd(OutOparator, InReal)
            end
        end
    elseif InOType == OperatorType.Sub then
        --Result = (not OutOparator)  and InReal or FormulaOperator.NewSub(InReal, OutOparator)
        if not OutOparator then
            Result = -InReal
        else
            if IsNumber(InReal) then
                if IsNumber(OutOparator) then
                    Result = InReal - OutOparator
                else
                    Result = FormulaOperator.NewSub(InReal, OutOparator)
                end
            else
                if IsNumber(OutOparator) then
                    Result = FormulaOperator.NewAdd(-OutOparator, InReal)
                else
                    Result = FormulaOperator.NewSub(InReal, OutOparator)
                end
            end
        end
    elseif InOType == OperatorType.Mul then
        --Result = (not OutOparator)  and FormulaOperator.NewDiv(1, InReal) or  FormulaOperator.NewDiv(OutOparator, InReal)
        if not OutOparator then
            if IsNumber(InReal) then
                Result = 1 / InReal
            else
                Result = FormulaOperator.NewDiv(1, InReal)
            end
        else
            if IsNumber(InReal) then
                if IsNumber(OutOparator) then
                    Result = OutOparator / InReal
                else
                    OutOparator:MulNumber(1 / InReal)
                    Result = OutOparator
                end
            else
                Result = FormulaOperator.NewDiv(OutOparator, InReal)
            end
        end
    elseif InOType == OperatorType.Div then
        Result = (not OutOparator)  and InReal or FormulaOperator.NewDiv(InReal, OutOparator)
    elseif InOType == OperatorType.Pow then
        Result = FormulaOperator.NewPow(FormulaOperator.NewDiv(1, self.Real), OutOparator)       
    end
  
    _errorAssert(not not Result , "Operator InvertOperatorReal OType is not Right")

    return Result
end

function FormulaOperator:ConvertRealParameToLeft(PName, OutOparator, IsFindParame)

    if IsFindParame then
        if self.RType == RealType.FormulaOperator then
            _errorAssert(not self.Real:HasParame(PName), "Now only support one parame c") 
        end

        OutOparator = self:InvertOperatorReal(OutOparator)
    else
        if self.RType == RealType.FormulaOperator then
            if self.Real:HasParame(PName) then
                OutOparator = self.Real:ConvertParameToLeft(PName, OutOparator)
            else
                OutOparator = self:InvertOperatorReal(OutOparator)
            end
        else
            OutOparator = self:InvertOperatorReal(OutOparator)
        end
    end

    return OutOparator
end

function FormulaOperator:ConvertParameParameToLeft(PName, OutOparator, IsFindParame)
    if IsFindParame then
        if self.PType == RealType.FormulaOperator then
            _errorAssert(not self.Parame:HasParame(PName), "Now only support one parame c") 
        end

        OutOparator = self:InvertOperatorParame(OutOparator)
    else
        if self.PType == RealType.FormulaOperator then
            if self.Parame:HasParame(PName) then
                OutOparator = self.Parame:ConvertParameToLeft(PName, OutOparator)
            else
                OutOparator = self:InvertOperatorParame(OutOparator)
            end
        else
            log('ConvertParameToLeft Find Parame', PName )
        end
    end
    return OutOparator
end

function FormulaOperator:ConvertParameToLeft(PName, OutOparator)
    local IsParameInOParame = false
    if self.PType == RealType.FormulaOperator then
        IsParameInOParame = self.Parame:HasParame(PName)
    else
        IsParameInOParame = self.PName == PName
        if IsParameInOParame then
            OutOparator = self:InvertOperatorReal(OutOparator)
            return OutOparator
        end
    end

    if IsParameInOParame then
        OutOparator = self:ConvertRealParameToLeft(PName, OutOparator, true)
        OutOparator = self:ConvertParameParameToLeft(PName, OutOparator, false)
    else
        OutOparator = self:ConvertParameParameToLeft(PName, OutOparator, true)
        OutOparator = self:ConvertRealParameToLeft(PName, OutOparator, false)
    end
    return OutOparator
end

function FormulaOperator:ToString()
    local RealStr = ToStringReal(self)
    local ParameStr = ToStringParame(self)
    local OperatorStr = ""

    local str = ""
    if self.OType == OperatorType.Add then
        str = RealStr .. " + " .. ParameStr
    elseif self.OType == OperatorType.Sub then
        str = RealStr .. " - " .. ParameStr
    elseif self.OType == OperatorType.Mul then
        str = RealStr .. "*" .. ParameStr
    elseif self.OType == OperatorType.Div then
        str = RealStr .. "/" .. ParameStr
    elseif self.OType == OperatorType.Pow then
        str = ParameStr .. "^".. RealStr
    else
        _errorAssert(false, "ToString OType is not Right")
    end

    return str

end

function Formula.new()
    local v = setmetatable({}, metatable_Formula);

    v.renderid = Render.FormulaId

    v.Operators = {}
    v.ParameNames = {}
    v.ParameValue = {}
    return v;
end

function Formula:CheckAndAddParameName(InParameName)
    local IsNeedAdd = true
    for i = 1, #self.ParameNames do
        if self.ParameNames[i] == InParameName then
            IsNeedAdd = false
            break
        end
    end
    
    if IsNeedAdd then
        self.ParameNames[#self.ParameNames + 1] = InParameName
    end
end

function Formula:ExtractParamesName(p)
    local ParameNames = p:ExtractParamesName()
    for i = 1, #ParameNames do
        self:CheckAndAddParameName(ParameNames[i])
    end
end

function Formula:AddOperator(p)
    _errorAssert(IsFormulaOperator(p))
    self.Operators[#self.Operators + 1] = p:MergeParame()

    self:ExtractParamesName(p)
end

function Formula:CalculateParameterByJacobi()
    _errorAssert(#self.ParameNames == #self.Operators)

    local TempOperators = {}
    local TempValue = {}
    for i = 1, #self.Operators do
        TempOperators[i] = {PName = self.ParameNames[i], Operator = self.Operators[i]:ConvertParameToLeft(self.ParameNames[i])}
        TempValue[self.ParameNames[i]] = 0
    end

    local Iter = 1000
    for i = 1, Iter do
        for j = 1, #TempOperators do
            for p, v in pairs(TempValue) do
                if p ~= TempOperators[j].PName then
                    TempOperators[j].Operator:SetParameValue(p, v)
                end
            end

            TempValue[TempOperators[j].PName] = TempOperators[j].Operator:GetParameValue()
        end
    end

    for i, v in pairs(TempValue) do
        self.ParameValue[i] = v
        log(i,v)
    end
end

function Formula:CalculateParameterByEliminationInner(InOperators, InParameNames)
    if #InOperators == 1 then
        local x = InOperators[1]:ConvertParameToLeft(InParameNames[1])
        self.ParameValue[InParameNames[1]] = IsNumber(x) and x or x:GetParameValue()
        return
    end

    local TempOperators = {}
    local TempParameName = {}
    for i = 1, #InOperators do
        TempOperators[i] = FormulaOperator.Copy(InOperators[i])
        TempParameName[i] = InParameNames[i]
    end

    while #TempOperators > 1 do
        local Temp = {}
        
        local NewFO = TempOperators[1]:ConvertParameToLeft(TempParameName[1])
        for i = 2, #TempParameName do
            local NeedMergeFO = TempOperators[i]:ConvertParameToLeft(TempParameName[1])
            
            local FO = FormulaOperator.NewSub(FormulaOperator.Copy(NewFO), FormulaOperator.Copy(NeedMergeFO))
            FO:MergeParame();
            Temp[#Temp + 1] = FO
        end

        TempOperators = Temp
        table.remove(TempParameName, 1)
    end

   
    local x = TempOperators[1]:ConvertParameToLeft(TempParameName[1])
    self.ParameValue[TempParameName[1]] = x
    table.remove(InOperators, 1)
    for i = 1, #InParameNames do
        if InParameNames[i] == TempParameName[1] then
            table.remove(InParameNames, i)
            break
        end
    end
    
    for i = 1, #InOperators do
        InOperators[i]:SetParameValue(TempParameName[1], x)
    end

    self:CalculateParameterByEliminationInner(InOperators, InParameNames)
end

function Formula:CalculateParameterByElimination()
    _errorAssert(#self.ParameNames == #self.Operators)

    local TempParameName = {}
    local TempOperators = {}
    for i = 1, #self.Operators do
        TempOperators[i] = FormulaOperator.Copy(self.Operators[i])
        TempParameName[i] = self.ParameNames[i]
    end

    self.ParameValue = {}
    self:CalculateParameterByEliminationInner(TempOperators, TempParameName)

    for i, v in pairs(self.ParameValue) do
        log(i,v)
    end
end