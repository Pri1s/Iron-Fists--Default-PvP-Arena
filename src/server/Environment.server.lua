--[[
local Players_Service = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Settings = require(ReplicatedStorage.Shared.Modules.Settings)
local Calculations = require(ReplicatedStorage.Shared.Modules.Calculations)

local PlayerData = ReplicatedStorage.Remotes.Setup.Data.Player

local spinCamSettings = Settings.Environment.spinCamera
local dynamic_CamSettings = Settings.Environment.dynamic_Camera

local spinCamera = workspace.CameraAngles.Spin.Camera
local dynamic_Cameras = workspace.CameraAngles.Ring.Round.Dynamic
local centerObject = workspace.CameraAngles.Center  -- Replace with the actual name of the object to circle

local playerData = {}

local function SpinCamera()
	local x, z = Calculations.CircularPath(centerObject, spinCamSettings.Radius, spinCamSettings.angularSpeed)
	spinCamera.CFrame = CFrame.new(x, spinCamera.Position.Y, z)  -- Set CFrame relative to center object
end

local function Dynamic_Camera(camPart, partA, partB)
	print("----------")
	print(tostring(camPart))
	print(tostring(partA))
	print(tostring(partB))
	print(camPart.Position)
	-- Calculate the target position and orientation
	local targetPosition, midpoint = Calculations.TargetPositionAndOrientation(partA, partB, dynamic_CamSettings.FOV, dynamic_CamSettings.minOffset)
 
	-- Lerp the position of partTest towards the target position
	local currentPosition = camPart.Position
	local newPosition = currentPosition:Lerp(targetPosition, dynamic_CamSettings.lerpSpeed)
	camPart.Position = newPosition
 
	-- Orient partTest to face the midpoint
	camPart.CFrame = CFrame.lookAt(camPart.Position, midpoint)
end

local function GetRoots()
	local root1
	local root2

	for _, Data in ipairs(playerData) do
		local Player = Players_Service:FindFirstChild(Data.playerName)
		local Character = Player.Character or Player.CharacterAdded:Wait()
		
		print(Data.playerOrder)
		if Data.playerOrder == "Player1" then
			root1 = Character.HumanoidRootPart
		elseif Data.playerOrder == "Player2" then
			root2 = Character.HumanoidRootPart
		end

	end

	return root1, root2
end


PlayerData.OnServerEvent:Connect(function(Player, Data)
	table.insert(playerData, Data)
end)

repeat task.wait() until #playerData > 1
local root1, root2 = GetRoots()

RunService.Heartbeat:Connect(function()
	SpinCamera()
	
	if #playerData > 1 then
		Dynamic_Camera(dynamic_Cameras["1"], root1, root2)
		Dynamic_Camera(dynamic_Cameras["2"], root2, root1)
	end

end)
]] 