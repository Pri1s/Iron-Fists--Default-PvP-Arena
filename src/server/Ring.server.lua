local Player_Service = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Settings = require(ReplicatedStorage.Shared.Modules.Settings)
local Ring = require(ReplicatedStorage.Shared.Modules.Primary.Ring)

local Remotes = {

    Events = {
        Knocked = ReplicatedStorage.Remotes.Events.Ring.Combat.Knocked,
        assetsLoaded = ReplicatedStorage.Remotes.Events.Setup.AssetsLoaded,
        teleportData = ReplicatedStorage.Remotes.Events.Setup.TeleportData
    },

}

--local Remotes.Events.assetsLoaded = ReplicatedStorage.Remotes.Setup.Remotes.Events.assetsLoaded
--local Remotes.Events.teleportData = ReplicatedStorage.Remotes.Setup.Remotes.Events.teleportData
--local Remotes.Events.Knocked = ReplicatedStorage.Remotes.Ring.Combat.Knocked

local myRing = Ring.new()
local playerData = {}
local loadedPlayers = 0

Remotes.Events.teleportData.OnServerEvent:Connect(function(Player, Data)
    table.insert(playerData, Data)
end)

Remotes.Events.assetsLoaded.OnServerEvent:Connect(function(Player)
    loadedPlayers = loadedPlayers + 1
end)

repeat
    task.wait()
until loadedPlayers == Settings.requiredQueuers and #Player_Service:GetChildren() >= Settings.requiredQueuers

Remotes.Events.assetsLoaded:FireAllClients()
task.wait(Settings.Delays.initializeMatch)
myRing:Initialize(playerData)

Remotes.Events.Knocked.OnServerEvent:Connect(function(Player, knockType)
    local Victor = nil

    for _, Data in pairs(myRing.playerData) do
        if Data.Player ~= Player then
            Victor = Data.Player
        end
    end

    myRing:CompleteRound(Victor, Player, knockType)
end)