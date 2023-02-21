local DS 		= game:GetService("DataStoreService")
local RS 		= game:GetService("ReplicatedStorage")
local keybindDatastore	= DS:GetDataStore("KeybindDatastore")

local UniversalFramework = game:GetService("ReplicatedStorage"):WaitForChild("UniversalFramework")
local Knit = require(UniversalFramework.Utility.KnitFramework.Knit)
local Utils = require(UniversalFramework.Utility.FrameworkUtils)
local Systems = UniversalFramework.Systems

local function keybind(player, func)
	local success, keybind = pcall(function()
		local keybinds = keybindDatastore:GetAsync(player.Name)
        if keybinds[func] ~= nil then
		    return keybinds[func] 
        else
			return UniversalFramework.DefaultKeybinds[func].Value
        end
	end)
    if not success then
        keybindDatastore:SetAsync(player.Name, {})
		return UniversalFramework.DefaultKeybinds[func].Value
    end
    return keybind
end

UniversalFramework.Utility.Keybind.OnServerInvoke = keybind