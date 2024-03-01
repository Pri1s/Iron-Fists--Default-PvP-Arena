local Players_Service = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local Player = Players_Service.LocalPlayer
local Camera = workspace.CurrentCamera

local ToggleCamera = ReplicatedStorage.Remotes.Ring.Other.ToggleCamera
local IntroEvent = ReplicatedStorage.Remotes.Ring.Primary.Intro
local CompletionEvent = ReplicatedStorage.Remotes.Ring.Primary.Completion

local Character = Player.Character
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

local cameraAngles = workspace:WaitForChild("CameraAngles")
local centerAngle = cameraAngles:WaitForChild("Center")
local ringAngles = cameraAngles:WaitForChild("Ring")
local roundAngles = ringAngles:WaitForChild("Round")
local introAngles = ringAngles:WaitForChild("Intro")
local spinAngles = cameraAngles:WaitForChild("Spin")
local spinCamera = spinAngles:WaitForChild("Camera")
local spinTarget = spinAngles:WaitForChild("Target")

loopedAngleData = {
	Type = "Spin",
	Angle = nil
}

local cameraTweenInfo = TweenInfo.new(
	0.5,
	Enum.EasingStyle.Quad,
	Enum.EasingDirection.InOut
)

Camera.CameraType = Enum.CameraType.Scriptable
Camera.FieldOfView = 30

IntroEvent.OnClientEvent:Connect(function(playerOrder)
	loopedAngleData.Type = nil
	TweenService:Create(Camera, cameraTweenInfo, {CFrame = introAngles[playerOrder].CFrame}):Play()
	TweenService:Create(Camera, cameraTweenInfo, {FieldOfView = 50}):Play()
end)

CompletionEvent.OnClientEvent:Connect(function()
	local goalLookAt = Vector3.new(centerAngle.Position.X, roundAngles.Main.Position.Y - 2, centerAngle.Position.Z)
	local goalAngle = CFrame.lookAt(ringAngles.Round.Main.Position, goalLookAt)
	loopedAngleData.Type = nil
	TweenService:Create(Camera, cameraTweenInfo, {CFrame = goalAngle}):Play()
	TweenService:Create(Camera, cameraTweenInfo, {FieldOfView = 30}):Play()
end)

ToggleCamera.OnClientEvent:Connect(function(Enabled, cameraAngle)
	local roundAngleTween = TweenService:Create(Camera, cameraTweenInfo, {CFrame = CFrame.lookAt(roundAngles[cameraAngle].Position, HumanoidRootPart.Position)})
	roundAngleTween:Play()
	TweenService:Create(Camera, cameraTweenInfo, {FieldOfView = 40}):Play()
	roundAngleTween.Completed:Wait()
	loopedAngleData.Type = "Ring/Main"
	loopedAngleData.Angle = roundAngles[cameraAngle]
end)

RunService.RenderStepped:Connect(function()
	if not loopedAngleData.Type then return end
	
	if loopedAngleData.Type == "Spin" then
		Camera.CFrame = CFrame.lookAt(spinAngles.Camera.Position, spinAngles.Target.Position)
	elseif loopedAngleData.Type == "Ring/Main" then
		Camera.CFrame = CFrame.lookAt(loopedAngleData.Angle.Position, HumanoidRootPart.Position)
	end
	
end)

