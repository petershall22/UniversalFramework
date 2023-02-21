local RS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local UniversalFramework = game:GetService("ReplicatedStorage"):WaitForChild("UniversalFramework")
local Knit = require(UniversalFramework.Utility.KnitFramework.Knit)
local Utils = require(UniversalFramework.Utility.FrameworkUtils)
local Systems = UniversalFramework.Systems

local statisticsService = Knit.GetService("Statistics")

local setting = UniversalFramework.Configuration.StatisticsSystem.Stamina
local player = game.Players.LocalPlayer
local char = player.Character
local humanoid = char:WaitForChild("Humanoid")
local staminaFrame = player.PlayerGui.StatsDebug.Stamina.TweenFrame -- place frame to be tweened according to stamina availability
local maxStamina = setting:GetAttribute("MaxStamina")
local stamina = maxStamina
local decrease;
local runEnabled = false
local jumpCooldown = false

-- TODO: Implement jumping, jump cost, and tweening of staminaFrame

local decreaseStamina = function()
	stamina -= setting:GetAttribute("RunningCost")
end

local function endSprint()
	runEnabled = false
	Utils.Hold(0.15)
	humanoid.WalkSpeed = setting:GetAttribute("DefaultWalkSpeed")
end

local function sprint()
	runEnabled = true
	while runEnabled and stamina > setting:GetAttribute("RunningCost") do
		humanoid.WalkSpeed = statisticsService:GetRunSpeed(player)
		decreaseStamina()
		Utils.Hold(1)
	end
	endSprint()
end

-- Player inputs

UIS.InputBegan:Connect(function(input,gpe)
	if not gpe then
		if input.KeyCode == Enum.KeyCode.LeftShift then
			sprint()
		end
	end
end)

UIS.InputEnded:Connect(function(input, gpe)
	if not gpe then
		if input.KeyCode == Enum.KeyCode.LeftShift then
			endSprint()
		end
	end
end)