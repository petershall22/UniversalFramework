local TrelloAPI = require(game.ServerScriptService.UniversalFramework.TrelloAPI)
local listID = TrelloAPI.BoardsAPI.GetListID("NscRXZhs", "Updates")
local cards = TrelloAPI.CardsAPI.GetCardsOnList(listID)
print(cards)