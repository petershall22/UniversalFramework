local UniversalFramework = game:GetService("ReplicatedStorage"):WaitForChild("UniversalFramework")
local UIS = game:GetService("UserInputService")
local Knit = require(UniversalFramework.Utility.KnitFramework.Knit)
local Utils = require(UniversalFramework.Utility.FrameworkUtils)
local PromptService = game:GetService("ProximityPromptService")
local Systems = UniversalFramework.Systems
local InteractionSystem = Systems.InteractionSystem
local InteractionService = Knit.GetService("InteractionService")
local locations = {}

local player = game.Players.LocalPlayer

local function initialise()
	for i, prompt in locations do
		prompt:Destroy()
	end
	local doors, promptPart = InteractionService:GetAllowedDoors(player)
	for i, v in doors do
		local interactKeybind = UniversalFramework.Utility.Keybind:InvokeServer("DoorInteract")
		local clone = script.DoorInteraction:Clone()
		clone.ActionText = string.format("%s %s", v.DoorStatus.Action.Value, v.Name)
		clone.KeyboardKeyCode = Enum.KeyCode[interactKeybind]
		clone.Parent = promptPart[i]
		locations[promptPart[i]] = clone
		v.DoorStatus.Action.Changed:Connect(function()
			clone.ActionText = string.format("%s %s", v.DoorStatus.Action.Value, v.Name)
		end)
	end
end

PromptService.PromptTriggered:Connect(function(prompt)
	InteractionService:DoorInteracted(prompt.Parent)
end)

player:GetPropertyChangedSignal("Team"):Connect(function()
	initialise()
end)

--TODO: Add server to client signal to call initialise

initialise()