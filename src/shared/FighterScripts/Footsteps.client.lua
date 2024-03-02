local Players_Service = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local RunService = game:GetService("RunService")

local Player = Players_Service.LocalPlayer
local Character = Player.Character
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

local footstepSounds = ReplicatedStorage.Sounds.FootstepSounds:Clone()
footstepSounds.Parent = SoundService

local isWalking = false

Humanoid.Running:connect(function(WalkSpeed)
	
	if WalkSpeed > Humanoid.WalkSpeed/2 then
		isWalking = true
	else
		isWalking = false
	end
	
end)

function GetMaterial()
	
	local floorMaterial = Humanoid.FloorMaterial
	
	if not floorMaterial then floorMaterial = "Air" end
	
	local materialString = string.split(tostring(floorMaterial), "Enum.Material." )[2]
	local material = materialString
	
	return material
end

local lastMaterial = nil

RunService.Heartbeat:connect(function()
	
	if isWalking then
		local Material = GetMaterial()
		
		if Material ~= lastMaterial and lastMaterial ~= nil then
			footstepSounds[lastMaterial].Playing = false
		end
		
		local materialSound = footstepSounds[Material]
		
		materialSound.PlaybackSpeed = Humanoid.WalkSpeed / 12
		materialSound.Playing = true
		lastMaterial = Material
		
	else
		
		for _, Sound in pairs(footstepSounds:GetChildren()) do
			Sound.Playing = false
		end
		
	end
	
end)