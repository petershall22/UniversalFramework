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
    local amount = 0
    for i, v in devlogCards do
        cardInfos[i] = {}
        local card = cardInfos[i]
        local split = string.split(v["desc"], "||")
        card["image"] = removeWhitespace(split[1])
        card["briefDesc"] = removeWhitespace(split[2])
        card["desc"] = removeWhitespace(split[3])
        card["title"] = v["name"]
        amount = i
    end
    return cardInfos, amount
end

UniversalFramework.Utility.Devlogs.OnServerInvoke = returnDevlogs
UniversalFramework.Utility.GameVersion.OnServerInvoke = returnGameVersion