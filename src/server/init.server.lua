local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Services = Knit.AddServices(script.Services)

Knit.Start():catch(warn)