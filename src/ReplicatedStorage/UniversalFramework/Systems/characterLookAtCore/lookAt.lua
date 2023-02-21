local UniversalFramework = game:GetService("ReplicatedStorage"):WaitForChild("UniversalFramework")
local values = UniversalFramework.Configuration.characterLookAtCore
local SETTINGS = {
	horizontalRange = math.rad(values:GetAttribute("MaxHorizontalRange"));
	verticalRange = math.rad(values:GetAttribute("MaxVerticalRange"));
	maxHorizontalWaist = math.rad(values:GetAttribute("WaistHorizontalRange"));
	maxHorizontalHead = math.rad(values:GetAttribute("HeadHorizontalRange"));
	verticalAngleDivider = values:GetAttribute("VerticalAngleDivider");
	horizontalAngleDivider = values:GetAttribute("HorizontalAngleDivider");
}

local lookAt = {};
local lookAt_mt = {__index = lookAt};

local spring = require(script.Parent:WaitForChild("spring"));


function lookAt.new(character)
	local self = {};
	
	self.character = character;
	self.hrp = character:WaitForChild("HumanoidRootPart");
	self.neck = character:WaitForChild("Head"):WaitForChild("Neck");
	self.waist = character:WaitForChild("UpperTorso"):WaitForChild("Waist");
	self.neckC0 = self.neck.C0;
	self.waistC0 = self.waist.C0;
	
	self.spring = spring.new(Vector3.new(), Vector3.new(), Vector3.new(), 10, 1);
	
	return setmetatable(self, lookAt_mt);
end

function lookAt:calcGoal(target)
	local goal = Vector3.new(0, 0, 0);
	
	local eye = (self.hrp.CFrame * CFrame.new(0, 3, 0)):pointToObjectSpace(target).unit;
	local horizontal = -math.atan2(eye.x, -eye.z)/SETTINGS.horizontalAngleDivider;
	local vertical = math.asin(eye.y)/SETTINGS.verticalAngleDivider;
	
	if not (math.abs(horizontal) > SETTINGS.horizontalRange or math.abs(vertical) > SETTINGS.verticalRange) then
		local hsign, habs = math.sign(horizontal), math.abs(horizontal);
		local hneck, hwaist = habs*0.5, habs*0.5;
		
		if (hwaist > SETTINGS.maxHorizontalWaist) then
			local remainder = hwaist - SETTINGS.maxHorizontalWaist;
			hwaist = SETTINGS.maxHorizontalWaist;
			hneck = math.clamp(hneck + remainder, 0, SETTINGS.maxHorizontalHead);
		end
		
		goal = Vector3.new(hsign*hneck, hsign*hwaist, vertical);
	end
	
	self.spring.target = goal;
end

function lookAt:update(dt)
	self.spring:update(dt);
	local set = self.spring.p;
	self.neck.C0 = self.neckC0 * CFrame.fromEulerAnglesYXZ(set.z*0.5, set.x, 0);
	self.waist.C0 = self.waistC0 * CFrame.fromEulerAnglesYXZ(set.z*0.5, set.y, 0);
end

return lookAt;