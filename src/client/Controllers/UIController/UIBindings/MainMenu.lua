local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = game.Players.LocalPlayer
local UI = Player:WaitForChild("PlayerGui").Main
local MainMenu = UI.MainMenu
local ButtonsListSeperator = MainMenu.ButtonsListSeperator

local Bindings = {}

Bindings.MainMenuPlayActivated = ButtonsListSeperator.Play.TextButton.Activated:Connect(function(Input : InputObject)

    MainMenu.Visible = false
    UI.PlayMenu.Visible = true
end)

Bindings.MainMenuInventoryActivated = ButtonsListSeperator.Inventory.TextButton.Activated:Connect(function(Input : InputObject)

    MainMenu.Visible = false
    UI.InventoryMenu.Visible = true
end)

Bindings.MainMenuSettingsActivated = ButtonsListSeperator.Settings.TextButton.Activated:Connect(function(Input : InputObject)

    MainMenu.Visible = false
    UI.SettingsMenu.Visible = true
end)

Bindings.CharacterAdded = Player.CharacterAdded:Connect(function(character)
    MainMenu.Visible = false
    UI.PlayMenu.Visible = false
    UI.InventoryMenu.Visible = false
    UI.SettingsMenu.Visible = false
end)

Bindings.CharacterRemoving = Player.CharacterRemoving:Connect(function(character)
    MainMenu.Visible = true
end)

return Bindings