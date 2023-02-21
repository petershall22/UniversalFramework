local RunService = game:GetService("RunService");
local Player = game.Players.LocalPlayer;
local Character = Player.Character or Player.CharacterAdded:Wait();
local Camera = game.Workspace.CurrentCamera;

local FPMaximumDistance = 0.75; -- determining when character parts transparency is changed
local ZOffsetDistance = -1 -- amount the camera is offsetted when in first person

local function ChangeView(firstPerson)
	if firstPerson then
		for i,v in pairs(Character:GetChildren()) do
			if (v:IsA("BasePart")) and v.Name ~= "Head" then
				v.LocalTransparencyModifier = 0;
			end
		end
		Character.Humanoid.CameraOffset = Vector3.new(0,0,ZOffsetDistance)
	else
		Character.Humanoid.CameraOffset = Vector3.new(0,0,0)
		for i,v in pairs(Character:GetChildren()) do
			if (v:IsA("BasePart")) then
				v.LocalTransparencyModifier = 0;
			end
		end
	end
end

RunService.RenderStepped:Connect(function()
	local isFirstPerson = ((Camera.CFrame.p - Camera.Focus.p).magnitude <= FPMaximumDistance)
	ChangeView(isFirstPerson)
end)
