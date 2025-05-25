dofile('script/DeepLearning/ActionState.lua')

_G.MarkovProcess = {}
MarkovProcess.Meta = {__index = MarkovProcess}

_G.MarkovState = {}
MarkovState.Meta = {__index = MarkovState}

-- Index must be more than 0 （start from 1）
function MarkovState.new(InName, InIndex, InReward)
    local m = setmetatable({}, MarkovState.Meta)

    m._Name = tostring(InName)
    m._Index = InIndex
    m._Reward = InReward or 0

    m:Init()

    return m
end

function MarkovState:Init()

    self._ToOtherState = {}
    self._Actions = {}
    self._Termination = false
end

function MarkovState:AddLinkStateAndProbability(InState, InP)
    self._ToOtherState[#self._ToOtherState + 1] = {State = InState, P = InP}
end

function MarkovState:HasActions()
    return #self._Actions > 0
end

function MarkovState:AddAction(InActionState, InP)
    self._Actions[#self._Actions + 1] = {ActionState = InActionState, P = InP}
end

function MarkovState:GetIndex()
    return self._Index
end

function MarkovState:GetName()
    return self._Name
end

function MarkovState:GetReward()
    return self._Reward
end

function MarkovState:IsTermination()
    return self._Termination
end

function MarkovState:SetTermination(InValue)
    self._Termination = InValue
    if InValue then
        self:AddLinkStateAndProbability(self, 1)
    end
end

function MarkovState:ForeachLinkStatesNoAction(InFunc)
    _errorAssert(self:HasActions() == false and #self._ToOtherState > 0)
    for i = 1, #self._ToOtherState do
        InFunc(self, self._ToOtherState[i].State, self._ToOtherState[i].P)
    end
end

function MarkovState:ForeachLinkStatesAction(InFunc)
    _errorAssert(self:HasActions())
    for i = 1, #self._Actions do
        InFunc(self, self._Actions[i])
    end
end

function MarkovState:CacleActionsReward()
    if self:HasActions() == false then
        return
    end

    self._Reward = 0
    for i = 1, #self._Actions do
        local a = self._Actions[i]
        self._Reward = self._Reward + a.P * a.ActionState:GetReward()
    end
end

--UserData is state index
function MarkovState:CaclePToState_Actions(InState)
    local _Index = InState:GetIndex()
    
    if _Index == self._Index and self._Termination then
        return 1
    end

    if self:HasActions() == false then
        return 0
    end

    local _P = 0
    for i = 1, #self._Actions do
        local a = self._Actions[i]
        self._Reward = self._Reward + a.P * a.ActionState:GetReward()
        a.ActionState:ForeachActions(function(InAction)
            if InAction:GetType() == ActionType.UserDataIsStateIndex and InAction:GetUserData() == _Index then
                _P = _P + a.P * InAction:GetP()
            end
        end)
    end

    return _P
end

function MarkovProcess.new(InDiscountFactor)
    local m = setmetatable({}, MarkovProcess.Meta)

    -- m:InitData(InMS)
    -- m._P = Matrixs.new(InSN, InSN) -- state transition matrix

    m._IsHastData = false
    m._State_N = 0
    m._MarkovStates = {}
    m._DiscountFactor = InDiscountFactor or 0

    return m
end

function MarkovProcess:AddMarkovState(InState)
    self._State_N = self._State_N + 1
    self._MarkovStates[self._State_N] = InState

    self._IsHastData = true
end

function MarkovProcess:SetDiscountFactor(InValue)
    self._DiscountFactor = InValue or 0
end

function MarkovProcess:GenerateStateValuesNoAction()
    if self._IsHastData == false then return end

    --Sort from index
    table.sort(self._MarkovStates, function (a, b)
        return a:GetIndex() < b:GetIndex()
    end)

    --state transition matrixs
    self._P = Matrixs.new(self._State_N, self._State_N, 0)

    --Generate state transition matrixs
    local _Holder = self
    for i = 1, self._State_N do
        local s = self._MarkovStates[i]
        s:ForeachLinkStatesNoAction(function (InSelfState, InLinkState, InP)
            _Holder:SetStateProbability(InSelfState:GetIndex(), InLinkState:GetIndex(), InP)
        end)
    end

    local NewP = self._P * self._DiscountFactor
    local _IMat = Matrixs.new(self._P.Row, self._P.Column)
    _IMat:Identity()
    NewP = _IMat - NewP

    -- Get reward
    local _reward = {}
    for i = 1, #self._MarkovStates do
        _reward[i] = self._MarkovStates[i]:GetReward()
    end

    local InverseMat = NewP:GetInverseByGaussJordan()
    InverseMat:FixValues()
    local _V = InverseMat * _reward

    return _V
end

function MarkovProcess:GetStateFormIndex(InIndex)
    return self._MarkovStates[i]
end

function MarkovProcess:CaclePFormActions()
    if self._IsHastData == false then return end
     table.sort(self._MarkovStates, function (a, b)
        return a:GetIndex() < b:GetIndex()
    end)

    --state transition matrixs
    self._P = Matrixs.new(self._State_N, self._State_N, 0)

     --Generate state transition matrixs
    local _Holder = self
    for i = 1, self._State_N do
        local selfstate = self._MarkovStates[i]
        for j = 1, self._State_N do
            local linkstate = self._MarkovStates[j]
    
            local _p = selfstate:CaclePToState_Actions(linkstate)
            _Holder:SetStateProbability(i, j, _p)
        end

        -- local s = self._MarkovStates[i]
        -- s:ForeachLinkStates(function (InSelfState, InAction)
        --     InFuncForP(_Holder, InSelfState, InAction)
        --     -- _Holder:SetStateProbability(InSelfState:GetIndex(), InLinkState:GetIndex(), InFuncForP(InSelfState, InLinkState))
        -- end)
    end
end

function MarkovProcess:GenerateStateValues(InFuncForP)
    if self._IsHastData == false then return end

    self:CaclePFormActions()

    local NewP = self._P * self._DiscountFactor
    local _IMat = Matrixs.new(self._P.Row, self._P.Column)
    _IMat:Identity()
    NewP = _IMat - NewP

    -- Get reward
    local _reward = {}
    for i = 1, #self._MarkovStates do
        _reward[i] = self._MarkovStates[i]:GetReward()
    end

    local InverseMat = NewP:GetInverseByGaussJordan()
    -- InverseMat:FixValues()
    local _V = InverseMat * _reward

    return _V
end

-- Form State InJ To State InI
function MarkovProcess:SetStateProbability(InI, InJ, InP)
    self._P[InI][InJ] = InP
end