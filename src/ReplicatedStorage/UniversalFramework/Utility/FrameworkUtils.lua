local Utils = {}

local RunService = game:GetService("RunService")

function Utils.Hold(seconds) -- accurate wait
	local Heartbeat = RunService.Heartbeat
	local StartTime = tick()
	repeat Heartbeat:Wait() until tick() - StartTime >= seconds
end

function Utils.repeatFunc(func, waitTime, stopTime)
	local LastTime = tick()
	local repeatFunction = RunService.Heartbeat:Connect(function()
		if tick() - LastTime < waitTime then return end
		if stopTime then
			if tick() - LastTime < stopTime then 
				repeatFunction:Disconnect()
			end
		end
		LastTime = tick()
		func()
	end)
end

function Utils.secToMHMS(s)
	return string.format("%02i months, %02i hours, %02i minutes, %02i seconds", s/2.628e+6, s/3600, s/60%60, s%60)
end

return Utils
