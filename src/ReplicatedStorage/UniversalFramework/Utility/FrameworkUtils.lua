---@diagnostic disable: undefined-global
local Utils = {}

local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local previousTransparencies = {}

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

local function checkIgnore(v, list)
	local ignore = false
	for i, item in list do
		if v:IsDescendantOf(item) or v == item then
			ignore = true
			break
		end
	end
	return ignore
end

local function checkIgnoreButtons(v, list)
	local ignore = false
	for i, image in list do
		if v:IsDescendantOf(image) or v == image then
			ignore = true
			break
		end
	end
	return ignore
end

function Utils.Hold(seconds: number, cond1, cond2, condition: string) -- accurate wait
	local Heartbeat = RunService.Heartbeat
	local StartTime = tick()
	local condMet = false
	coroutine.wrap(function()
		while not condMet do
			task.wait(0.1)
			local success, err = pcall(function()
				if cond1.Value then
					if condition == "~=" then
						if cond1.Value ~= cond2 then
							condMet = true
						end
					elseif condition == "==" then
						if cond1.Value == cond2 then
							condMet = true
						end
					end
				end
			end)
			if not success then
				if condition == "~=" then
					if cond1 ~= cond2 then
						condMet = true
					end
				elseif condition == "==" then
					if cond1 == cond2 then
						condMet = true
					end
				end
			end
		end
	end)()
	repeat Heartbeat:Wait() until tick() - StartTime >= seconds or condMet
end

function Utils.repeatFunc(func, waitTime: number, stopTime: number)
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

-- TODO: Cleanup the below functions, add a local function to handle tweening.

function Utils.descendantsFadeInTween(object: ObjectValue, ignoreFrames, ignoreImages, ignoreButtons, transitionInfo: TweenInfo, ignore)
	for _, v in object:GetDescendants() do
		local interrupt;
		if ignore then
			interrupt = checkIgnore(v, ignore)
		end
		if not interrupt then
			if v:IsA("TextLabel") then
				v.Visible = true
				local prev;
				if not previousTransparencies[v] then
					previousTransparencies[v] = v.TextTransparency
				end
				v.TextTransparency = 1
				local tween = TweenService:Create(v, transitionInfo, {TextTransparency =  previousTransparencies[v]})
				tween:Play()
			elseif v:IsA("Frame") and v.Name ~= "Template" then
				local ignore = checkIgnoreFrame(v, ignoreFrames)
				if not ignore then
					v.Visible = true
					if not previousTransparencies[v] then
						previousTransparencies[v] = v.BackgroundTransparency
					end
					v.BackgroundTransparency = 1
					local tween = TweenService:Create(v, transitionInfo, {BackgroundTransparency = previousTransparencies[v]})
					tween:Play()
				end
			elseif v:IsA("UIStroke") then
				if previousTransparencies[v] then
					local tween = TweenService:Create(v, transitionInfo, {Transparency = previousTransparencies[v]})
					tween:Play()
				else
					previousTransparencies[v] = v.Transparency
					local tween = TweenService:Create(v, transitionInfo, {Transparency = previousTransparencies[v]})
					tween:Play()
				end
			elseif v:IsA("ImageLabel") then
				local ignore = checkIgnoreImages(v, ignoreImages)
				if not previousTransparencies[v] then
					previousTransparencies[v] = v.ImageTransparency
				end
				if not ignore then
					v.Visible = true
					v.ImageTransparency = 1
					local tween = TweenService:Create(v, transitionInfo, {ImageTransparency =  previousTransparencies[v]})
					tween:Play()
				end
			elseif v:IsA("ScrollingFrame") then
				v.Visible = true
				if not previousTransparencies[v] then
					previousTransparencies[v] = v.ScrollBarImageTransparency
				end
				v.ScrollBarImageTransparency = 1
				local tween = TweenService:Create(v, transitionInfo, {ScrollBarImageTransparency = previousTransparencies[v]})
				tween:Play()
			elseif v:IsA("TextButton") then
				local ignore = checkIgnoreButtons(v, ignoreButtons)
				if not ignore then
					v.Visible = true
					local prev;
					if previousTransparencies[v] then
						prev = previousTransparencies[v]
					else
						previousTransparencies[v] = {v.TextTransparency, v.BackgroundTransparency}
						prev = previousTransparencies[v]
					end
					v.TextTransparency = 1
					local tween1 = TweenService:Create(v, transitionInfo, {TextTransparency = prev[1]})
					tween1:Play()
					local tween2 = TweenService:Create(v, transitionInfo, {BackgroundTransparency = prev[2]})
					tween2:Play()
				end
			end
		end
	end
end

function Utils.descendantsFadeOutTween(object: ObjectValue, ignoreFrames, ignoreImages, ignoreButtons, transitionInfo: TweenInfo)
	for i, v in object:GetDescendants() do
		if v:IsA("TextLabel") then
			if not previousTransparencies[v] then
				previousTransparencies[v] = v.TextTransparency
			end
			local tween = TweenService:Create(v, transitionInfo, {TextTransparency = 1})
			tween:Play()
			tween.Completed:Connect(function()
				v.Visible = false
			end)
		elseif v:IsA("Frame") and (v.Name ~= "Buttons" or v.Name ~= "Template") then
			local ignore = checkIgnoreFrame(v, ignoreFrames)
			if not ignore then
				previousTransparencies[v] = v.BackgroundTransparency
				local tween = TweenService:Create(v, transitionInfo, {BackgroundTransparency = 1})
				tween:Play()
				tween.Completed:Connect(function()
					v.Visible = false
				end)
			end
		elseif v:IsA("UIStroke") then
			if not previousTransparencies[v] then
				previousTransparencies[v] = v.Transparency
			end
			local tween = TweenService:Create(v, transitionInfo, {Transparency = 1})
			tween:Play()
		elseif v:IsA("ImageLabel") then
			if not previousTransparencies[v] then
				previousTransparencies[v] = v.ImageTransparency
			end
			local ignore = checkIgnoreImages(v, ignoreImages)
			if not ignore then
				local tween = TweenService:Create(v, transitionInfo, {ImageTransparency = 1})
				tween:Play()
				tween.Completed:Connect(function()
					v.Visible = false
				end)
			end
		elseif v:IsA("ScrollingFrame") then
			if not previousTransparencies[v] then
				previousTransparencies[v] = v.ScrollBarImageTransparency
			end
			local tween = TweenService:Create(v, transitionInfo, {ScrollBarImageTransparency = 1})
			tween:Play()
			tween.Completed:Connect(function()
				v.Visible = false
			end)
		elseif v:IsA("TextButton") then
			local ignore = checkIgnoreButtons(v, ignoreButtons)
			if not previousTransparencies[v] then
				previousTransparencies[v] = {v.TextTransparency, v.BackgroundTransparency} 
			end
			if not ignore then
				local tween1 = TweenService:Create(v, transitionInfo, {TextTransparency = 1})
				tween1:Play()
				local tween2 = TweenService:Create(v, transitionInfo, {BackgroundTransparency = 1})
				tween2:Play()
				tween1.Completed:Connect(function()
					v.Visible = false
				end)
			end
		end
	end
end

return Utils
