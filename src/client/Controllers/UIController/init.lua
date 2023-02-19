local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Controller = Knit.CreateController{
    Name = "UIController"
}

function Controller:KnitInit()
    self.Player = game.Players.LocalPlayer
    self.UI = game.StarterGui.Main:Clone()
    self.UI.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    

    self.Connections = {}
end

function Controller:KnitStart()
    for _,Module : ModuleScript in pairs(script.UIBindings:GetChildren()) do
        require(Module)
    end

    game.Players.LocalPlayer.PlayerGui.ChildAdded:Connect(function(child)
        repeat child:Destroy() task.wait() until child.Parent == nil
    end)
end

return Controller