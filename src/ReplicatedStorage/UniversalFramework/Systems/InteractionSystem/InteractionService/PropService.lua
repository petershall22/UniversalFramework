local UniversalFramework = game:GetService("ReplicatedStorage"):WaitForChild("UniversalFramework")
local Knit = require(UniversalFramework.Utility.KnitFramework.Knit)
local Systems = UniversalFramework.Systems
local Utils = require(UniversalFramework.Utility.FrameworkUtils)

local ownership = {}

local propService = Knit.CreateService {
	Name = "PropService"
}

function propService.Client:UpdateProp(player, object, objectCFrame)
    if object:GetAttribute("CanInteract") == true and (object.Position - player.Character.HumanoidRootPart.Position).Magnitude < 20 then
        print(object)
        if ownership[object] == nil then
            ownership[object] = player
            object.Anchored = true
            object.CanCollide = false
            object.CFrame = objectCFrame
        elseif ownership[object] == player then
            object.Anchored = true
            object.CanCollide = false
            object.CFrame = objectCFrame
        end
    else
        print((object.Position - player.Character.HumanoidRootPart.Position).Magnitude)
        Utils.KickExploiter(player)
    end
end

function propService.Client:CanPick(_, object)
    if ownership[object] == nil then
        return true
    else
        return false
    end
end

function propService.Client:DissasociateProp(player, object)
    if ownership[object] == player then
        object.Anchored = false
        object.CanCollide = true
        ownership[object] = nil
    end
end

return propService