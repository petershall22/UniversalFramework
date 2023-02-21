local UniversalFramework = game:GetService("ReplicatedStorage"):WaitForChild("UniversalFramework")
local Knit = require(UniversalFramework.Utility.KnitFramework.Knit)
local Utils = require(UniversalFramework.Utility.FrameworkUtils)
local Systems = UniversalFramework.Systems

local player = game.Players.LocalPlayer
local statisticsService = Knit.GetService("Statistics")
local gui = script.Parent
local x = statisticsService:GetStats(player)

local timer = function()
		local spent = x["Time"]
		local currentRange = tick() - x["LastTime"]
		local seconds = math.floor(spent + currentRange)
		gui.Time.Text = Utils.secToMHMS(seconds)
end

local tokens = function()
	gui.Tokens.Text = statisticsService:GetTokens(player)
	Utils.Hold(UniversalFramework.Configuration.StatisticsSystem:GetAttribute("TokenInterval"))
end


Utils.repeatFunc(tokens, 1)
Utils.repeatFunc(timer, 0.1)