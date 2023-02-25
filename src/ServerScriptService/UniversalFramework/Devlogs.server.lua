local UniversalFramework = game:GetService("ReplicatedStorage"):WaitForChild("UniversalFramework")
local TrelloAPI = require(game.ServerScriptService.UniversalFramework.TrelloAPI)
local listID = TrelloAPI.BoardsAPI.GetListID("NscRXZhs", "Updates")
local cards = TrelloAPI.CardsAPI.GetCardsOnList(listID)

local function removeWhitespace(string)
    string = string.gsub(string, "^%s+", "")
    string = string.gsub(string, "%s+$", "")

    return string
end

local function returnDevlogs()
    local cardInfos = {}
    for i, v in cards do
        cardInfos[i] = {}
        local split = string.split(v["desc"], "||")
        cardInfos[i]["image"] = removeWhitespace(split[1])
        cardInfos[i]["briefDesc"] = removeWhitespace(split[2])
        cardInfos[i]["desc"] = removeWhitespace(split[3])
        cardInfos[i]["title"] = v["name"]
    end
    return cardInfos
end

UniversalFramework.Utility.Devlogs.OnServerInvoke = returnDevlogs