local spinCamera = workspace.CameraAngles.Spin.Camera
local centerObject = workspace.CameraAngles.Center  -- Replace with the actual name of the object to circle
local radius = 75  -- Radius of the circular path
local angularSpeed = 0.1  -- Speed of rotation (radians per second)

while task.wait() do
	local angle = time() * angularSpeed
	local x = centerObject.Position.X + radius * math.cos(angle)
	local z = centerObject.Position.Z + radius * math.sin(angle)  -- Maintain original Y height
	spinCamera.CFrame = CFrame.new(x, spinCamera.Position.Y, z)  -- Set CFrame relative to center object
end