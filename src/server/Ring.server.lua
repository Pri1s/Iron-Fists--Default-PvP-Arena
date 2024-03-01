local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Settings = require(ReplicatedStorage.Modules.Settings)
local Ring = require(ReplicatedStorage.Modules.Primary.Ring)
local GetPlayerData = ReplicatedStorage.Remotes.TeleportAsync.PlayerData
local KnockedEvent = ReplicatedStorage.Remotes.Ring.Combat.Knocked

local myRing = Ring.new()

local playerData = {}

GetPlayerData.OnServerEvent:Connect(function(Player, Data)
	table.insert(playerData, Data)
end)

repeat task.wait() until #playerData == 2
task.wait(Settings.Delays.initializeMatch)
myRing:Initialize(playerData)

KnockedEvent.OnServerEvent:Connect(function(Player, knockType)
	local Victor = nil
	
	for _, Data in pairs(myRing.playerData) do
		print("Data.Player: ", tostring(Data.Player))
		if Data.Player ~= Player then Victor = Data.Player end
	end
	
	myRing:CompleteRound(Victor, Player, knockType)
end)