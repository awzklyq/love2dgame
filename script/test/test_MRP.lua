local State1 = MarkovState.new("State1", 1, -1)

local State2 = MarkovState.new("State2", 2, -2)

local State3 = MarkovState.new("State3", 3, -2)

local State4 = MarkovState.new("State4", 4, 10)

local State5 = MarkovState.new("State5", 5, 1)

local State6 = MarkovState.new("State6", 6, 0)
State6:SetTermination(true)

State1:AddLinkStateAndProbability(State1, 0.9)
State1:AddLinkStateAndProbability(State2, 0.1)

State2:AddLinkStateAndProbability(State1, 0.5)
State2:AddLinkStateAndProbability(State3, 0.5)

State3:AddLinkStateAndProbability(State4, 0.6)
State3:AddLinkStateAndProbability(State6, 0.4)

State4:AddLinkStateAndProbability(State6, 0.7)
State4:AddLinkStateAndProbability(State5, 0.3)

State5:AddLinkStateAndProbability(State4, 0.5)
State5:AddLinkStateAndProbability(State3, 0.3)
State5:AddLinkStateAndProbability(State2, 0.2)

local mp = MarkovProcess.new(0.5)
mp:AddMarkovState(State1)
mp:AddMarkovState(State2)
mp:AddMarkovState(State3)
mp:AddMarkovState(State4)
mp:AddMarkovState(State5)
mp:AddMarkovState(State6)

local _V = mp:GenerateStateValues()
for i = 1, #_V do
    log('aaaa', i, _V[i])
end