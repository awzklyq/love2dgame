
local TestFunc = function()
    log('TestFunc ---------')
end

local TestFuncFrame = function()
    log('TestFuncFrame ->>')
end

local timer = Timer.new(5)
timer.TraggerEvent = TestFunc
timer.TriggerFrame = TestFuncFrame

timer:Start()