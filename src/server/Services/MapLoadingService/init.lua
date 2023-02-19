local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Service = Knit.CreateService{
    Name = "MapLoadingService",
    Client = {}
}

function Service:KnitInit()
    self.CurrentMap = nil

    self.PlayerSpawnService = Knit.GetService("PlayerSpawnService")

    self.Connections = {}
end

function Service:KnitStart()

end

function Service:LoadMap(Map : Folder)
    if self.CurrentMap then self:UnloadMap() end
    self.CurrentMap = Map--//TODO: load map
    self.CurrentMap.Parent = workspace

    self.PlayerSpawnService:LoadMapSpawns(self.CurrentMap)
end

function Service:UnloadMap()
    if not self.CurrentMap then return end
    self.CurrentMap.Parent = ReplicatedStorage.Assets.Maps
    self.CurrentMap = nil
    self.PlayerSpawnService:UnloadMapSpawns()
    --//TODO: unload current map
end

function Service:GetMapTeams() : {string}
    local Teams = {}
    for i,v in pairs(self.CurrentMap.Spawns.TeamSpawns:GetChildren()) do
        Teams[i] = v.Name
    end

    return Teams
end

return Service