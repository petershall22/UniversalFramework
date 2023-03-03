local UniversalFramework = game:GetService("ReplicatedStorage"):WaitForChild("UniversalFramework")
local TrelloAPI = require(game.ServerScriptService.UniversalFramework.TrelloAPI)
local devlogListID = TrelloAPI.BoardsAPI.GetListID("NscRXZhs", "Updates")
local gameVerListID = TrelloAPI.BoardsAPI.GetListID("NscRXZhs", "Game Version")
local devlogCards = TrelloAPI.CardsAPI.GetCardsOnList(devlogListID)
local gameVersion = TrelloAPI.CardsAPI.GetCardOnList(gameVerListID, "Current Game Version")


local function removeWhitespace(string)
    string = string.gsub(string, "^%s+", "")
    string = string.gsub(string, "%s+$", "")

    return string
end

local function returnGameVersion()
    return gameVersion["desc"]
end

local function returnDevlogs()
    local cardInfos = {}
    for i, v in devlogCards do
        local title = v["name"]
        cardInfos[title] = {}
        local split = string.split(v["desc"], "||")
        cardInfos[title]["image"] = removeWhitespace(split[1])
        cardInfos[title]["briefDesc"] = removeWhitespace(split[2])
        cardInfos[title]["desc"] = removeWhitespace(split[3])
        cardInfos[title]["title"] = v["name"]
    end
    return cardInfos
end

UniversalFramework.Utility.Devlogs.OnServerInvoke = returnDevlogs
UniversalFramework.Utility.GameVersion.OnServerInvoke = returnGameVersion