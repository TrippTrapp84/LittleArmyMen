local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Controller = Knit.CreateController{
    Name = "PlayerController"
}

function Controller:KnitInit()
    self.Player = game.Players.LocalPlayer
    self.PlayerSpawnService = Knit.GetService("PlayerSpawnService")

    self.Connections = {}
end

function Controller:KnitStart()
    self.Connections.CharacterAdded = self.PlayerSpawnService.PlayerLoaded:Connect(function()
        local Character = self.Player.Character or self.Player.CharacterAdded:Wait()
        self:FixCharacter(Character)
    end)
end

function Controller:FixCharacter(Character : Model)
    (Character:WaitForChild("Humanoid") :: Humanoid).BreakJointsOnDeath = false
end

return Controller