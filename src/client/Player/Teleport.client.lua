local Player_Service = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")

local Player = Player_Service.LocalPlayer

local teleportData = TeleportService:GetLocalPlayerTeleportData()

local TeleportEvent = ReplicatedStorage.Remotes.Events.Setup.TeleportData

if teleportData then

    for _, playerData in pairs(teleportData) do

        if playerData.playerUserId == Player.UserId then
            TeleportEvent:FireServer(playerData)
        end

    end

end