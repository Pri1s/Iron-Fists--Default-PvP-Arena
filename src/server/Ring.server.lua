local Player_Service = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Settings = require(ReplicatedStorage.Shared.Modules.Settings)
local Ring = require(ReplicatedStorage.Shared.Modules.Primary.Ring)

local AssetsLoaded = ReplicatedStorage.Remotes.Setup.AssetsLoaded
local TeleportData = ReplicatedStorage.Remotes.Setup.TeleportData
local KnockedEvent = ReplicatedStorage.Remotes.Ring.Combat.Knocked

local myRing = Ring.new()
local playerData = {}
local loadedPlayers = 0

TeleportData.OnServerEvent:Connect(function(Player, Data)
    table.insert(playerData, Data)
end)

AssetsLoaded.OnServerEvent:Connect(function(Player)
    loadedPlayers = loadedPlayers + 1
end)

repeat
    task.wait()
until loadedPlayers == Settings.requiredQueuers and #Player_Service:GetChildren() >= Settings.requiredQueuers

AssetsLoaded:FireAllClients()
task.wait(Settings.Delays.initializeMatch)
myRing:Initialize(playerData)

KnockedEvent.OnServerEvent:Connect(function(Player, knockType)
    local Victor = nil

    for _, Data in pairs(myRing.playerData) do
        if Data.Player ~= Player then
            Victor = Data.Player
        end
    end

    myRing:CompleteRound(Victor, Player, knockType)
end)