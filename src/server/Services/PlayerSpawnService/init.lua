local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Service = Knit.CreateService{
    Name = "PlayerSpawnService",
    Client = {
        PlayerLoaded = Knit.CreateSignal(),
        PlayerSpawned = Knit.CreateSignal(),
        PlayerUnloading = Knit.CreateSignal(),

        TeamsLoaded = Knit.CreateSignal(),
        TeamsReset = Knit.CreateSignal()
    }
}

local SPAWN_OFFSET = Vector3.new(0,4,0)

function Service:KnitInit()
    self.LoadedPlayers = {}
    self.Teams = {}
    self.PlayerTeams = {}
    self.AllowSpawns = false

    self.TeamSpawnLocations = {}
    self.DynamicSpawnLocations = {}

    self.Connections = {}
end

function Service:KnitStart()
    self.Connections.PlayerAdded = game.Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function(char)
            char:WaitForChild("Humanoid").Died:Connect(function()
                task.wait(1)
                player.Character = nil :: Model
            end)
        end)
    end)
end

function Service:LoadPlayer(Player : Player) : Model
    self.Client.PlayerLoaded:Fire(Player)
    print("Fired Player Loaded")
    Player:LoadCharacter()
    local Character = Player.Character or Player.CharacterAdded:Wait()
    self.LoadedPlayers[Player] = Character
    return Character
end

function Service:UnloadPlayer(Player : Player)
    if not self.LoadedPlayers[Player] then return end

    self.LoadedPlayers[Player] = nil
    if not Player.Character then return end


    self.Client.PlayerUnloading:Fire(Player)
    Player.Character = nil :: Model
end

function Service:LoadMapSpawns(Map : Folder & {Spawns : any})
    self.DynamicSpawnLocations = Map.Spawns.DynamicSpawns:GetChildren()
    for i,v in pairs(Map.Spawns.TeamSpawns:GetChildren()) do
        self.TeamSpawnLocations[v.Name] = v:GetChildren()
    end
end

function Service:PickDynamicSpawnLocation()
    return self.DynamicSpawnLocations[math.random(1,#self.DynamicSpawnLocations)]
end

function Service:PickTeamSpawnLocation(Team : string)
    return self.TeamSpawnLocations[Team][math.random(1,#self.TeamSpawnLocations[Team])]
end

function Service:SpawnPlayer(Player : Player)
    local SpawnLocation : BasePart
    if self.PlayerTeams[Player] then
        SpawnLocation = self:PickTeamSpawnLocation(self.PlayerTeams[Player])
    else
        SpawnLocation = self:PickDynamicSpawnLocation()
    end

    local Character = self:LoadPlayer(Player);
    (Character:WaitForChild("HumanoidRootPart") :: Part).CFrame = CFrame.new(SpawnLocation.Position + SPAWN_OFFSET)
    self.Client.PlayerSpawned:Fire(Player)
end

function Service:UnloadMapSpawns()
    self.TeamSpawnLocations = {}
    self.DynamicSpawnLocations = {}
end

function Service:LoadTeams(TeamNames : {string})
    for _,TeamName in pairs(TeamNames) do
        self.Teams[TeamName] = {}
    end

    self.Client.TeamsLoaded:FireAll(TeamNames)
end

function Service:ResetTeams()
    for TeamName,TeamRoster in pairs(self.Teams) do
        for _,Player in pairs(TeamRoster) do
            self:UnloadPlayer(Player)
        end
    end
    self.Teams = {}
    self.PlayerTeams = {}

    self.Client.TeamsReset:FireAll()
end

function Service:SetPlayerTeam(Player : Player,Team : string?)
    local CurrentTeam = self.PlayerTeams[Player]
    if Team == CurrentTeam then return end

    if CurrentTeam then
        table.remove(self.Teams[CurrentTeam],table.find(self.Teams[CurrentTeam],Player))
        self.PlayerTeams[Player] = nil
    end

    if Team then
        table.insert(self.Teams[Team],Player)
        self.PlayerTeams[Player] = Team
    end

    self:UnloadPlayer(Player)
end

function Service:SetSpawnsAllowed(Allowed : boolean)
    print("Set AllowSpawns to:",Allowed)
    self.AllowSpawns = Allowed
end

function Service:GetPlayerTeam(Player : Player)
    return self.PlayerTeams[Player]
end

function Service:GetTeamPlayers(Team : string)
    return self.Teams[Team]
end

function Service.Client:SetTeam(Player : Player, Team : string)
    if (not Team) or (not self.Server.Teams[Team]) then return end
    self.Server:SetPlayerTeam(Player,Team)
end

function Service.Client:RequestSpawn(Player : Player)
    if not self.Server.AllowSpawns then return end
    if self.Server.LoadedPlayers[Player] then return end
    self.Server:SpawnPlayer(Player)
end

return Service