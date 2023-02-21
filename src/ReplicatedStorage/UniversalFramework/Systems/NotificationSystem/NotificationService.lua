local UniversalFramework = game:GetService("ReplicatedStorage"):WaitForChild("UniversalFramework")
local Knit = require(UniversalFramework.Utility.KnitFramework.Knit)
local Utils = require(UniversalFramework.Utility.FrameworkUtils)
local Systems = UniversalFramework.Systems
local Types = require(Systems.NotificationSystem.Types)

local notificationService = Knit.CreateService {
	Name = "NotificationService",
	Client = {
		CreateNotification = Knit.CreateSignal(),
	}
}

function notificationService:Notify(player, status, message)
	local types = Types.returnTypes()
	if types[status] then
		self.CreateNotification:Fire(player, status, message)
		return true
	else
		error("Status not found, aborting.")
	end
end

return notificationService
