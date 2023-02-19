local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = game.Players.LocalPlayer
local UI = Player:WaitForChild("PlayerGui").Main
local InventoryMenu = UI.InventoryMenu

local Bindings = {}

Bindings.InventoryMenuBackActivated = InventoryMenu.Back.TextButton.Activated:Connect(function(Input : InputObject)

    InventoryMenu.Visible = false
    UI.MainMenu.Visible = true
end)

return Bindings