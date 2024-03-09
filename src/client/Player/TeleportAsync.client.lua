local Player_Service = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")

local Player = Player_Service.LocalPlayer

local teleportData = TeleportService:GetLocalPlayerTeleportData()

local CharacterData = ReplicatedStorage.Remotes.Setup.Data.Character
local PlayerData = ReplicatedStorage.Remotes.Setup.Data.Player

if teleportData then
	
	for _, playerData in pairs(teleportData) do

		if playerData.playerUserId == Player.UserId then
			CharacterData:FireServer(playerData.characterString)
			PlayerData:FireServer(playerData)
		end
		
	end
	
end