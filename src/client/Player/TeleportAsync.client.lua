local Player_Service = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")

local Player = Player_Service.LocalPlayer

local teleportData = TeleportService:GetLocalPlayerTeleportData()

local CharacterEvent = ReplicatedStorage.Remotes.TeleportAsync.Character
local GetPlayerData = ReplicatedStorage.Remotes.TeleportAsync.PlayerData

if teleportData then
	
	for _, playerData in pairs(teleportData) do

		if playerData.playerUserId == Player.UserId then
			CharacterEvent:FireServer(playerData.characterString)
			GetPlayerData:FireServer(playerData)
		end
		
	end
	
end