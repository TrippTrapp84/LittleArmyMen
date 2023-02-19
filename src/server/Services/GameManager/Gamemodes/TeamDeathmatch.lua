local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local GameManager = Knit.GetService("GameManager")

local TeamsBase = require(script.Parent.Base.TeamsBase)
local Timer = require(ReplicatedStorage.shared.Timer)

local Gamemode = {
    Name = "Team Deathmatch",
    Description = "Funny kill players haha"
}

function Gamemode:StartMatch()
    TeamsBase:StartMatch()

    self.CurrentScores = {}
    self.Timer = Timer.new(20)

    self.Timer:OnTimerFinished(function()
        GameManager.GameStateMachine:PerformAction("EndMatch")
    end)

    self.Connections = {}
end

function Gamemode:EndMatch()
    if not self.Timer:IsFinished() then self.Timer:Stop() end
    TeamsBase:EndMatch()
end

return Gamemode