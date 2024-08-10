local Players_Service = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players_Service.LocalPlayer
local Controls = require(Player.PlayerScripts:WaitForChild("PlayerModule")):GetControls()

local ControlsEvent = ReplicatedStorage.Remotes.Events.Setup.Controls

ControlsEvent.OnClientEvent:Connect(function(Status)

    if Status == "Disable" then
        Controls:Disable()
    else
        Controls:Enable()
    end

end)