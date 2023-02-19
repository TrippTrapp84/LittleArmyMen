local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Controller = Knit.CreateController{
    Name = "CameraController"
}

function Controller:KnitInit()
    self.Player = game.Players.LocalPlayer
    self.Camera = workspace.CurrentCamera
    self.CurrentViewmodel = nil

    self.PlayerSpawnService = Knit.GetService("PlayerSpawnService")
    
    self.Connections = {}
end

function Controller:KnitStart()
    local CameraViewmodelConnection

    print("Bound PlayerLoaded")
    self.Connections.CharacterAdded = self.PlayerSpawnService.PlayerLoaded:Connect(function()
        --// local Character = self.Player.Character or self.Player.CharacterAdded:Wait()
        self.CurrentViewmodel = ReplicatedStorage.Assets.Rigs.PlayerViewmodel:Clone()
        self.CurrentViewmodel.Parent = workspace
        CameraViewmodelConnection = RunService.RenderStepped:Connect(function()
            self.CurrentViewmodel.ViewmodelRootPart.CFrame = self.Camera.CFrame
        end)
    end)

    self.Connections.CharacterRemoving = self.PlayerSpawnService.PlayerUnloading:Connect(function()
        self.CurrentViewmodel:Destroy()
        CameraViewmodelConnection:Disconnect()
    end)
end

return Controller