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
local cameraCycler;
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
local currentScreen = homeFrame
local hoverEffectInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local selectionInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
local gameVer = UniversalFramework.Utility.GameVersion:InvokeServer()

-- Devlogs
local cards = UniversalFramework.Utility.Devlogs:InvokeServer()
local devlogPreview = homeFrame.DevlogPreview
local devlogFrame = screensFrame.Devlog
local devlogViewing = false
local devlogCycleWait = 3
local devlogCycler;
local currentCard;

-- Store
local gamepasses = {}
local devProducts = {}
local storeFrame = screensFrame.Store
local storeSelectionBar = storeFrame.SelectionBar
local storeButtons = storeSelectionBar.Buttons
local storeBottomBar = storeFrame.BottomBar
local currentStoreFrame = storeBottomBar.All

local ignoreFrames = {homeFrame.Buttons, devlogPreview.Image}
local ignoreImages = {homeFrame.Buttons}

-- START OF: UTILITY

local function moveSelection(selectionBar, chosenFrame)
    local selectionFrameY = selectionBar.Position.Y.Scale
    local xScale = (chosenFrame.AbsolutePosition.X/chosenFrame.Parent.AbsoluteSize.X) + 0.053
    local pos = UDim2.new(xScale, 0, selectionFrameY, 0)
    local tween = TweenService:Create(selectionBar, selectionInfo, {Position = pos})
    tween:Play()
end

local function hoverEffect(object)
    local frameTween = TweenService:Create(object, hoverEffectInfo, {BackgroundTransparency = 0})
    local buttonTween = TweenService:Create(object.Button, hoverEffectInfo, {TextColor3 = Color3.fromRGB(0,0,0)})
    if object.Arrow then
        local arrowTween = TweenService:Create(object.Arrow, hoverEffectInfo, {ImageTransparency = 0})
        arrowTween:Play()
    end
    frameTween:Play()
    buttonTween:Play()
end

local function endHover(object)
    local frameTween = TweenService:Create(object, hoverEffectInfo, {BackgroundTransparency = 1})
    local buttonTween = TweenService:Create(object.Button, hoverEffectInfo, {TextColor3 = Color3.fromRGB(255,255,255)})
    if object.Arrow then
        local arrowTween = TweenService:Create(object.Arrow, hoverEffectInfo, {ImageTransparency = 1})
        arrowTween:Play()
    end
    frameTween:Play()
    buttonTween:Play()
end

-- END OF: UTILITY

-- START OF: HOME

local function progressBar(object)
    coroutine.wrap(function()
        object.State.Size = UDim2.new(0,0,1,0)
        local fadeOut = TweenService:Create(object.State, transitionInfo, {BackgroundTransparency = 1})
        local fadeIn = TweenService:Create(object.State, transitionInfo, {BackgroundTransparency = 0})
        local holdTime = (transitionTime/2) + devlogCycleWait
        local tweenInfo = TweenInfo.new(holdTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
        local expandTween = TweenService:Create(object.State, tweenInfo, {Size = UDim2.new(1,0,1,0)})
        fadeIn:Play()
        expandTween:Play()
        expandTween.Completed:Wait()
        fadeOut:Play()
    end)()
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

local function devlogPreviewHandler()
    devlogCycler = coroutine.create(function()
        while task.wait() do
            for i, currentCard in cards do
                if currentScreen == homeFrame then
                    local fadeOut = TweenService:Create(devlogPreview.Image.ImageLabel, transitionInfo, {ImageTransparency = 1})
                    local fadeIn = TweenService:Create(devlogPreview.Image.ImageLabel, transitionInfo, {ImageTransparency = 0})
                    devlogPreview.Image.ImageLabel.Image = currentCard["image"]
                    devlogPreview.Title.Text = currentCard["title"]
                    fadeIn:Play()
                    progressBar(devlogPreview.ProgressBar)
                    Utils.Hold(transitionTime/2, currentScreen, homeFrame, "~=")
                    Utils.Hold(devlogCycleWait, currentScreen, homeFrame, "~=")
                    fadeOut:Play()
                    Utils.Hold(transitionTime/2, currentScreen, homeFrame, "~=")
                end
            end
        end
    end)
    coroutine.resume(devlogCycler)
end

local function devlogAppear(title, tween: boolean)
    devlogViewing = true
    -- Devlog Information
    currentCard = cards[title]
    local information = devlogFrame.ScrollingFrame.Frame
    devlogFrame.Preview.Image = currentCard["image"]
    information.Title.Text = currentCard["title"]
    information.BriefDesc.Text = currentCard["briefDesc"]
    information.Desc.Text = currentCard["desc"]
    -- Tweening
    if tween then
        local tween = TweenService:Create(devlogFrame, transitionInfo, {BackgroundTransparency = 0.1})
        Utils.descendantsFadeInTween(devlogFrame, ignoreFrames, ignoreImages, transitionInfo)
        tween:Play()
    end
end

local function devlogDisappear()
    local tween = TweenService:Create(devlogFrame, transitionInfo, {BackgroundTransparency = 1})
    Utils.descendantsFadeOutTween(devlogFrame, ignoreFrames, ignoreImages, transitionInfo)
    tween:Play()
    devlogViewing = false
end

-- END OF: HOME

-- START OF: STORE

local function changeStoreBar(button)
    local screen = storeBottomBar:FindFirstChild(button.Name)
    if screen ~= currentStoreFrame then
        moveSelection(storeSelectionBar.Selection, button)
        click:Play()
        screen.Visible = true
        Utils.descendantsFadeInTween(screen, ignoreFrames, ignoreImages, transitionInfo)
        Utils.descendantsFadeOutTween(currentStoreFrame, ignoreFrames, ignoreImages, transitionInfo)
        currentStoreFrame = screen
    end
end

-- END OF: STORE

local function changeScreen(button)
    local screen = screensFrame:FindFirstChild(button.Name)
    if screen ~= currentScreen then
        moveSelection(topbarFrame.Selection, button)
        click:Play()
        screen.Visible = true
        Utils.descendantsFadeInTween(screen, ignoreFrames, ignoreImages, transitionInfo)
        Utils.descendantsFadeOutTween(currentScreen, ignoreFrames, ignoreImages, transitionInfo)
        currentScreen = screen
    end
end

local function intialise()
    local cameras = workspace.UniversalFramework:WaitForChild("MenuCameras")
    coreGuiSet(false)
    devlogPreviewHandler()
    cameraCycler = coroutine.create(function()
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
    end)
    homeFrame.VersionNumber.Text = gameVer
    coroutine.resume(cameraCycler)
end

local function play()
    coroutine.close(cameraCycler)
    coroutine.close(devlogCycler)
end

-- Topbar Buttons

for i, v in topbarButtons:GetChildren() do
    if v:IsA("TextButton") then
        v.MouseButton1Down:Connect(function()
            changeScreen(v)
        end)
    end
end

for i, v in storeButtons:GetChildren() do
    if v:IsA("TextButton") then
        v.MouseButton1Down:Connect(function()
            changeStoreBar(v)
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

-- Buttons

devlogPreview.Button.MouseButton1Down:Connect(function()
    if not devlogViewing then
        click:Play()
        devlogAppear(devlogPreview.Title.Text, true)
    end
end)
screensFrame.Devlog.Exit.MouseButton1Down:Connect(function ()
    devlogDisappear()
end)

devlogFrame.RightArrow.MouseButton1Down:Connect(function()
    local index = table.find(cards, currentCard["title"])
    print(cards, currentCard)
end)
devlogFrame.LeftArrow.MouseButton1Down:Connect(function()
    
end)

-- Initialise

intialise()