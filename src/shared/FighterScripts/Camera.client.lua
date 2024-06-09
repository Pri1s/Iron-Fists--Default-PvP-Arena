local Players_Service = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local Settings = require(ReplicatedStorage.Shared.Modules.Settings)
local Math = require(ReplicatedStorage.Shared.Modules.Math)

local Player = Players_Service.LocalPlayer
local Camera = workspace.CurrentCamera

local ToggleCamera = ReplicatedStorage.Remotes.Ring.Other.ToggleCamera
local IntroEvent = ReplicatedStorage.Remotes.Ring.Primary.Intro
local CompletionEvent = ReplicatedStorage.Remotes.Ring.Primary.Completion

local Character = Player.Character
local HumanoidRootPart = Character.HumanoidRootPart

local spinCameraSettings = Settings.Environment.Camera.Spin

local cameraAngles = workspace.CameraAngles
local centerAngle = cameraAngles.Center
local ringAngles = cameraAngles.Ring
local introAngles = ringAngles.Intro
local roundAngles = ringAngles.Round
local dynamicAngle = roundAngles.Dynamic
local staticAngle = roundAngles.Static
local spinAngles = cameraAngles.Spin
local spinCamera = spinAngles.Camera
local spinTarget = spinAngles.Target

local viewMode = "Spin"
local dynamicViewObject

local cameraTweenInfo = TweenInfo.new(
	0.5,
	Enum.EasingStyle.Quad,
	Enum.EasingDirection.InOut
)

Camera.CameraType = Enum.CameraType.Scriptable
Camera.FieldOfView = 30

IntroEvent.OnClientEvent:Connect(function(playerOrder)
  viewMode = "Cutscene"
	TweenService:Create(Camera, cameraTweenInfo, {CFrame = introAngles[playerOrder].CFrame}):Play()
	TweenService:Create(Camera, cameraTweenInfo, {FieldOfView = 50}):Play()
end)

CompletionEvent.OnClientEvent:Connect(function()
	local goalLookAt = Vector3.new(centerAngle.Position.X, roundAngles.Completion.Position.Y - 2, centerAngle.Position.Z)
	local goalAngle = CFrame.lookAt(roundAngles.Completion.Position, goalLookAt)

  viewMode = "Cutscene"
	TweenService:Create(Camera, cameraTweenInfo, {CFrame = goalAngle}):Play()
	TweenService:Create(Camera, cameraTweenInfo, {FieldOfView = 30}):Play()
end)

ToggleCamera.OnClientEvent:Connect(function(Looped, cameraMode)
	local goalAngle

	if cameraMode == "Round/Static" then
		goalAngle = CFrame.lookAt(staticAngle.Position, HumanoidRootPart.Position)
	end

	local angleTween = TweenService:Create(Camera, cameraTweenInfo, {CFrame = goalAngle})
	local fovTween = TweenService:Create(Camera, cameraTweenInfo, {FieldOfView = 40})
	angleTween:Play()
	fovTween:Play()
	angleTween.Completed:Wait()

	viewMode = cameraMode
end)

RunService.RenderStepped:Connect(function()
	
	if viewMode == "Spin" then
		local x, z = Math.CircularPath(centerAngle, spinCameraSettings.Radius, spinCameraSettings.angularSpeed)
		spinCamera.CFrame = CFrame.new(x, spinCamera.Position.Y, z)
		Camera.CFrame = CFrame.lookAt(spinAngles.Camera.Position, spinAngles.Target.Position)
	elseif viewMode == "Round/Static" then
		Camera.CFrame = CFrame.lookAt(staticAngle.Position, HumanoidRootPart.Position)
	elseif viewMode == "Round/Dynamic" then
		print("Round/Dynamic")
	end
	
end)