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
local cards, devlogAmount = UniversalFramework.Utility.Devlogs:InvokeServer()
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
local storeItems = storeFrame.Items
local currentStoreFrame = storeItems.All

-- Debounces
local storeDebounce = false
local changeScreenDebounce = false
local devlogDisappearing = false

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

local function findCard(title)
    for i, v in cards do
        if v["title"] == title then
            return v
        end
    end
end

local function progressBar(object, step)
    coroutine.wrap(function()
        local holdTime = (transitionTime/2) + devlogCycleWait
        if step == devlogAmount then
            holdTime -= 1
        end
        local tweenInfo = TweenInfo.new(holdTime, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
        local expandTween = TweenService:Create(object.Progress.State, tweenInfo, {Size = UDim2.new(1,0,1,0)})
        expandTween:Play()
        expandTween.Completed:Wait()
        if step == devlogAmount then
            for i, bar in devlogPreview.ProgressBar:GetChildren() do
                if bar:IsA("TextButton") then
                    local fadeOut = TweenService:Create(bar.Progress.State, transitionInfo, {BackgroundTransparency = 1})
                    fadeOut:Play()
                    fadeOut.Completed:Connect(function()
                        bar.Progress.State.Size = UDim2.new(0,0,1,0)
                        bar.Progress.State.BackgroundTransparency = 0
                    end)
                end
            end
        end
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
            local step = 0
            for i, currentCard in ipairs(cards) do
                step += 1
                if currentScreen == homeFrame then
                    local title = currentCard["title"]
                    local currentBar = devlogPreview.ProgressBar:FindFirstChild(title)
                    local fadeOut = TweenService:Create(devlogPreview.Image.ImageLabel, transitionInfo, {ImageTransparency = 1})
                    local fadeIn = TweenService:Create(devlogPreview.Image.ImageLabel, transitionInfo, {ImageTransparency = 0})
                    devlogPreview.Image.ImageLabel.Image = currentCard["image"]
                    devlogPreview.Title.Text = title
                    fadeIn:Play()
                    progressBar(currentBar, step)
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
    if not devlogViewing then
        devlogViewing = true
        -- Devlog Information
        currentCard = findCard(title)
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
end

local function devlogDisappear()
    if devlogViewing and not devlogDisappearing then
        devlogDisappearing = true
        local tween = TweenService:Create(devlogFrame, transitionInfo, {BackgroundTransparency = 1})
        Utils.descendantsFadeOutTween(devlogFrame, ignoreFrames, ignoreImages, transitionInfo)
        tween:Play()
        Utils.Hold(1)
        devlogViewing = false
        devlogDisappearing = false
    end
end

local function setupDevlogBar()
    for i, card in cards do
        local clone = devlogPreview.BarTemplate:Clone()
        clone.Active = true
        clone.Parent = devlogPreview.ProgressBar
        clone.Name = card["title"]
        clone.Size = UDim2.new((1/devlogAmount),-5,1,0)
        clone.Visible = true
        clone.MouseButton1Down:Connect(function()
            if not devlogViewing then
                click:Play()
                devlogAppear(clone.Name, true)
            end
        end)
    end
end

-- END OF: HOME

-- START OF: STORE

local function changeStoreBar(button)
    local screen = storeItems:FindFirstChild(button.Name)
    if screen ~= currentStoreFrame and not storeDebounce then
        storeDebounce = true
        moveSelection(storeSelectionBar.Selection, button)
        click:Play()
        screen.Visible = true
        Utils.descendantsFadeInTween(screen, ignoreFrames, ignoreImages, transitionInfo)
        Utils.descendantsFadeOutTween(currentStoreFrame, ignoreFrames, ignoreImages, transitionInfo)
        currentStoreFrame = screen
        Utils.Hold(1)
        storeDebounce = false
    end
end

-- END OF: STORE

local function changeScreen(button)
    local screen = screensFrame:FindFirstChild(button.Name)
    if screen ~= currentScreen and not changeScreenDebounce then
        changeScreenDebounce = true
        moveSelection(topbarFrame.Selection, button)
        click:Play()
        screen.Visible = true
        Utils.descendantsFadeInTween(screen, ignoreFrames, ignoreImages, transitionInfo)
        Utils.descendantsFadeOutTween(currentScreen, ignoreFrames, ignoreImages, transitionInfo)
        currentScreen = screen
        Utils.Hold(1)
        changeScreenDebounce = false
    end
end

local function intialise()
    local cameras = workspace.UniversalFramework:WaitForChild("MenuCameras")
    coreGuiSet(false)
    devlogPreviewHandler()
    setupDevlogBar()
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

-- Initialise

intialise()