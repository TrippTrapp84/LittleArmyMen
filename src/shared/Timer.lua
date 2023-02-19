local Handler = {}
Handler.__index = Handler

function Handler.new(Duration : number)
    local self = setmetatable({},Handler)

    self.Duration = Duration
    self.ElapsedTime = -1
    self.Finished = false
    self.Callbacks = {
        TimerFinished = function() end,
        TimeChanged = function() end,
        TimerStopped = function() end,
    }

    task.defer(function()
        while true do
            if self.Finished then break end
            self.ElapsedTime += 1
            self:_Update()
            if self.ElapsedTime >= self.Duration then self:_Finish() break end
            wait(1)
        end
    end)

    return self
end

function Handler:_Finish()
    self.Finished = true
    self.Callbacks.TimerFinished()
end

function Handler:_Update()
    self.Callbacks.TimeChanged(self.ElapsedTime)
end

function Handler:Stop()
    self.Finished = true
    self.Callbacks.TimerStopped()
end

function Handler:OnTimeChanged(callback : (Time : number) -> ())
    self.Callbacks.TimeChanged = callback
end

function Handler:OnTimerStopped(callback : () -> ())
    self.Callbacks.TimerStopped = callback
end

function Handler:OnTimerFinished(callback : () -> ())
    self.Callbacks.TimerFinished = callback
end

function Handler:SetTime(Time : number)
    self.ElapsedTime = math.clamp(Time,0,math.huge)
    if self.ElapsedTime >= self.Duration then self:_Finish() return end
    self:_Update()
end

function Handler:GetTime()
    return self.ElapsedTime
end

function Handler:IsFinished()
    return self.Finished
end

return Handler