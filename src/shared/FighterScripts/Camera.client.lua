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

local loopView = true
local angleType = "Spin"
local viewObject = nil
local viewTarget = nil

local cameraTweenInfo = TweenInfo.new(
	0.5,
	Enum.EasingStyle.Quad,
	Enum.EasingDirection.InOut
)

Camera.CameraType = Enum.CameraType.Scriptable
Camera.FieldOfView = 30

IntroEvent.OnClientEvent:Connect(function(playerOrder)
	print("IntroEvent.OnClientEvent()")
	loopView = false
  angleType = "Static"
	TweenService:Create(Camera, cameraTweenInfo, {CFrame = introAngles[playerOrder].CFrame}):Play()
	TweenService:Create(Camera, cameraTweenInfo, {FieldOfView = 50}):Play()
end)

CompletionEvent.OnClientEvent:Connect(function()
	local goalLookAt = Vector3.new(centerAngle.Position.X, roundAngles.Main.Position.Y - 2, centerAngle.Position.Z)
	local goalAngle = CFrame.lookAt(ringAngles.Round.Main.Position, goalLookAt)
	loopView = false
  angleType = "Static"
	TweenService:Create(Camera, cameraTweenInfo, {CFrame = goalAngle}):Play()
	TweenService:Create(Camera, cameraTweenInfo, {FieldOfView = 30}):Play()
end)

ToggleCamera.OnClientEvent:Connect(function(Enabled, cameraAngle)
	local roundAngleTween = TweenService:Create(Camera, cameraTweenInfo, {CFrame = CFrame.lookAt(roundAngles[cameraAngle].Position, HumanoidRootPart.Position)})
	local fieldOfViewTween = TweenService:Create(Camera, cameraTweenInfo, {FieldOfView = 40})
	roundAngleTween:Play()
	fieldOfViewTween:Play()
	roundAngleTween.Completed:Wait()
	loopView = true
	angleType = "Ring"
  viewObject = roundAngles[cameraAngle]
	viewTarget = HumanoidRootPart
end)

RunService.RenderStepped:Connect(function()
	if not loopView then return end
	
	if angleType == "Spin" then
		Camera.CFrame = CFrame.lookAt(spinAngles.Camera.Position, spinAngles.Target.Position)
	elseif angleType == "Ring" then
		Camera.CFrame = CFrame.lookAt(viewObject.Position, viewTarget.Position)
	end
	
end)