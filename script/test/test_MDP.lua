local State1 = MarkovState.new("State1", 1)

local State2 = MarkovState.new("State2", 2)

local State3 = MarkovState.new("State3", 3)

local State4 = MarkovState.new("State4", 4)

local State5 = MarkovState.new("State5", 5)

local ActionState1_1 = MarkovActionState.new(MarkovActionState.Action1, -1);
ActionState1_1:AddUserAction(MarkovUserAction.new(1, 1, ActionType.UserDataIsStateIndex))
State1:AddAction(ActionState1_1, 0.5)

local ActionState1_2 = MarkovActionState.new(MarkovActionState.Action2, 0);
ActionState1_2:AddUserAction(MarkovUserAction.new(2, 1, ActionType.UserDataIsStateIndex))
State1:AddAction(ActionState1_2, 0.5)

local ActionState2_1 = MarkovActionState.new(MarkovActionState.Action3, -1);
ActionState2_1:AddUserAction(MarkovUserAction.new(1, 1, ActionType.UserDataIsStateIndex))
State2:AddAction(ActionState2_1, 0.5)

local ActionState2_3 = MarkovActionState.new(MarkovActionState.Action4, -2);
ActionState2_3:AddUserAction(MarkovUserAction.new(3, 1, ActionType.UserDataIsStateIndex))
State2:AddAction(ActionState2_3, 0.5)

local ActionState3_5 = MarkovActionState.new(MarkovActionState.Action5, 0);
ActionState3_5:AddUserAction(MarkovUserAction.new(5, 1, ActionType.UserDataIsStateIndex))
State3:AddAction(ActionState3_5, 0.5)

local ActionState3_4 = MarkovActionState.new(MarkovActionState.Action6, -2);
ActionState3_4:AddUserAction(MarkovUserAction.new(4, 1, ActionType.UserDataIsStateIndex))
State3:AddAction(ActionState3_4, 0.5)

local ActionState4_5 = MarkovActionState.new(MarkovActionState.Action7, 10);
ActionState4_5:AddUserAction(MarkovUserAction.new(5, 1, ActionType.UserDataIsStateIndex))
State4:AddAction(ActionState4_5, 0.5)

local ActionState4_234 = MarkovActionState.new(MarkovActionState.Action8, 1);
ActionState4_234:AddUserAction(MarkovUserAction.new(2, 0.2, ActionType.UserDataIsStateIndex))
ActionState4_234:AddUserAction(MarkovUserAction.new(3, 0.4, ActionType.UserDataIsStateIndex))
ActionState4_234:AddUserAction(MarkovUserAction.new(4, 0.4, ActionType.UserDataIsStateIndex))
State4:AddAction(ActionState4_234, 0.5)

State5:SetTermination(true)

State1:CacleActionsReward()
State2:CacleActionsReward()
State3:CacleActionsReward()
State4:CacleActionsReward()
State5:CacleActionsReward()

log('State1 Reward', State1:GetReward())
log('State2 Reward', State2:GetReward())
log('State3 Reward', State3:GetReward())
log('State4 Reward', State4:GetReward())
log('State5 Reward', State5:GetReward())

local mp = MarkovProcess.new(0.5)
mp:AddMarkovState(State1)
mp:AddMarkovState(State2)
mp:AddMarkovState(State3)
mp:AddMarkovState(State4)
mp:AddMarkovState(State5)

local _V = mp:GenerateStateValues()

for i = 1, #_V do
    -- log('aaaa', i, _V[i] / 6) -- TODO 6
    log('aaaa', i, _V[i]) -- TODO 6
end