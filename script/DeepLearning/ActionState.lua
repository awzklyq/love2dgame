_G.MarkovActionState = {}
MarkovActionState.Meta = {__index = MarkovActionState}

_G.MarkovUserAction = {}
MarkovUserAction.Meta = {__index = MarkovUserAction}

_G.ActionType = {}
ActionType.UserDataIsStateIndex = 1

local ActionNumber = 100
for i = 1, ActionNumber do
    MarkovActionState["Action" .. tostring(i)] = i
end

function MarkovUserAction.new(InUserData, InP, InType)
    local a = setmetatable({}, MarkovUserAction.Meta)

    a._P = InP

    a._Type = InType
    a._UserData = InUserData

    return a
end

function MarkovUserAction:GetP()
    return self._P
end

function MarkovUserAction:GetType()
    return self._Type
end


function MarkovUserAction:GetUserData()
    return self._UserData
end

function MarkovActionState.new(InActionIndex, InReward)
    local a = setmetatable({}, MarkovActionState.Meta)

    a._ActionIndex = InActionIndex

    a._Reward = InReward or 0

    a._Actions = {}

    return a
end

function MarkovActionState:GetUserActions()
    return self._Actions
end

function MarkovActionState:ForeachActions(InFunc)
    for i = 1, #self._Actions do
        InFunc(self._Actions[i])
    end
end

function MarkovActionState:AddUserAction(InUserAction)
    self._Actions[#self._Actions + 1] = InUserAction
end

function MarkovActionState:GetActionIndex()
    return self._ActionIndex
end

function MarkovActionState:HasUserActions()
    return #self._Actions > 0
end

function MarkovActionState:GetReward()
    return self._Reward
end