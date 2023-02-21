local Types = {}

local notifTypes = {
	["Alert"] = {
		["Sound"] = "",
		["Image"] = "",
		["Color"] = Color3.fromRGB(132, 24, 26)
	},
	["Notification"] = {
		["Sound"] = "",
		["Image"] = "",
		["Color"] = Color3.fromRGB(67, 98, 126)
	},
	["Purchase"] = {
		["Sound"] = "",
		["Image"] = "",
		["Color"] = Color3.fromRGB(77, 116, 69)
	},
	["Tokens"] = {
		["Sound"] = "",
		["Image"] = "",
		["Color"] = Color3.fromRGB(173, 134, 35)
	}
}

function Types.returnTypes()
	return notifTypes
end

return Types
