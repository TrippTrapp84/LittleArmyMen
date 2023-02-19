local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Service = Knit.CreateService{
    Name = "DataService",
    Client = {}
}

local DATA_STORE_ID = "TrippTrappTestDS" --// TODO: Change DS ID to something more secure

local function DefaultData()
    return {

    }
end

function Service:KnitInit()
    self.DataStore = DataStoreService:GetDataStore(DATA_STORE_ID)
    self.PlayerData = {}

    self.Connections = {}
end

function Service:KnitStart()
    self.Connections.PlayerAdded = game.Players.PlayerAdded:Connect(function(Player : Player)
        self:OnPlayerAdded(Player)
    end)

    self.Connections.PlayerAdded = game.Players.PlayerRemoving:Connect(function(Player : Player)
        self:OnPlayerRemoving(Player.UserId)
    end)
    
end

function Service:GetAsync(Index : any,RetryCount : number) : (boolean, any)
    if RetryCount > 2 then return false end

    local Success,Data = pcall(self.DataStore.GetAsync,self.DataStore,Index)
    if Success then return true, Data end
    return self:GetAsync(Index,RetryCount + 1)
end

function Service:SetAsync(Index : any,Value : any, RetryCount : number) : boolean
    if RetryCount > 2 then return false end

    local Success = pcall(self.DataStore.SetAsync,self.DataStore,Index,Value)
    if Success then return true end
    return self:SetAsync(Index,Value,RetryCount + 1)
end

function Service:Set(PlayerId : number,Data : any)
    self.PlayerData[PlayerId] = Data
end

function Service:Get(PlayerId : number) : (boolean,any)
    if not self.PlayerData[PlayerId] then return false end

    return true,self.PlayerData[PlayerId]
end

function Service:OnPlayerAdded(Player : Player)
    local DataExists,PlayerData = self:GetAsync(Player.UserId,0)
    if not DataExists then Player:Kick("Could not load PlayerData, please rejoin. If this error persists, contact the owner for assistance.") end
    if not PlayerData then PlayerData = DefaultData() end
    self.PlayerData[Player.UserId] = PlayerData
end

function Service:OnPlayerRemoving(PlayerId : number)
    --//TODO: handle data not being saved properly
    self:SetAsync(PlayerId,self.PlayerData[PlayerId],0)
    self.PlayerData[PlayerId] = nil
end

return Service