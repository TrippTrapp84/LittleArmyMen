local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local VotingService = Knit.GetService("VotingService")

local Player = game.Players.LocalPlayer
local UI = Player:WaitForChild("PlayerGui").Main
local VotingMenuSeperator = UI.MainMenu.VotingMenuSeperator
local VotingOptionsList = VotingMenuSeperator.VotingOptionsList

local Bindings = {}

local VotingOptionButtons = {}
local CurrentChoice : number? = nil

local function OnVotingBegan(VotingCategory : string, VotingOptions : {string})

    VotingMenuSeperator.Visible = true

    for OptionNumber,Option in pairs(VotingOptions) do
        local Button = VotingOptionsList._VotingOptionTemplate:Clone()
        Button.Name = Option
        Button.Parent = VotingOptionsList
        Button.LayoutOrder = OptionNumber
        Button.TextButton.Text = Option
        Button.Visible = true

        local ButtonActivatedConnection = Button.TextButton.Activated:Connect(function(Input : InputObject)
            if OptionNumber == CurrentChoice then return end
            
            CurrentChoice = OptionNumber
            VotingService:SetVote(CurrentChoice)
        end)

        VotingOptionButtons[OptionNumber] = {
            Button = Button,
            ActivatedConnection = ButtonActivatedConnection
        }
    end
end

Bindings.VotingBegan = VotingService.VotingBegan:Connect(OnVotingBegan)

Bindings.VotingEnded = VotingService.VotingEnded:Connect(function(VotingResult : number)

    VotingMenuSeperator.Visible = false

    for i,v in pairs(VotingOptionButtons) do
        v.ActivatedConnection:Disconnect()
        v.Button:Destroy()
    end

    VotingOptionButtons = {}
    CurrentChoice = nil
end)

--//TODO: Add vote counts to UI and bind VotesChanged event in here

--// Handling the case of joining mid-vote
if VotingService:IsVotingHappening():expect() then
    local VotingCategory,VotingOptions = VotingService:GetVotingOptionData():expect()
    OnVotingBegan(VotingCategory,VotingOptions)
end

return Bindings