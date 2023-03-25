local RUNSERVICE		= game:GetService("RunService")
local PLAYERS			= game:GetService("Players")
local UIS				= game:GetService("UserInputService")
local US 				= UserSettings():GetService("UserGameSettings")

local UniversalFramework = game:GetService("ReplicatedStorage"):WaitForChild("UniversalFramework")
local Knit = require(UniversalFramework.Utility.KnitFramework.Knit)
local Utils = require(UniversalFramework.Utility.FrameworkUtils)
local Systems = UniversalFramework.Systems
local KeybindRemote 	= UniversalFramework.Utility.Keybind

local CAMERA			= workspace.CurrentCamera

local PLAYER			= PLAYERS.LocalPlayer
local CHAR				= PLAYER.Character or PLAYER.CharacterAdded:wait()
local ROOT				= CHAR:WaitForChild('HumanoidRootPart')
local HUMANOID			= CHAR:WaitForChild('Humanoid')
local OTSEnabled 		= false
local lockRotation 		= UniversalFramework.Configuration.CameraSystem:GetAttribute("LockRotation")
local debounce 			= false
local firstPersonEnabled = false
local firstPersonToggled = false
local moving			= false
local heartbeat;

CAMERA.CameraType = Enum.CameraType.Scriptable

local ZOOM				= 8
local ZOOMlower			= 8
local ZOOMupper			= 8
local ZOOMincr			= 2

local X					= -1
local Y					= 0
local RX				= 0
local RY				= 0
local XOffset 			= 1.5

local PANSPEED			= 20

local SKEW				= 0.2 
local direction			= "r"


function halflerp(a,b,alpha)
	return a+(b-a)--*alpha
end

function firstPerson(enabled)
	if enabled then
		firstPersonEnabled = true
		unbindOTS()
		PLAYER.CameraMode = Enum.CameraMode.LockFirstPerson
	else
		firstPersonEnabled = false
		PLAYER.CameraMode = Enum.CameraMode.Classic
		PLAYER.CameraMinZoomDistance = 5
		--task.wait(0.3) -- wait is depreceated
		bindOTS()
	end
end

function PanCamera(dt)

	local DELTA = UIS:GetMouseDelta()*SKEW
	local ROOTCF = CFrame.new(ROOT.Position)
	local OFFSET = CFrame.new(XOffset,2,ZOOM)
	local MODSPEED = PANSPEED*dt


	X = X-DELTA.X
	Y = math.clamp(Y-DELTA.Y,-70,70)

	RX = halflerp(RX,math.rad(X),MODSPEED)
	RY = halflerp(RY,math.rad(Y),MODSPEED)

	local absOFFSET = CFrame.Angles(0,RX,0)*CFrame.Angles(RY,0,0)*OFFSET

	CAMERA.CFrame = CAMERA.CFrame:Lerp(ROOTCF*absOFFSET,MODSPEED)
end

function SetZoom(input,other)
	if other then return end
	if input.UserInputType == Enum.UserInputType.MouseWheel then
		local dt = input.Position.Z
		if dt > 0 then
			ZOOM = math.clamp(ZOOM-ZOOMincr,ZOOMlower,ZOOMupper)
		elseif dt < 0 then
			ZOOM = math.clamp(ZOOM+ZOOMincr,ZOOMlower,ZOOMupper)
		end
		if ZOOM == ZOOMlower then
			if firstPersonToggled then
				firstPerson(true)
			else
				if dt > 0 and OTSEnabled then
					firstPerson(true)
				elseif dt < 0 and firstPersonEnabled then
					firstPerson(false)
				end
			end
		elseif firstPersonToggled then
			firstPerson(true)
		end
	end
end

function characterTurn()
	US.RotationType = Enum.RotationType.MovementRelative
	local Duration = 0.5
	local Elapsed = 0
	local rotationCFrame;
	local rx, ry, rz = CAMERA.CFrame:ToOrientation() 
	local rx1,ry1, rz1 = ROOT.CFrame:ToOrientation()
	local rotationY = ry - ry1
	rotationY = math.floor(math.deg(rotationY)) -- turn orientation to degrees
	rotationY = math.sqrt(rotationY^2) -- remove negative values
	local turn;
	if (rotationY) >= lockRotation and not debounce and lockRotation ~= 0 then
		debounce = true
		turn = RUNSERVICE.Heartbeat:Connect(function(deltaTime)
			Elapsed += deltaTime
			local alpha = Elapsed/Duration
			rotationCFrame = CFrame.new(CHAR.HumanoidRootPart.CFrame.Position) * CFrame.fromOrientation(0, ry, 0)
			CHAR.HumanoidRootPart.CFrame = CHAR.HumanoidRootPart.CFrame:Lerp(rotationCFrame, alpha)
			if alpha >= 1 then
				turn:Disconnect()
				debounce = false
			end
		end)
	elseif debounce then
		rotationCFrame = CFrame.new(CHAR.HumanoidRootPart.CFrame.Position) * CFrame.fromOrientation(0, ry, 0)
	end
end

function characterSwitch()
	heartbeat = RUNSERVICE.Heartbeat:Connect(function(deltaTime)
		task.wait(0.2)
		if not moving then
			characterTurn()
		else
			characterLock()
		end
	end)
end

function characterLock()
	US.RotationType = Enum.RotationType.CameraRelative
end

function bindOTS(arg)
	if not OTSEnabled then
		OTSEnabled = true
		PLAYER.CameraMinZoomDistance = 5
		checkMoving()
		RUNSERVICE:BindToRenderStep('ShoulderCam',Enum.RenderPriority.Camera.Value - 1,PanCamera)
		characterSwitch()
		CAMERA.CameraType = "Scriptable"
		UIS.MouseBehavior = Enum.MouseBehavior.LockCenter
	end
end

function unbindOTS(arg)
	if OTSEnabled then
		OTSEnabled = false
		RUNSERVICE:UnbindFromRenderStep('ShoulderCam')
		heartbeat:Disconnect()
		CAMERA.CameraType = "Custom"
		UIS.MouseIconEnabled = true
		UIS.MouseBehavior = Enum.MouseBehavior.Default
	end
end

CAMERA.CameraType = "Custom"

Systems.CameraSystem.ToggleOTS.Event:Connect(function(arg)
	if arg == true then
		bindOTS()
	elseif arg == false then
		unbindOTS()
	end
end)

PLAYER.CharacterAdded:Connect(function()
	CHAR = PLAYER.Character or PLAYER.CharacterAdded:wait()
	ROOT = CHAR:WaitForChild('HumanoidRootPart')
	HUMANOID = CHAR.Humanoid
	CAMERA.CameraSubject = HUMANOID
	CAMERA.CameraType = "Custom"
	CAMERA.CFrame = CHAR.Head.CFrame
	if OTSEnabled then
		unbindOTS()
		bindOTS()
	else
		unbindOTS()
	end
end)

Systems.CameraSystem.Aim.Event:Connect(function(arg)
	if arg == true then
		ZOOM = 4
		ZOOMlower = 4
		ZOOMupper = 4
	elseif arg == false then
		ZOOM				= 5
		ZOOMlower			= 5
		ZOOMupper			= 5
		ZOOMincr			= 5
	end
end)

function checkMoving()
	
end

-- Keybind checking begins here
UIS.InputBegan:Connect(function(input, gameProcessedEvent)
	local changeShoulderKeybind = UniversalFramework.Utility.Keybind:InvokeServer("ChangeShoulder")
	local unlockCharKeybind = UniversalFramework.Utility.Keybind:InvokeServer("UnlockCharacter")
	local FPSKeybind = UniversalFramework.Utility.Keybind:InvokeServer("FirstPerson")
	if not gameProcessedEvent then
		if input.KeyCode.Name:upper() == changeShoulderKeybind:upper() then
			if direction == "l" then
				XOffset = math.sqrt(XOffset^2)
				direction = "r"
			elseif direction == "r" then
				XOffset = -XOffset
				direction = "l"
			end
		end
		if input.KeyCode.Name:upper() == unlockCharKeybind:upper() then
			heartbeat:Disconnect()
			debounce = true
		end
	end
end)

game.ReplicatedStorage.UniversalFramework.Systems.CameraSystem.ToggleFPS.Event:Connect(function(enabled)
	firstPersonToggled = enabled
	firstPerson(true)
end)

UIS.InputEnded:Connect(function(input, gameProcessedEvent)
	local unlockCharKeybind = KeybindRemote:InvokeServer("UnlockCharacter")
	if input.KeyCode.Name:upper() == unlockCharKeybind:upper() then
		if not gameProcessedEvent then
			characterSwitch()
			debounce = false
		end
	end
end)


UIS.WindowFocused:Connect(function()
	if OTSEnabled then
		unbindOTS()
		bindOTS()
	end
end)

UIS.InputChanged:Connect(SetZoom)