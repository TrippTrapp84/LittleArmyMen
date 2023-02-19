local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = game.Players.LocalPlayer
local UI = Player:WaitForChild("PlayerGui").Main
local SettingsMenu = UI.SettingsMenu

local Bindings = {}

Bindings.SettingsMenuBackActivated = SettingsMenu.Back.TextButton.Activated:Connect(function(Input : InputObject)

    SettingsMenu.Visible = false
    UI.MainMenu.Visible = true
end)

return Bindings