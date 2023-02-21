local base = script.Parent:WaitForChild("DoorBase")

for i, v in (script.Parent:GetDescendants()) do
	if v:IsA("BasePart") then
		local new = Instance.new("WeldConstraint")
		new.Parent = base
		new.Part0 = v
		new.Part1 = base
		v.Anchored = false
	end
end

local hinge = Instance.new("HingeConstraint")
hinge.Parent = base
hinge.Attachment0 = base.Attachment
hinge.Attachment1 = script.Parent.Parent.DoorFrame.Attachment
hinge.ActuatorType = Enum.ActuatorType.Servo
hinge.AngularResponsiveness = 20
hinge.AngularSpeed = 5
hinge.ServoMaxTorque = math.huge
hinge.TargetAngle = 0

