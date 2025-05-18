_G.MarkovProcess = {}
MarkovProcess.Meta = {__index = MarkovProcess}

_G.MarkovState = {}
MarkovState.Meta = {__index = MarkovState}

-- Index must be more than 0 （start from 1）
function MarkovState.new(InName, InIndex, InReward)
    local m = setmetatable({}, MarkovState.Meta)

    m._Name = tostring(InName)
    m._Index = InIndex
    m._ToOtherState = {}
    m._Reward = InReward
    m._Termination = false

    return m
end

function MarkovState:AddLinkStateAndProbability(InState, InP)
    self._ToOtherState[#self._ToOtherState + 1] = {State = InState, P = InP}
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
end

function MarkovState:ForeachLinkStates(InFunc)
    for i = 1, #self._ToOtherState do
        InFunc(self, self._ToOtherState[i].State, self._ToOtherState[i].P)
    end
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
    self._MarkovStates[#self._MarkovStates + 1] = InState
end

function MarkovProcess:SetDiscountFactor(InValue)
    self._DiscountFactor = InValue or 0
end

function MarkovProcess:GenerateData()
    self._State_N = #self._MarkovStates
    self._IsHastData = self._State_N > 0

    if self._IsHastData == false then return end

    self:GenerateSTM()
end

--Generate state transition matrix
function MarkovProcess:GenerateSTM()
    if self._IsHastData == false then return end

    --Sort from index
    table.sort(self._MarkovStates, function (a, b)
        return a:GetIndex() < b:GetIndex()
    end)

    --state transition matrix
    self._P = Matrixs.new(self._State_N, self._State_N, 0)

    local _Holder = self
    for i = 1, self._State_N do
        local s = self._MarkovStates[i]
        s:ForeachLinkStates(function (InSelfState, InLinkState, InP)
            _Holder:SetStateProbability(InLinkState:GetIndex(), InSelfState:GetIndex(), InP)
        end)
    end
end

-- Form State InJ To State InI
function MarkovProcess:SetStateProbability(InI, InJ, InP)
    self._P[InI][InJ] = InP
end