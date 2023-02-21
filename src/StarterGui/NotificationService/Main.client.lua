local UniversalFramework = game:GetService("ReplicatedStorage"):WaitForChild("UniversalFramework")
local TweenService = game:GetService("TweenService")
local Knit = require(UniversalFramework.Utility.KnitFramework.Knit)
local Utils = require(UniversalFramework.Utility.FrameworkUtils)
local Types = require(UniversalFramework.Configuration.NotificationService.Types)

local notificationService = Knit.GetService("NotificationService")
local gui = script.Parent.MainFrame

-- Information about the tween
local notificationTweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
local startPosX = 1.2
local holdingTime = 5
--

notificationService.CreateNotification:Connect(function(status, title, message)
	local posY = gui.Notif.Body.Position.Y.Scale
	local endPosX = gui.Notif.Body.Position.X.Scale
	local startPos = UDim2.new(startPosX, 0, posY, 0)
	local endGoal = UDim2.new(endPosX, 0, posY, 0)

	local types = Types.returnTypes()
	local clone = gui.Notif:Clone()

	clone.Body.Position = startPos
	clone.Body.StatusImage.ImageColor3 = types[status]["Color"]
	clone.Body.Status.BackgroundColor3 = types[status]["Color"]
	clone.Body.Status.Misc.BackgroundColor3 = types[status]["Color"]
	clone.Body.StatusImage.Image = types[status]["Image"]
	clone.Notification.SoundId = types[status]["Sound"]
	clone.Body.Status.Status.Text = title
	clone.Body.Body.Text = message
	clone.Visible = true
	clone.Parent = gui

	local tweenIn = TweenService:Create(clone.Body, notificationTweenInfo, { Position = endGoal })
	tweenIn:Play()
	clone.Notification:Play()
	tweenIn.Completed:Connect(function()
		Utils.Hold(holdingTime)
		local tweenOut = TweenService:Create(clone.Body, notificationTweenInfo, { Position = startPos })
		tweenOut:Play()
		tweenOut.Completed:Connect(function()
			clone:Destroy()
		end)
	end)

end)