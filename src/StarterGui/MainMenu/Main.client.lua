-- Requirements
local UniversalFramework = game:GetService("ReplicatedStorage"):WaitForChild("UniversalFramework")
local Knit = require(UniversalFramework.Utility.KnitFramework.Knit)
local Utils = require(UniversalFramework.Utility.FrameworkUtils)
local Types = require(UniversalFramework.Configuration.NotificationSystem.Types)
local player = game.Players.LocalPlayer

-- Services
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- Camera Variables
local RenderStepped;
local Camera = workspace.CurrentCamera
local Mouse = player:GetMouse()
local MovementDivide = 700
local homeActive = true
local pauseTime = 10
local transitionTime = 2
local transitionInfo = TweenInfo.new(transitionTime/2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- UI elements
local gui = script.Parent
local screensFrame = gui.Screens
local topbarFrame = gui.Topbar
local topbarButtons = topbarFrame.Topbar
local homeFrame = screensFrame.Home
local click = gui.Click
local selectionFrameY = topbarFrame.Selection.Position.Y.Scale
local hoverEffectInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local selectionInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)

-- Functions
local function hoverEffect(object)
    local frameTween = TweenService:Create(object, hoverEffectInfo, {BackgroundTransparency = 0})
    local buttonTween = TweenService:Create(object.Button, hoverEffectInfo, {TextColor3 = Color3.fromRGB(0,0,0)})
    local arrowTween = TweenService:Create(object.Arrow, hoverEffectInfo, {ImageTransparency = 0})
    frameTween:Play()
    buttonTween:Play()
    arrowTween:Play()
end

local function endHover(object)
    local frameTween = TweenService:Create(object, hoverEffectInfo, {BackgroundTransparency = 1})
    local buttonTween = TweenService:Create(object.Button, hoverEffectInfo, {TextColor3 = Color3.fromRGB(255,255,255)})
    local arrowTween = TweenService:Create(object.Arrow, hoverEffectInfo, {ImageTransparency = 1})
    frameTween:Play()
    buttonTween:Play()
    arrowTween:Play()
end

local function cameraFunctionality(CameraCFrame)
    if CameraCFrame ~= false then
        RenderStepped = RunService.RenderStepped:Connect(function()
            local Center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
            local MoveVector = Vector3.new((Mouse.X-Center.X)/MovementDivide, (Mouse.Y-Center.Y)/MovementDivide, 0)
            Camera.CFrame = CFrame.new(CameraCFrame.p + MoveVector) * CameraCFrame.Rotation
        end)
    else
        RenderStepped:Disconnect()
    end
end

local function coreGuiSet(arg)
    game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, arg)
    game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, arg)
    game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, arg)
    game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, arg)
end

local function intialise()
    local cameras = workspace.UniversalFramework:WaitForChild("MenuCameras")
    coreGuiSet(false)
    while homeActive do
        for i, cameraPart in cameras:GetChildren() do
            cameraFunctionality(cameraPart.CFrame)
            Utils.Hold(pauseTime)
            local fadeIn = TweenService:Create(gui.Transition, transitionInfo, {BackgroundTransparency = 0})
            local fadeOut = TweenService:Create(gui.Transition, transitionInfo, {BackgroundTransparency = 1})
            fadeIn:Play()
            fadeIn.Completed:Connect(function()
                Utils.Hold(1)
                fadeOut:Play()
            end)
            Utils.Hold(transitionTime/2)
            cameraFunctionality(false)
        end
    end
end

local function changeScreen(button)
    local xScale = (button.AbsolutePosition.X/button.Parent.AbsoluteSize.X) + 0.053
    local pos = UDim2.new(xScale, 0, selectionFrameY, 0)
    local tween = TweenService:Create(topbarFrame.Selection, selectionInfo, {Position = pos})
    tween:Play()
    click:Play()
end

-- Topbar Buttons

for i, v in topbarButtons:GetChildren() do
    if v:IsA("TextButton") then
        v.MouseButton1Down:Connect(function()
            changeScreen(v)
        end)
    end
end

-- Home Buttons

for i, v in homeFrame.Buttons:GetChildren() do
    if v:IsA("Frame") then
        v.Button.MouseEnter:Connect(function()
            hoverEffect(v)
        end)
        v.Button.MouseLeave:Connect(function()
            endHover(v)
        end)
    end
end

-- Initialise

intialise()