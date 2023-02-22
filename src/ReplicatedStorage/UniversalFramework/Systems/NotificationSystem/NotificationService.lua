local UniversalFramework = game:GetService("ReplicatedStorage"):WaitForChild("UniversalFramework")
local Knit = require(UniversalFramework.Utility.KnitFramework.Knit)
local Types = require(UniversalFramework.Configuration.NotificationSystem.Types)

local notificationService = Knit.CreateService {
	Name = "NotificationService",
	Client = {
		CreateNotification = Knit.CreateSignal(),
	}
}

function notificationService:Notify(player, status, message)
	local types = Types.returnTypes()
	if types[status] then
		self.Client.CreateNotification:Fire(player, status, message)
		return true
	else
		error("Status not found, aborting.")
	end
end

function notificationService:NotifyAll(status, message)
	local types = Types.returnTypes()
	for i, player in game:GetService("Players"):GetPlayers() do
		if types[status] then
			self.Client.CreateNotification:Fire(player, status, message)
			return true
		else
			error("Status not found, aborting.")
		end
	end
end

return notificationService
