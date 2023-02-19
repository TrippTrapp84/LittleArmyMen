local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local PlayerSpawnService = Knit.GetService("PlayerSpawnService")
local MapLoadingService = Knit.GetService("MapLoadingService")

local Gamemode = {
    Name = "Team Deathmatch",
    Description = "Funny kill players haha"
}

function Gamemode:StartMatch()

    self.Teams = MapLoadingService:GetMapTeams()
    PlayerSpawnService:LoadTeams(self.Teams)
    PlayerSpawnService:SetSpawnsAllowed(true)

    self.Connections = {}
end

function Gamemode:EndMatch()
    PlayerSpawnService:SetSpawnsAllowed(false)
    PlayerSpawnService:ResetTeams()
end

return Gamemode