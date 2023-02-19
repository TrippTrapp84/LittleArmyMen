local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

export type VotingOptions = { string }

local Service = Knit.CreateService{
    Name = "VotingService",
    Client = {
        VotingBegan = Knit.CreateSignal(),
        VotingEnded = Knit.CreateSignal(),

        VotesChanged = Knit.CreateSignal()
    }
}

function Service:KnitInit()
    self.CurrentVotingOptions = {}
    self.CurrentVotingCategory = ""
    self.CurrentVotes = {}
    self.VotingResult = nil
    self.VotesChanged = false
    self.IsVoting = false

    self.Connections = {}
end

function Service:KnitStart()

end

function Service:GetVotingResult()
    
    local VoteTally = {}
    for i,v in pairs(self.CurrentVotes) do
        VoteTally[v] = (VoteTally[v] or 0) + 1
    end
    
    local HighestVal = 0
    local Highest = {}
    for VoteOption,Votes in pairs(VoteTally) do
        if Votes < HighestVal then continue end
        if Votes == HighestVal then Highest[#Highest+1] = VoteOption continue end
        HighestVal = Votes
        Highest = {VoteOption}
    end

    return self.CurrentVotingOptions[Highest[math.random(1,#Highest)]]
end

function Service:BeginVoting(NewVotingCategory : string, NewVotingOptions : VotingOptions, VotingTime : number)
    self.IsVoting = true
    self.CurrentVotingOptions = NewVotingOptions
    self.CurrentVotingCategory = NewVotingCategory
    self.CurrentVotes = {}
    self.Client.VotingBegan:FireAll(NewVotingCategory,NewVotingOptions)

    local VoteStartTime = tick()
    repeat
        task.wait()
        if not self.IsVoting then return self:GetVotingResult() end
        if tick() - VoteStartTime > VotingTime then break end

        if self.VotesChanged then
            self.Client.VotesChanged:FireAll(self.CurrentVotes)
            self.VotesChanged = false
        end
    until false
    return self:EndVoting(self:GetVotingResult())
end

function Service:EndVoting(Result : string)
    self.Client.VotingEnded:FireAll(Result)
    self.CurrentVotingOptions = {}
    self.CurrentVotingCategory = ""
    self.CurrentVotes = {}

    self.IsVoting = false

    return Result
end

function Service.Client:GetVotingOptionData(Player : Player)
    return self.Server.CurrentVotingCategory, self.Server.CurrentVotingOptions
end

function Service.Client:GetVotes(Player : Player)
    return self.Server.CurrentVotes
end

function Service.Client:IsVotingHappening(Player : Player)
    return self.Server.IsVoting
end

function Service.Client:SetVote(Player : Player, VotingOption : number)
    print(VotingOption)
    self.Server.VotesChanged = true
    self.Server.CurrentVotes[Player] = VotingOption
end

return Service
