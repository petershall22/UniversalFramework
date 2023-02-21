local camera = game.Workspace.CurrentCamera;

local character = game.Players.LocalPlayer.CharacterAdded:Wait();
local humanoid = character:WaitForChild("Humanoid");
local hrp = character:WaitForChild("HumanoidRootPart");
local Player = game.Players.LocalPlayer
local Mouse = Player:GetMouse()

local UniversalFramework = game:GetService("ReplicatedStorage").UniversalFramework
local Knit = require(UniversalFramework.Utility.KnitFramework.Knit)
local Utils = require(UniversalFramework.Utility.FrameworkUtils)
local Systems = UniversalFramework.Systems

local core = Systems:WaitForChild("characterLookAtCore");
local lookAt = require(core.lookAt).new(character);
local characterLookAtService = Knit.GetService("CharacterLookAt")


characterLookAtService:Init(character, humanoid);

game:GetService("RunService").RenderStepped:Connect(function(dt)
	lookAt:calcGoal((hrp.CFrame * CFrame.new(0, 3, 0)).p + camera.CFrame.LookVector);
	--lookAt:update(dt);
end)

game:GetService("RunService").RenderStepped:Connect(function()
	characterLookAtService:Update((hrp.CFrame * CFrame.new(0, 3, 0)).p + camera.CFrame.LookVector);
end)
