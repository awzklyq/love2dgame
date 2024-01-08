_G.TimerManager = {}

TimerManager.Timers = {}
TimerManager.Tick = function(dt)
    for i, v in pairs(TimerManager.Timers) do
        v:Tick(dt)
    end
end

_G.Timer = {}
function Timer.new(duration)
    local timer = setmetatable({}, {__index = Timer});
    timer.loop = false
    timer.pause = false
    timer.tick = 0
    timer.duration = duration or 1
    return timer;
end

function Timer:Start()
    TimerManager.Timers[self] = self
    self.tick = 0
end

function Timer:Stop()
    TimerManager.Timers[self] = nil
    self.tick = 0
end

function Timer:Release()
    self.TraggerEvent = nil
    self.TriggerFrame = nil
end

function Timer:Tick(dt)
    if self.pause then return end
    
    self.tick = self.tick + dt

    if self.tick >= self.duration then
        if self.TraggerEvent then
            self.TraggerEvent()
        end

        if self.loop then
            self.tick = self.tick % self.duration
        else
            self:Stop()
        end
    else
        if self.TriggerFrame then
            self.TriggerFrame(self.tick, self.duration)
        end
    end
end

_G.app.update(function(dt)
    TimerManager.Tick(dt);
end)