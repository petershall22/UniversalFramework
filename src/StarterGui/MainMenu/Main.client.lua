-- Requirements
local UniversalFramework = game:GetService("ReplicatedStorage"):WaitForChild("UniversalFramework")
local Knit = require(UniversalFramework.Utility.KnitFramework.Knit)
local Utils = require(UniversalFramework.Utility.FrameworkUtils)
local Types = require(UniversalFramework.Configuration.NotificationSystem.Types)
local player = game.Players.LocalPlayer

-- Services
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

-- Camera Variables
local RenderStepped = nil
local cameraCycler = nil
local Camera = workspace.CurrentCamera
local Mouse = player:GetMouse()
local MovementDivide = 700
local homeActive = true
local pauseTime = 10
local transitionTime = 1
local transitionInfo = TweenInfo.new(transitionTime/2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- UI elements
local gui = script.Parent
local screensFrame = gui.Screens
local topbarFrame = gui.Topbar
local topbarButtons = topbarFrame.Buttons
local homeFrame = screensFrame.Home
local click = gui.Click
local currentScreen = homeFrame
local hoverEffectInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local selectionInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
local gameVer = UniversalFramework.Utility.GameVersion:InvokeServer()

-- Home
local unselectedButtonFrameColor = Color3.fromRGB(29, 29, 29)
local selectedButtonFrameColor = Color3.fromRGB(232, 168, 70)
local selectedButtonTextColor = Color3.fromRGB(255, 255, 255)
local unselectedButtonTextColor = Color3.fromRGB(255, 255, 255)
local unselectedTopbarSize = UDim2.new(1, 0, 0.275, 0)
local selectedTopbarSize = UDim2.new(1, 0, 0.325, 0)
local unselectedFilterSize = UDim2.new(1, 0, 0.4, 0)
local selectedFilterSize = UDim2.new(1, 0, 0.45, 0)
local unselectedTopbarTransparency = 0.5
local selectedTopbarTransparency = 0 

-- Devlogs
local cards, devlogAmount = UniversalFramework.Utility.Devlogs:InvokeServer()
local devlogPreview = homeFrame.DevlogPreview
local devlogFrame = screensFrame.Devlog
local block = devlogFrame.Block
local devlogViewing = false
local devlogCycleWait = 5
local devlogCycler;
local currentCard;
local step;

-- Rules

local rulesCards, ruleAmount = UniversalFramework.Utility.Rules:InvokeServer()
local rulesFrame = screensFrame.Rules
local ruleContentFrame = rulesFrame.Block.ContentHolder
local ruleButtonTemplate = rulesFrame.DocumentSelection.Template

-- Store
local storeFrame = screensFrame.Store
local productHolder = storeFrame.ProductHolder
local productInfo = storeFrame.ProductInfo
local filters = productHolder.Filters
local tabs = productHolder.Tabs
local currentStoreFrame = tabs.Featured
local infoFadedIn = false
local currentInfo;
local products = {}

-- Credits
local creditsFrame = screensFrame.Credits.Holder
local creditTemplate = screensFrame.Credits.Template

-- Debounces
local storeDebounce = false
local changeScreenDebounce = false
local changeFilterDebounce = false
local devlogDisappearing = false

local ignoreFrames = {devlogPreview.MainPart.Image, productHolder.Filters}
local ignoreImages = {homeFrame.Buttons}
local ignoreButtons = {devlogPreview.Template}
local ignoreList = {tabs, block.TagsHolder.Template, block.ContentHolder.Main.DoNotTouch, productInfo.Main.Owned, productInfo.Main.SubscriptionStatus, ruleButtonTemplate, ruleContentFrame.ScrollingFrame.DoNotTouch}

-- START OF: UTILITY

local function cameraFunctionality(CameraCFrame, MovementDivider)
	local MovementDivide = MovementDivide
	if MovementDivider ~= nil then
		MovementDivide = MovementDivider
	end
	if CameraCFrame ~= false then
		if RenderStepped == nil then
			RenderStepped = RunService.RenderStepped:Connect(function()
				local Center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
				local MoveVector = Vector3.new((Mouse.X-Center.X)/MovementDivide, (Mouse.Y-Center.Y)/MovementDivide, 0)
				Camera.CFrame = CFrame.new(CameraCFrame.p + MoveVector) * CameraCFrame.Rotation
			end)
		else
			RenderStepped:Disconnect()
			RenderStepped = RunService.RenderStepped:Connect(function()
				local Center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
				local MoveVector = Vector3.new((Mouse.X-Center.X)/MovementDivide, (Mouse.Y-Center.Y)/MovementDivide, 0)
				Camera.CFrame = CFrame.new(CameraCFrame.p + MoveVector) * CameraCFrame.Rotation
			end)
		end
	else
		if RenderStepped then
			RenderStepped:Disconnect()
		end
	end
end

local function selectEffect(chosenButton, currentButton, selectedSize, unselectedSize)
	local currentButton = currentButton.TextLabel
	local chosenButton = chosenButton.TextLabel
	local sizeInTween = TweenService:Create(chosenButton, selectionInfo, {Size = selectedSize})
	local transparencyInTween = TweenService:Create(chosenButton, selectionInfo, {TextTransparency = selectedTopbarTransparency})
	local sizeOutTween = TweenService:Create(currentButton, selectionInfo, {Size = unselectedSize})
	local transparencyOutTween = TweenService:Create(currentButton, selectionInfo, {TextTransparency = unselectedTopbarTransparency})
	sizeInTween:Play()
	transparencyInTween:Play()
	sizeOutTween:Play()
	transparencyOutTween:Play()
	chosenButton.Font = Enum.Font.GothamBold
	currentButton.Font = Enum.Font.Gotham
end

local function hoverEffect(object: ObjectValue)
	local frameTween = TweenService:Create(object, hoverEffectInfo, {BackgroundColor3 = selectedButtonFrameColor})
	local textTween = TweenService:Create(object.Button.TextLabel, hoverEffectInfo, {TextColor3 = selectedButtonTextColor})
	local buttonTween = TweenService:Create(object.Button, hoverEffectInfo, {TextColor3 = Color3.fromRGB(0,0,0)})
	if object:FindFirstChild("Arrow") then
		local arrowTween = TweenService:Create(object.Arrow, hoverEffectInfo, {ImageTransparency = 0})
		arrowTween:Play()
	end
	if object:FindFirstChild("UIStroke") then
		local borderTween = TweenService:Create(object.UIStroke, hoverEffectInfo, {Thickness = 1})
		borderTween:Play()
	end
	frameTween:Play()
	buttonTween:Play()
	textTween:Play()
end

local function endHover(object: ObjectValue)
	local frameTween = TweenService:Create(object, hoverEffectInfo, {BackgroundColor3 = unselectedButtonFrameColor})
	local textTween = TweenService:Create(object.Button.TextLabel, hoverEffectInfo, {TextColor3 = unselectedButtonTextColor})
	local buttonTween = TweenService:Create(object.Button, hoverEffectInfo, {TextColor3 = Color3.fromRGB(255,255,255)})
	if object:FindFirstChild("Arrow") then
		local arrowTween = TweenService:Create(object.Arrow, hoverEffectInfo, {ImageTransparency = 1})
		arrowTween:Play()
	end
	if object:FindFirstChild("UIStroke") then
		local borderTween = TweenService:Create(object.UIStroke, hoverEffectInfo, {Thickness = 0})
		borderTween:Play()
	end
	frameTween:Play()
	buttonTween:Play()
	textTween:Play()
end

local function showHoverInfo(object: ObjectValue)
	object.HoverInfo.Visible = true
	Utils.descendantsFadeInTween(object.HoverInfo, ignoreFrames, ignoreImages, ignoreButtons, hoverEffectInfo)
	local tween = TweenService:Create(object.HoverInfo, hoverEffectInfo, {BackgroundTransparency = 0})
	tween:Play()
end

local function hideHoverInfo(object: ObjectValue)
	Utils.descendantsFadeOutTween(object.HoverInfo, hoverEffectInfo, ignoreImages, ignoreButtons, hoverEffectInfo)
	local tween = TweenService:Create(object.HoverInfo, hoverEffectInfo, {BackgroundTransparency = 1})
	tween:Play()
	tween.Completed:Connect(function()
		object.HoverInfo.Visible = false
	end)
end

-- END OF: UTILITY

-- START OF: HOME

local function findCard(title)
	for _, v in cards do
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
		local tweenInfo = TweenInfo.new(holdTime, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
		local expandTween = TweenService:Create(object.Progress.State, tweenInfo, {Size = UDim2.new(1,0,1,0)})
		expandTween:Play()
		expandTween.Completed:Wait()
		if step == devlogAmount then
			for _, bar in devlogPreview.ProgressBar:GetChildren() do
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

local function coreGuiSet(arg)
	game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, arg)
	game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, arg)
	game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, arg)
	game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, arg)
end

local function advancePreview(currentCard)
    step += 1
    local title = currentCard["title"]
    local currentBar = devlogPreview.ProgressBar:FindFirstChild(title)
    local fadeOutCard = TweenService:Create(devlogPreview.MainPart.Image, transitionInfo, {ImageTransparency = 1})
    local fadeInCard = TweenService:Create(devlogPreview.MainPart.Image, transitionInfo, {ImageTransparency = 0.05})
    devlogPreview.MainPart.Image.Image = currentCard["image"]
    devlogPreview.MainPart.Title.Text = title
    fadeInCard:Play()
    progressBar(currentBar, step)
    Utils.Hold(transitionTime/2, currentScreen, homeFrame, "~=")
    Utils.Hold(devlogCycleWait, currentScreen, homeFrame, "~=")
    fadeOutCard:Play()
    Utils.Hold(transitionTime/2, currentScreen, homeFrame, "~=")
end

local function devlogPreviewHandler()
	devlogCycler = coroutine.create(function()
		while task.wait() do
			step = 0
			for _, currentCard in ipairs(cards) do
				if currentScreen == homeFrame then
                    advancePreview(currentCard)
				else
					while currentScreen ~= homeFrame do
						task.wait()
					end
                    advancePreview(currentCard)
				end
			end
		end
	end)
	coroutine.resume(devlogCycler)
end

local function devlogAppear(title, tween: boolean) 
	if not devlogViewing and currentScreen == homeFrame then
		devlogViewing = true
		changeScreenDebounce = true
		-- Devlog Information
		currentCard = findCard(title)
		local information = block.ContentHolder.Main
		block.Title.Text = currentCard["title"]
		block.Subtitle.Text = currentCard["briefDesc"]
		information.Content.Text = currentCard["desc"]
		devlogFrame.Visible = true
		-- Tweening
		for _, v in currentCard["labels"] do
			local clone = block.TagsHolder.Template:Clone()
			clone.Name = v["name"]
			clone.Text = v["name"]
			clone.Parent = block.TagsHolder
			clone.Visible = true
			clone.TextTransparency = 0
			clone.UIStroke.Transparency = 0
		end
		if tween then
			local tween = TweenService:Create(devlogFrame.Background, transitionInfo, {BackgroundTransparency = 0.2})
			Utils.descendantsFadeInTween(devlogFrame, ignoreFrames, ignoreImages, ignoreButtons, transitionInfo, ignoreList)
			Utils.descendantsFadeOutTween(homeFrame, ignoreFrames, ignoreImages, ignoreButtons, transitionInfo)
			tween:Play()
		end
	end
end

local function devlogDisappear()
	if devlogViewing and not devlogDisappearing then
		devlogDisappearing = true
		click:Play()
		local tween = TweenService:Create(devlogFrame, transitionInfo, {BackgroundTransparency = 1})
		Utils.descendantsFadeOutTween(devlogFrame, ignoreFrames, ignoreImages, ignoreButtons, transitionInfo)
		Utils.descendantsFadeInTween(homeFrame, ignoreFrames, ignoreImages, ignoreButtons, transitionInfo, ignoreList)
		tween:Play()
		for _, v in block.TagsHolder:GetChildren() do
			if v.Name ~= "Template" and v:IsA("TextLabel") then
				v:Destroy()
			end
		end
		Utils.Hold(transitionTime)
		devlogViewing = false
		devlogDisappearing = false
		changeScreenDebounce = false
	end
end

local function setupDevlogBar()
	for _, card in cards do
		local clone = devlogPreview.Template:Clone()
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

local function changeStoreTab(button)
	local screen = tabs:FindFirstChild(button.Name)
	local newIgnore = table.clone(ignoreList)
	local index = table.find(newIgnore, tabs)
	table.remove(newIgnore, index)
	if screen ~= currentStoreFrame and not changeFilterDebounce then
		changeFilterDebounce = true
		selectEffect(button, filters:FindFirstChild(currentStoreFrame.Name), selectedFilterSize, unselectedFilterSize)
		click:Play()
		Utils.descendantsFadeOutTween(currentStoreFrame, ignoreFrames, ignoreImages, ignoreButtons, transitionInfo)
        Utils.Hold(transitionTime/2)
		currentStoreFrame.Visible = false
		screen.Visible = true
		Utils.descendantsFadeInTween(screen, ignoreFrames, ignoreImages, ignoreButtons, transitionInfo, newIgnore)
		currentStoreFrame = screen
		Utils.Hold(1)
		changeFilterDebounce = false
	end
end

local function showProduct(name)
	local main = productInfo.Main
	local fadeIn = TweenService:Create(gui.Transition, transitionInfo, {BackgroundTransparency = 0})
	local fadeOut = TweenService:Create(gui.Transition, transitionInfo, {BackgroundTransparency = 1})
	currentInfo = products[name]
	local cframe = currentInfo["Object"].CameraPart.CFrame
	main.Title.Text = currentInfo.Name
	main.Desc.Text = currentInfo.Description
	main.PType.Text = currentInfo["Object"]:GetAttribute("Category")
	main.ButtonHolder.Purchase.Contents.Price.Text = currentInfo.PriceInRobux
	if not infoFadedIn then
		infoFadedIn = true
		Utils.descendantsFadeInTween(productInfo, ignoreFrames, ignoreImages, ignoreButtons, transitionInfo, {productInfo.Main.Owned, productInfo.Main.SubscriptionStatus})
		productInfo.Visible = true
	end
	if currentInfo["Type"] == Enum.InfoType.GamePass then
		if MarketplaceService:UserOwnsGamePassAsync(player.UserId, currentInfo["Id"]) then
			main.Owned.Visible = true
		else
			main.Owned.Visible = false
		end
	else
		main.Owned.Visible = false
	end
	fadeIn:Play()
	fadeIn.Completed:Connect(function()
		cameraFunctionality(false)
		cameraFunctionality(cframe, 1500)
		Utils.Hold(0.2, gui.homeActive, false, "==")
		fadeOut:Play()
	end)
end

local function purchase()
	if currentInfo["Type"] == Enum.InfoType.GamePass then
		MarketplaceService:PromptGamePassPurchase(player, currentInfo["Id"])
	else
		MarketplaceService:PromptProductPurchase(player, currentInfo["Id"])
	end
	click:Play()
end

local function initialiseProducts()
	local storeFolder = workspace:WaitForChild("UniversalFramework").StoreShowcase
	for _, v in storeFolder:GetChildren() do
		local id = v:GetAttribute("Id")
		local success, err = pcall(function()
			local type;
			if v:GetAttribute("Gamepass") then
				type = Enum.InfoType.GamePass
			else
				type = Enum.InfoType.Product
			end
			local info = MarketplaceService:GetProductInfo(id, type)
			if info.IsForSale then
				local clone = productHolder.Template:Clone()
				clone.Name = info.Name
				products[info.Name] = info
				products[info.Name]["Id"] = id
				products[info.Name]["Object"] = v
				products[info.Name]["Type"] = type
				table.insert(ignoreList, clone.HoverInfo)
				clone.HoverInfo.Title.Text = info.Name
				clone.HoverInfo.Desc.Text = v:GetAttribute("BriefDesc")
				clone.Preview.Image = string.format("rbxassetid://%d", v:GetAttribute("ImageId"))
				if v:GetAttribute("Featured") then
					local clone1 = clone:Clone()
					table.insert(ignoreList, clone1.HoverInfo)
					clone1.Parent = tabs.Featured
					clone1.Button.MouseButton1Down:Connect(function()
						showProduct(clone1.Name)
					end)
					clone1.Button.MouseEnter:Connect(function()
						showHoverInfo(clone1)
					end)
					clone1.Button.MouseLeave:Connect(function()
						hideHoverInfo(clone1)
					end)
				end
				if type == Enum.InfoType.GamePass then
					clone.Parent = tabs.Gamepasses
				elseif v:GetAttribute("IsSubscription") then
					clone.Parent = tabs.Subscriptions
				else
					clone.Parent = tabs.Products
				end
				clone.Visible = true
				clone.Button.MouseButton1Down:Connect(function()
					showProduct(clone.Name)
				end)
				clone.Button.MouseEnter:Connect(function()
					showHoverInfo(clone)
				end)
				clone.Button.MouseLeave:Connect(function()
					hideHoverInfo(clone)
				end)
				--TODO: ADD CHECKBOX IF PRODUCT OWNED
			end
		end)
		if not success then
			warn(string.format("Error in store: %s", err))
		end
	end
end

-- END OF: STORE

-- START OF: RULES

local function showTab(card)
	ruleContentFrame.Parent.Title.Text = card["title"]
	ruleContentFrame.ScrollingFrame.ClauseContent.Text = card["desc"]
end

local function initialiseRules()
	for i, v in rulesCards do
		local clone = ruleButtonTemplate:Clone()
		clone.Name = v["title"]
		clone.HoverInfo.Title.Text = v["team"]
		clone.Parent = ruleButtonTemplate.Parent
		clone.Preview.Image = v["image"]
		clone.Visible = true
		table.insert(ignoreList, clone.HoverInfo)
		clone.Button.MouseEnter:Connect(function()
			showHoverInfo(clone)
		end)
		clone.Button.MouseLeave:Connect(function()
			hideHoverInfo(clone)
		end)
		clone.Button.MouseButton1Down:Connect(function()
			showTab(v)
		end)
	end
end

-- END OF: RULES

-- START OF: CREDITS

local function initialiseCredits()
	for _, title in creditsFrame:GetChildren() do
		for _, user in title:GetChildren() do
			if user:IsA("StringValue") then
				local clone = creditTemplate:Clone()
				local name = user.Name
				local userId = Players:GetUserIdFromNameAsync(name)
				clone.Name = name
				clone.HoverInfo.Title.Text = name
				clone.HoverInfo.Desc.Text = string.format("%s<br />%s", title.Name, user.Job.Value)
				table.insert(ignoreList, clone.HoverInfo)
				clone.MouseEnter:Connect(function()
					showHoverInfo(clone)
				end)
				clone.MouseLeave:Connect(function()
					hideHoverInfo(clone)
				end)
				clone.Parent = title
				clone.Avatar.Image = Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
				clone.Visible = true
			end
		end
	end
end

-- END OF: CREDITS

local function createCycler()
	local cameras = workspace.UniversalFramework:WaitForChild("MenuCameras")
	cameraCycler = coroutine.create(function()
		while gui.homeActive.Value do      
			for _, cameraPart in cameras:GetChildren() do
				if gui.homeActive.Value then
					local fadeIn = TweenService:Create(gui.Transition, transitionInfo, {BackgroundTransparency = 0})
					local fadeOut = TweenService:Create(gui.Transition, transitionInfo, {BackgroundTransparency = 1})
					fadeIn:Play()
					fadeIn.Completed:Connect(function()
						cameraFunctionality(false)
						cameraFunctionality(cameraPart.CFrame)
						Utils.Hold(1)
						fadeOut:Play()
					end)
					Utils.Hold(pauseTime)
				else
					break
				end
			end
		end
	end)
end

local function homeCamera()
	if cameraCycler ~= nil then
		coroutine.close(cameraCycler)
		cameraFunctionality(false)
		cameraCycler = nil
		createCycler()
	else
		createCycler()
	end
	homeFrame.VersionNumber.Text = gameVer
	coroutine.resume(cameraCycler)
end

local function endHomeCamera()
	gui.homeActive.Value = false
	coroutine.close(cameraCycler)
end

local function changeScreen(button)
	local screen = screensFrame:FindFirstChild(button.Name)
	if screen ~= currentScreen and not changeScreenDebounce then
		local fadeIn = TweenService:Create(gui.Transition, transitionInfo, {BackgroundTransparency = 0})
		local fadeOut = TweenService:Create(gui.Transition, transitionInfo, {BackgroundTransparency = 1})
		changeScreenDebounce = true
		selectEffect(button, topbarButtons:FindFirstChild(currentScreen.Name), selectedTopbarSize, unselectedTopbarSize)
		click:Play()
		if screen == storeFrame then -- Manages transitioning from home screen to other screens
			endHomeCamera()
		else
			gui.homeActive.Value = true
			fadeIn:Play()
			fadeIn.Completed:Connect(function()
				homeCamera()
				Utils.Hold(1, gui.homeActive, false, "==")
				fadeOut:Play()
			end)
		end
		Utils.descendantsFadeOutTween(currentScreen, ignoreFrames, ignoreImages, ignoreButtons, transitionInfo)
		currentScreen = screen
        Utils.Hold(transitionTime/2)
		screen.Visible = true
		if screen == storeFrame then -- NOTE: This is to make sure that the product info does not appear without a product being selected.
			if not infoFadedIn then
				screen.ProductHolder.Visible = true
				local newIgnore = table.clone(ignoreList)
				local index = table.find(newIgnore, tabs)
				table.remove(newIgnore, index)
				Utils.descendantsFadeInTween(screen.ProductHolder, ignoreFrames, ignoreImages, ignoreButtons, transitionInfo, ignoreList)
				for _, v in tabs:GetChildren() do
					if v ~= currentStoreFrame then
						v.Visible = false
					end
				end
				Utils.descendantsFadeInTween(currentStoreFrame, ignoreFrames, ignoreImages, ignoreButtons, transitionInfo, newIgnore)
				for _, v in filters:GetChildren() do
					if v.Name ~= currentStoreFrame.Name and v:IsA("TextButton") then
						selectEffect(filters:FindFirstChild(currentStoreFrame.Name), v, selectedFilterSize, unselectedFilterSize)
					end
				end
				currentStoreFrame.Visible = true
			else 
				local newIgnore = table.clone(ignoreList)
				local index = table.find(newIgnore, tabs)
				table.remove(newIgnore, index)
				Utils.descendantsFadeInTween(screen, ignoreFrames, ignoreImages, ignoreButtons, transitionInfo, ignoreList)
				for _, v in tabs:GetChildren() do
					if v ~= currentStoreFrame then
						v.Visible = false
					end
				end
				Utils.descendantsFadeInTween(currentStoreFrame, ignoreFrames, ignoreImages, ignoreButtons, transitionInfo, newIgnore)
				local fadeIn = TweenService:Create(gui.Transition, transitionInfo, {BackgroundTransparency = 0})
				local fadeOut = TweenService:Create(gui.Transition, transitionInfo, {BackgroundTransparency = 1})
				fadeIn:Play()
				currentStoreFrame.Visible = true
				fadeIn.Completed:Connect(function()
					local cframe = currentInfo["Object"].CameraPart.CFrame
					cameraFunctionality(cframe)
					Utils.Hold(1)
					fadeOut:Play()
				end)
			end
			for _, v in filters:GetChildren() do
				if v.Name ~= currentStoreFrame.Name and v:IsA("TextButton") then
					selectEffect(filters:FindFirstChild(currentStoreFrame.Name), v, selectedFilterSize, unselectedFilterSize)
				end
			end
		else
			Utils.descendantsFadeInTween(screen, ignoreFrames, ignoreImages, ignoreButtons, transitionInfo, ignoreList)
		end
		Utils.Hold(1)
		changeScreenDebounce = false
	end
end

local function intialise()
	initialiseRules()
	initialiseCredits()
	homeCamera()
	coreGuiSet(false)
	devlogPreviewHandler()
	setupDevlogBar()
	initialiseProducts() -- YIELDS
	homeFrame.VersionNumber.Text = gameVer
end

local function play()
	coroutine.close(cameraCycler)
	coroutine.close(devlogCycler)
end

-- Topbar Buttons

for _, v in topbarButtons:GetChildren() do
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

-- Store Buttons

for i, v in filters:GetChildren() do
	if v:IsA("TextButton") then
		v.MouseButton1Down:Connect(function()
			changeStoreTab(v)
		end)
	end
end

productInfo.Main.ButtonHolder.Purchase.MouseButton1Down:Connect(purchase)

-- Buttons

devlogPreview.MainPart.Button.MouseButton1Down:Connect(function()
	if not devlogViewing then
		click:Play()
		devlogAppear(devlogPreview.MainPart.Title.Text, true)
	end
end)
block.CloseButton.MouseButton1Down:Connect(function ()
	devlogDisappear()
end)

-- Initialise

intialise()