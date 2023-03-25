local UniversalFramework = game:GetService("ReplicatedStorage").UniversalFramework
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Knit = require(UniversalFramework.Utility.KnitFramework.Knit)
local Systems = UniversalFramework.Systems

local propService = Knit.GetService("PropService") 
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local pickingObject = false
local object = nil
local studsLimit = 10
local mult = 5
local pickupKeyCode = Enum.KeyCode.E
local lastUpdated = os.time()
local refreshRate = 0.3
local renderStepped;

local function pickupItem()
    local targetCFrame = workspace.CurrentCamera.CFrame + (workspace.CurrentCamera.CFrame.LookVector * mult)
    object.Anchored = true
    object.CanCollide = false
    object.CFrame = object.CFrame:Lerp(targetCFrame, 0.2)
    if os.time() - lastUpdated > refreshRate then
        propService:UpdateProp(object, object.CFrame)
        lastUpdated = os.time()
    end
end

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if not gameProcessedEvent then
        if input.KeyCode == pickupKeyCode then
            if pickingObject == false then
                object = mouse.Target
                if object:IsA("MeshPart") or object:IsA("Part") then
                    pickingObject = true
                    if object:GetAttribute("CanInteract") == true and (object.Position - player.Character.HumanoidRootPart.Position).Magnitude < studsLimit and propService:CanPick(object) then
                        Systems.CameraSystem.ToggleFPS:Fire(true)
                        renderStepped = RunService.RenderStepped:Connect(pickupItem)
                    else
                        object = nil
                    end
                end
            else
                pickingObject = false
                renderStepped:Disconnect()
                propService:DissasociateProp(object)
                Systems.CameraSystem.ToggleFPS:Fire(false)
                object = nil
            end
        end
    end
end)