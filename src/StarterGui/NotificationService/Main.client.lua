local UniversalFramework = game:GetService("ReplicatedStorage"):WaitForChild("UniversalFramework")
local TweenService = game:GetService("TweenService")
local Knit = require(UniversalFramework.Utility.KnitFramework.Knit)
local Utils = require(UniversalFramework.Utility.FrameworkUtils)
local Systems = UniversalFramework.Systems
local Types = require(Systems.NotificationSystem.Types)

local notificationService = Knit.GetService("NotificationService")

local gui = script.Parent

notificationService.CreateNotification:Connect(function(player, status, message)
	local types = Types.returnTypes()
	local clone = gui.Template:Clone()
	clone.Status.BackgroundColor = types[status]["Color"]
	clone.Status.Status.Text = status
end)