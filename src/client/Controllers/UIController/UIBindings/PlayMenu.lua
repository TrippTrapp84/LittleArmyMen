local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local PlayerSpawnService = Knit.GetService("PlayerSpawnService")

local Player = game.Players.LocalPlayer
local UI = Player:WaitForChild("PlayerGui").Main
local PlayMenu = UI.PlayMenu
local TeamButtonsList = PlayMenu.TeamButtons

local Bindings = {}
local TeamButtons = {}

Bindings.PlayMenuBackActivated = PlayMenu.Back.TextButton.Activated:Connect(function(Input : InputObject)

    PlayMenu.Visible = false
    UI.MainMenu.Visible = true
end)

Bindings.PlayMenuSpawnActivated = PlayMenu.Spawn.TextButton.Activated:Connect(function(Input : InputObject)

    PlayerSpawnService:RequestSpawn()
end)

Bindings.PlayMenuTeamsAdded = PlayerSpawnService.TeamsLoaded:Connect(function(Teams : {string})

    local TeamChangeAttemptInProgress = false

    for TeamIndex, TeamName in pairs(Teams) do
        local Button = TeamButtonsList._TeamButtonTemplate:Clone()
        Button.TextButton.Text = TeamName
        Button.LayoutOrder = TeamIndex
        Button.Parent = TeamButtonsList
        Button.Visible = true

        local ButtonActivatedConnection = Button.TextButton.Activated:Connect(function(Input : InputObject)
            if TeamChangeAttemptInProgress then return end
            TeamChangeAttemptInProgress = true
            PlayerSpawnService:SetTeam(TeamName):await()
            TeamChangeAttemptInProgress = false
        end)

        TeamButtons[TeamIndex] = {
            Button = Button,
            ActivatedConnection = ButtonActivatedConnection
        }
    end
end)

Bindings.PlayMenuTeamsReset = PlayerSpawnService.TeamsReset:Connect(function()
    for _,TeamButton in pairs(TeamButtons) do
        TeamButton.ActivatedConnection:Disconnect()
        TeamButton.Button:Destroy()
    end

    TeamButtons = {}
end)

return Bindings