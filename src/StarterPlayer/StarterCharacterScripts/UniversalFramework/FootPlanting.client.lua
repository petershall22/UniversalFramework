local Player = game.Players.LocalPlayer
local Char = Player.Character
local Humanoid = Char.Humanoid
local RunService = game:GetService("RunService")

local LeftFoot = Char:FindFirstChild("LeftFoot")
local RightFoot = Char:FindFirstChild("RightFoot")
local minWeight = 0.3
local maxWeight = 0.65
local previousLMult = 0
local previousRMult = 0
local IKSet = false
local moving = false
local debounce = false -- to find LastCFrame
local lastLCFrame;
local lastRCFrame;

local LeftIKObj = workspace:FindFirstChild("LeftIK") or Instance.new("Part")
LeftIKObj.CanCollide = false
LeftIKObj.Transparency = .5
LeftIKObj.Color = Color3.new(0,0.4,0.8)
LeftIKObj.Size = Vector3.new(0.4,0.4,0.4)
LeftIKObj.Name = "LeftIK"
LeftIKObj.Parent = workspace

local RightIKObj = workspace:FindFirstChild("RightIK") or Instance.new("Part")
RightIKObj.CanCollide = false
RightIKObj.Transparency = .5
RightIKObj.Color = Color3.new(0,0.4,0.8)
RightIKObj.Size = Vector3.new(0.4,0.4,0.4)
RightIKObj.Name = "RightIK"
RightIKObj.Parent = workspace

local LeftLegIK = Instance.new("IKControl")
local RightLegIK = Instance.new("IKControl")

LeftLegIK.Name = "LeftLegIK"
LeftLegIK.Parent = Char:FindFirstChild("Humanoid")
LeftLegIK.Type = Enum.IKControlType.Position

LeftLegIK.EndEffector = LeftFoot
LeftLegIK.ChainRoot = Char:FindFirstChild("LeftUpperLeg")
LeftLegIK.Pole = LeftIKObj
LeftLegIK.Weight = minWeight
LeftLegIK.Target = LeftIKObj

RightLegIK.Name = "RightLegIK"
RightLegIK.Parent = Char:FindFirstChild("Humanoid")
RightLegIK.Type = Enum.IKControlType.Position

RightLegIK.Weight = minWeight
RightLegIK.Pole = RightIKObj
RightLegIK.EndEffector = RightFoot
RightLegIK.ChainRoot = Char:FindFirstChild("RightUpperLeg")

RightLegIK.Target = RightIKObj

local params = RaycastParams.new()
params.FilterType = Enum.RaycastFilterType.Blacklist
params.FilterDescendantsInstances = {Char,LeftIKObj,RightIKObj,workspace.CurrentCamera} -- workspace camera if you are using a view model

local function checkWalking()
	Humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function()
		if Humanoid.MoveDirection.Magnitude > 0 then
			IKSet = false
			debounce = false
			moving = true
		else
			moving = false
		end
	end)
end

RunService.RenderStepped:Connect(function()
	local minMult = 0.3
	local maxMult = 0.5
	local movingMult = 1
	local changeWeight = 0.4
	local divisor = 1.5
	local allowedRange = 0.05

	local leftY = ((LeftIKObj.CFrame.Position.Y - RightIKObj.CFrame.Position.Y)/divisor) -- roots the square for positive int
	local rightY = ((RightIKObj.CFrame.Position.Y - LeftIKObj.CFrame.Position.Y)/divisor) -- roots the square for positive in
	local leftMult = math.clamp(math.abs(leftY), minMult, maxMult)
	local rightMult = math.clamp(math.abs(rightY), minMult, maxMult)

	if math.abs(leftMult - previousLMult) > allowedRange then
		previousLMult = leftMult
	else
		leftMult = previousLMult
	end

	if math.abs(rightMult - previousRMult) > allowedRange then
		previousRMult = rightMult
	else
		rightMult = previousRMult
	end

	if leftY > changeWeight then
		LeftLegIK.Weight = maxWeight
	else
		LeftLegIK.Weight = minWeight
	end
	if rightY > changeWeight then
		RightLegIK.Weight = maxWeight
	else
		RightLegIK.Weight = minWeight
	end
	
	if moving then
		LeftLegIK.Pole = nil
		RightLegIK.Pole = nil
	else
		LeftLegIK.Pole = LeftIKObj
		RightLegIK.Pole = RightIKObj
	end
	
	if not IKSet then
		local LeftRay = workspace:Raycast(Vector3.new(Char.LeftFoot.Position.X,Char.LeftFoot.Position.Y+2,Char.LeftFoot.Position.Z),Vector3.new(0,-1,0)*300,params)
		if LeftRay then
			LeftIKObj.CFrame = CFrame.new(LeftRay.Position,LeftRay.Normal) + (Char:FindFirstChild("LeftFoot").CFrame.LookVector * leftMult)
			lastLCFrame = CFrame.new(LeftRay.Position,LeftRay.Normal) + (Char:FindFirstChild("LeftFoot").CFrame.LookVector * leftMult)
		end
		local RightRay = workspace:Raycast(Vector3.new(Char.RightFoot.Position.X,Char.RightFoot.Position.Y+2,Char.RightFoot.Position.Z),Vector3.new(0,-1,0)*300,params)
		if RightRay then
			RightIKObj.CFrame = CFrame.new(RightRay.Position,RightRay.Normal) + (Char:FindFirstChild("RightFoot").CFrame.LookVector * rightMult)
			lastRCFrame = CFrame.new(RightRay.Position,RightRay.Normal) + (Char:FindFirstChild("RightFoot").CFrame.LookVector * rightMult)
		end
		if not moving then
			IKSet = true 
		end
	else
		if not debounce then
			local LeftRay = workspace:Raycast(Vector3.new(Char.LeftFoot.Position.X,Char.LeftFoot.Position.Y+2,Char.LeftFoot.Position.Z),Vector3.new(0,-1,0)*300,params)
			if LeftRay then
				LeftIKObj.CFrame = CFrame.new(LeftRay.Position,LeftRay.Normal) + (Char:FindFirstChild("LeftFoot").CFrame.LookVector * leftMult)
				lastLCFrame = CFrame.new(LeftRay.Position,LeftRay.Normal) + (Char:FindFirstChild("LeftFoot").CFrame.LookVector * leftMult)
			end
			local RightRay = workspace:Raycast(Vector3.new(Char.RightFoot.Position.X,Char.RightFoot.Position.Y+2,Char.RightFoot.Position.Z),Vector3.new(0,-1,0)*300,params)
			if RightRay then
				RightIKObj.CFrame = CFrame.new(RightRay.Position,RightRay.Normal) + (Char:FindFirstChild("RightFoot").CFrame.LookVector * rightMult)
				lastRCFrame = CFrame.new(RightRay.Position,RightRay.Normal) + (Char:FindFirstChild("RightFoot").CFrame.LookVector * rightMult)
			end
			debounce = true
		end
		LeftIKObj.CFrame = lastLCFrame
		RightIKObj.CFrame = lastRCFrame
	end
end)

checkWalking()