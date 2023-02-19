local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local StateMachine = require(ReplicatedStorage.shared.StateMachine)
local StateChangedFunctions = require(script.GameStateFunctions)

local Service = Knit.CreateService{
    Name = "GameManager"
}

local GameStateData = {
    ServerStarted = {
        StartGame = "InLobby"
    },
    InLobby = {
        StartMatch = "InMatch",
        EndServer = "ServerEnded"
    },
    InMatch = {
        EndMatch = "InLobby",
        EndServer = "ServerEnded"
    },
    ServerEnded = {}
}

function Service:KnitInit()
    self.GameStateMachine = StateMachine.new(GameStateData,"ServerStarted")
    self.VotingService = Knit.GetService("VotingService")
    self.MapLoadingService = Knit.GetService("MapLoadingService")

    self.GameStateMachine:BindCallbackToStateChange(function(State, NewState, Action)
        StateChangedFunctions[State .. "___" .. NewState](self  )
    end)

    self.CurrentGamemode = nil
    self.Gamemodes = {}
    for _,Gamemode : ModuleScript in pairs(script.Gamemodes:GetChildren()) do
        if not Gamemode:IsA("ModuleScript") then continue end
        local GamemodeRef = require(Gamemode)
        self.Gamemodes[GamemodeRef.Name] = GamemodeRef
    end

    print("Gamemodes: ",self.Gamemodes)

    self.Connections = {}
end

function Service:KnitStart()
    self.GameStateMachine:PerformAction("StartGame")
end

function Service:GetNextMatchData()
    --//TODO: Make voting options be picked from the list of available maps and gamemodes instead of hardcoded, this is cringy
    local NextMap = ReplicatedStorage.Assets.Maps[self.VotingService:BeginVoting("Map",{"HugeHouse"},10)]
    local NextGamemode = self.Gamemodes[self.VotingService:BeginVoting("Gamemode",{"Team Deathmatch"},10)]
    return NextMap,NextGamemode
end

function Service:SetMap(Map : Instance)
    self.MapLoadingService:LoadMap(Map)
end

function Service:ClearMap()
    self.MapLoadingService:UnloadMap()
end

function Service:SetGamemode(Gamemode)
    self.CurrentGamemode = Gamemode
end

function Service:StartGamemode()
    self.CurrentGamemode:StartMatch()
end

function Service:EndGamemode()
    self.CurrentGamemode:EndMatch()
end

do --// STATE CALLBACK FUNCTIONS
    function Service:SetupServer()
        --//TODO: start other systems necessary for server beginning
    end
    
    function Service:PrepareMatch()
        local NextMap,NextGamemode = self:GetNextMatchData()

        self:SetMap(NextMap)
        self:SetGamemode(NextGamemode)
        self.GameStateMachine:PerformAction("StartMatch")
    end
    
    function Service:StartMatch()
        self:StartGamemode()
    end
    
    function Service:EndMatch()
        self:ClearMap()
        self:EndGamemode()
    end
    
    function Service:CleanupServer()
        self:ClearMap()
        self:EndGamemode()
        --//TODO: add data force cleanup here
    end
end

return Service