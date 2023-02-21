local UniversalFramework = game:GetService("ReplicatedStorage").UniversalFramework
local Knit = require(UniversalFramework.Utility.KnitFramework.Knit)
local Utils = require(UniversalFramework.Utility.FrameworkUtils)

local statisticsService = Knit.CreateService {
	Name = "Statistics",
}
local notificationService;

local Players = game:GetService("Players")
local DatastoreService = game:GetService("DataStoreService")
local statisticsStore = DatastoreService:GetDataStore("StatisticsStore")
local setting = UniversalFramework.Configuration.StatisticsSystem
local fields = {
	["Credits"] = 0,
	["Tokens"] = 0,
	["Time"] = 0,
	["String"] = ""
}
local playersInfo = {}

local function saveData(player)
	local x = statisticsStore:GetAsync(player.Name)
	x["Time"] += (tick() - x["LastTime"])
	x["Tokens"] = playersInfo[player.Name]["Tokens"]
	x["Credits"] = playersInfo[player.Name]["Credits"]
	statisticsStore:SetAsync(player.Name, x)
end

local function playerInit(player)
	local x = statisticsStore:GetAsync(player.Name) or {}
	for field, v in fields do
		if x[field] == nil then
			if field == "Credits" then
				x["Credits"] = setting:GetAttribute("DefaultCredits")
			elseif field == "Tokens" then
				x["Tokens"] = setting:GetAttribute("DefaultTokens")
			else
				x[field] = v
			end
		end
	end
	x["LastTime"] = tick()
	playersInfo[player.Name] = {}
	playersInfo[player.Name]["Tokens"] = x["Tokens"]
	playersInfo[player.Name]["Credits"] = x["Credits"]
	playersInfo[player.Name]["RunSpeed"] = setting.Stamina:GetAttribute("DefaultRunSpeed")
	print(playersInfo)
	statisticsStore:SetAsync(player.Name, x)
end


local function tokenHandler(player)
	while true do
		local success, response = pcall(function()
			Utils.Hold(setting:GetAttribute("TokenInterval"))
			local increment = setting:GetAttribute("TokenAmountGiven")
			local original = playersInfo[player.Name]["Tokens"]
			local amount = (playersInfo[player.Name]["Tokens"] + increment)
			local message = string.format("You have earned <b>%s tokens</b>, bringing your total to <b><u>%s</u></b>.", increment, amount)
			notificationService:Notify(player, "Tokens", "Tokens added", message)
			playersInfo[player.Name]["Tokens"] = amount
		end)
		if not success then
			print(response)
		end
	end
end

local function creditsHandler(player, amount)
	-- TODO: Add functionality 
end

-- PLAYER EVENTS

Players.PlayerAdded:Connect(function(player)
	playerInit(player)
	tokenHandler(player)
end)

Players.PlayerRemoving:Connect(function(player)
	saveData(player)
	playersInfo[player.Name] = nil
end)

game:BindToClose(function() -- in case of sudden server shutdown
	for i, v in game:GetService("Players"):GetPlayers() do
		saveData(v)
	end
end)

-- KNIT FRAMEWORK

function statisticsService.Client:GetStats(player)
	return statisticsStore:GetAsync(player.Name)
end

function statisticsService.Client:GetTokens(player)
	return playersInfo[player.Name]["Tokens"]
end

function statisticsService.Client:GetCredits(player)
	return playersInfo[player.Name]["Credits"]
end

function statisticsService.Client:GetRunSpeed(player)
	return playersInfo[player.Name]["RunSpeed"] -- if anti-cheat is created, use this to determine whether someone is going above walkspeed
end

-- TODO: Add function to change fields (if numerical, then by numerical value, otherwise by string), expose this to client as well but have a list of moderators that can do this. 

function statisticsService:KnitInit()
end

function statisticsService:KnitStart()
	notificationService = Knit.GetService("NotificationService")
end


return statisticsService
