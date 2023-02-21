local UniversalFramework = game:GetService("ReplicatedStorage"):WaitForChild("UniversalFramework")
local PromptService = game:GetService("ProximityPromptService")
local Knit = require(UniversalFramework.Utility.KnitFramework.Knit)
local Utils = require(UniversalFramework.Utility.FrameworkUtils)
local Systems = UniversalFramework.Systems

local Doors = {}

local objects = {
	["Door"] = "Anim.DoorBase",
}

local interactionService = Knit.CreateService {
	Name = "InteractionService"
}

local DoorLocation = workspace:WaitForChild("Doors")

local function changePerms(player, playerChange, permission) -- player, playerChange, {["Open"] = true}
	for i, v in Doors do
		if v["Owner"] == player then
			v["Permissions"][playerChange] = permission
		end
	end
end

local function ownDoor(player, door) -- only allow this to be called by the server (avoid exploiters)
	Doors[door]["Owner"] = player
end

local function initialiseDoors()
	for i, v in DoorLocation:GetChildren() do
		pcall(function()
			if v.Name == "Door" then
				local clone = script.DoorSetup:Clone()
				clone.Parent = v.Anim
				clone.Enabled = true
				Doors[v] = {}
				Doors[v]["Owner"] = ""
				Doors[v]["Permissions"] = {} -- TODO: Inside table is ["PlayerName"] = { ["Open"] = true, ["Lock"] = false }
				Doors[v]["Purchasable"] = v.Settings.Purchasable.Value
			end
		end)
	end
end


local function getAllowedDoors(player)
	local doors = {}
	local promptPart = {}
	for i, v in DoorLocation:GetChildren() do
		local success, err = pcall(function()
			if objects[v.Name] then
				local split = string.split(objects[v.Name], ".")
				local location = v
				for i, v in split do
					location = location[v]
				end
				if Doors[v]["Owner"] == player then
					table.insert(doors, v)
					table.insert(promptPart, location)
				elseif Doors[v]["Owner"] ~= "" and Doors[v]["Permissions"][player.Name] then
					if Doors[v]["Permissions"][player.Name]["Open"] == true then
						table.insert(doors, v)
						table.insert(promptPart, location)
					end
				elseif v.Settings.Teams.Value ~= "" then
					local teamsList = string.split(v.Settings.Teams.Value, ",")
					if v.Settings.GroupId.Value ~= 0  then
						if table.find(teamsList, player.Team.Name) and (player:GetRankInGroup(v.Settings.GroupId.Value) >= v.Settings.RankReq.Value) then
							table.insert(doors, v)
							table.insert(promptPart, location)
						end
					elseif table.find(teamsList, player.Team.Name) then
						table.insert(doors, v)
						table.insert(promptPart, location)
					end					
				elseif not Doors[v]["Purchasable"] then
					table.insert(doors, v)
					table.insert(promptPart, location)
				end
			end
		end)
		if not success then
			print(err)
		end
	end
	return doors, promptPart
end

local function doorHandler(player, promptPart)
	if promptPart.Name == "DoorBase" then
		local doors, doorPrompt = getAllowedDoors(player)
		if table.find(doorPrompt, promptPart) and (player.Character.HumanoidRootPart.Position.Magnitude - promptPart.Position.Magnitude) < 15 then
			local door = doors[table.find(doorPrompt, promptPart)]
			if door.DoorStatus.Action.Value == "Open" then
				door.DoorStatus.Action.Value = "Close"
				door.Anim.DoorBase.HingeConstraint.TargetAngle = 90
				door.Open:Play()
			else
				door.DoorStatus.Action.Value = "Open"
				door.Anim.DoorBase.HingeConstraint.TargetAngle = 0
				door.Close:Play()
			end
		else
			player:Kick("You have been kicked for potentially being an exploiter. If you think this was a mistake, contact a developer.")
		end
	end
end

function interactionService:PurchaseDoor(player, door)
	return ownDoor(player, door)
end

function interactionService.Client:GetAllowedDoors(player)
	return getAllowedDoors(player)
end

function interactionService.Client:DoorInteracted(player, promptPart)
	doorHandler(player, promptPart)
end

initialiseDoors()

return interactionService
