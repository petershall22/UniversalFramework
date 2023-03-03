---@diagnostic disable: undefined-global
local Utils = {}

local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

function Utils.Hold(seconds, cond1, cond2, condition) -- accurate wait
	local Heartbeat = RunService.Heartbeat
	local StartTime = tick()
	local condMet = false
	coroutine.wrap(function()
		while not condMet do
			task.wait(0.1)
			if cond1 then
				if condition == "~=" then
					if cond1 ~= cond2 then
						condMet = true
					end
				end
			end
		end
	end)()
	repeat Heartbeat:Wait() until tick() - StartTime >= seconds or condMet
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

local function checkIgnoreFrame(v, list)
    local ignore = false
    for i, frame in list do
        if v:IsDescendantOf(frame) or v == frame then
            ignore = true
            break
        end
    end
    return ignore
end

local function checkIgnoreImages(v, list)
    local ignore = false
    for i, image in list do
        if v:IsDescendantOf(image) or v == image then
            ignore = true
            break
        end
    end
    return ignore
end

function Utils.descendantsFadeInTween(object, ignoreFrames, ignoreImages, transitionInfo)
    for i, v in object:GetDescendants() do
        if v:IsA("TextLabel") then
			v.Visible = true
            v.TextTransparency = 1
            local tween = TweenService:Create(v, transitionInfo, {TextTransparency = 0})
            tween:Play()
        elseif v:IsA("Frame") then
            local ignore = checkIgnoreFrame(v, ignoreFrames)
            if not ignore then
				v.Visible = true
                v.BackgroundTransparency = 1
                local tween = TweenService:Create(v, transitionInfo, {BackgroundTransparency = 0})
                tween:Play()
            end
        elseif v:IsA("ImageLabel") then
            local ignore = checkIgnoreImages(v, ignoreImages)
            if not ignore then
				v.Visible = true
                v.ImageTransparency = 1
                local tween = TweenService:Create(v, transitionInfo, {ImageTransparency = 0})
                tween:Play()
            end
        elseif v:IsA("ScrollingFrame") then
			v.Visible = true
            v.ScrollBarImageTransparency = 1
            local tween = TweenService:Create(v, transitionInfo, {ScrollBarImageTransparency = 0})
            tween:Play()
        elseif v:IsA("TextButton") then
			v.Visible = true
            v.TextTransparency = 1
            local tween = TweenService:Create(v, transitionInfo, {TextTransparency = 0})
            tween:Play()
        end
    end
end

function Utils.descendantsFadeOutTween(object, ignoreFrames, ignoreImages, transitionInfo) 
    for i, v in object:GetDescendants() do
        if v:IsA("TextLabel") then
            local tween = TweenService:Create(v, transitionInfo, {TextTransparency = 1})
            tween:Play()
			tween.Completed:Connect(function()
				v.Visible = false
			end)
        elseif v:IsA("Frame") and v.Name ~= "Buttons" then
            local ignore = checkIgnoreFrame(v, ignoreFrames)
            if not ignore then
                local tween = TweenService:Create(v, transitionInfo, {BackgroundTransparency = 1})
                tween:Play()
				tween.Completed:Connect(function()
					v.Visible = false
				end)
            end
        elseif v:IsA("ImageLabel") then
            local ignore = checkIgnoreImages(v, ignoreImages)
            if not ignore then
                local tween = TweenService:Create(v, transitionInfo, {ImageTransparency = 1})
                tween:Play()
				tween.Completed:Connect(function()
					v.Visible = false
				end)
            end
        elseif v:IsA("ScrollingFrame") then
            local tween = TweenService:Create(v, transitionInfo, {ScrollBarImageTransparency = 1})
            tween:Play()
			tween.Completed:Connect(function()
				v.Visible = false
			end)
        elseif v:IsA("TextButton") then
            local tween = TweenService:Create(v, transitionInfo, {TextTransparency = 1})
            tween:Play()
			tween.Completed:Connect(function()
				v.Visible = false
			end)
        end
    end
end

return Utils
