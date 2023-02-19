local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Controllers = Knit.AddControllers(script.Controllers)

Knit.Start():catch(warn)