local UniversalFramework = game:GetService("ReplicatedStorage").UniversalFramework
local Knit = require(UniversalFramework.Utility.KnitFramework.Knit)
local Utils = require(UniversalFramework.Utility.FrameworkUtils)
local Systems = UniversalFramework.Systems
local RS = game:GetService("ReplicatedStorage")

require(Systems.characterLookAtCore.characterLookAtService)
require(Systems.StatisticsSystem.StatisticsService)
require(Systems.InteractionSystem.InteractionService)

Knit.Start()