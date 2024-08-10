local Players_Service = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local Interface = require(ReplicatedStorage.Shared.Modules.Primary.Interface)

local Player = Players_Service.LocalPlayer
local PlayerGui = Player.PlayerGui
local VitalsUi = PlayerGui:WaitForChild("Vitals")
local TimeUi = PlayerGui:WaitForChild("Time")
local TransitionUi = PlayerGui:WaitForChild("Transition")

local Character = Player.Character

local Remotes = {

    Events = {
        Interface = ReplicatedStorage.Remotes.Events.Interface,
        Transition = ReplicatedStorage.Remotes.Events.Transition,
        Health = ReplicatedStorage.Remotes.Events.Ring.Combat.Vitals.Health,
        Count = ReplicatedStorage.Remotes.Events.Ring.Other.Count,
        initializeViewports = ReplicatedStorage.Remotes.Events.Ring.Other.InitializeViewports
    },

}

--local Remotes.Events.Interface = ReplicatedStorage.Remotes.Other["Interface/Enabled"]
--local TransitionEvent = ReplicatedStorage.Remotes.Other.Transition
--local InitializeViewports = ReplicatedStorage.Remotes.Ring.Combat.Vitals.Health.Initialize
--local UpdateHealth = ReplicatedStorage.Remotes.Ring.Combat.Vitals.Health.Update
--local CountEvent = ReplicatedStorage.Remotes.Ring.Other.Count

repeat
    task.wait()

    local disabledReset = pcall(function()
        StarterGui:SetCore("ResetButtonCallback", false)
    end)

until disabledReset

StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)

Remotes.Events.Interface.OnClientEvent:Connect(function(Enabled, Exceptions)
    Interface.DisableUi(PlayerGui, Enabled, Exceptions)
end)

Remotes.Events.Transition.OnClientEvent:Connect(function()
    Interface.Transition(TransitionUi)
end)

Remotes.Events.initializeViewports.OnClientEvent:Connect(function(fighter1, fighter2)
    Interface.InitializeHealthVitals(VitalsUi, fighter1, fighter2)
end)

Remotes.Events.Health.OnClientEvent:Connect(function(playerType, Attribute, Length)
    Interface.UpdateHealthVitals(VitalsUi, Humanoid, playerType, Attribute, Length)
end)

Remotes.Events.Count.OnClientEvent:Connect(function(Display)
    TimeUi.Main.TextLabel.Text = Display
end)