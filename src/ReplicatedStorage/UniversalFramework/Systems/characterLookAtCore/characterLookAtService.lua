local UniversalFramework = game:GetService("ReplicatedStorage").UniversalFramework
local Knit = require(UniversalFramework.Utility.KnitFramework.Knit)
local Utils = require(UniversalFramework.Utility.FrameworkUtils)
local core = script.Parent

local lookAt = require(core.lookAt);
local lookAts = {};

local characterLookAt = Knit.CreateService {
	Name = "CharacterLookAt",
}

function characterLookAt:Update(player, target)
	if (lookAt[player]) then
		lookAt[player]:calcGoal(target);
	end
	return 0
end

function characterLookAt:Init(player, character, humanoid)
	lookAt[player] = lookAt.new(character);

	local hb = game:GetService("RunService").Heartbeat:Connect(function(dt)
		lookAt[player]:update(dt)
	end)

	humanoid.Died:Connect(function()
		hb:Disconnect();
	end)
	return 0
end

function characterLookAt.Client:Init(player, character, humanoid)
	return self.Server:Init(player, character, humanoid)
end

function characterLookAt.Client:Update(player, target)
	return self.Server:Update(player, target)
end

function characterLookAt:KnitInit()
end

function characterLookAt:KnitStart()
end

return characterLookAt