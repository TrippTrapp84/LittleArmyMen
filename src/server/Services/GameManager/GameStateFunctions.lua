local Functions = {}


function Functions.ServerStarted___InLobby(self)
    self:SetupServer()
    self:PrepareMatch()
end

function Functions.InLobby___InMatch(self)
    self:StartMatch()
end

function Functions.InLobby___ServerEnded(self)
    self:CleanupServer()
end

function Functions.InMatch___ServerEnded(self)
    self:EndMatch()
    self:CleanupServer()
end

function Functions.InMatch___InLobby(self)
    self:EndMatch()
    self:PrepareMatch()
end

return Functions

