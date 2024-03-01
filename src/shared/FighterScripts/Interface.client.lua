local Players_Service = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local Interface = require(ReplicatedStorage.Modules.Primary.Interface)

local Player = Players_Service.LocalPlayer
local PlayerGui = Player.PlayerGui
local VitalsUi = PlayerGui:WaitForChild("Vitals")
local TimeUi = PlayerGui:WaitForChild("Time")

local Character = Player.Character
local Humanoid = Character.Humanoid

local InterfaceEnabled = ReplicatedStorage.Remotes.Other["Interface/Enabled"]
local InitializeViewports = ReplicatedStorage.Remotes.Ring.Combat.Vitals.Health.Initialize
local UpdateHealth = ReplicatedStorage.Remotes.Ring.Combat.Vitals.Health.Update
local CountEvent = ReplicatedStorage.Remotes.Ring.Other.Count

repeat task.wait()

	local disabledReset = pcall(function()
		StarterGui:SetCore("ResetButtonCallback", false)
	end)

until disabledReset

StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)

InterfaceEnabled.OnClientEvent:Connect(function(Amount)
	Interface.DisableUi(PlayerGui, Amount)
end)

InitializeViewports.OnClientEvent:Connect(function(fighter1, fighter2)
	Interface.InitializeHealthVitals(VitalsUi, fighter1, fighter2)
end)

UpdateHealth.OnClientEvent:Connect(function(playerType, Attribute, Length)
	Interface.UpdateHealthVitals(VitalsUi, Humanoid, playerType, Attribute, Length)
end)

CountEvent.OnClientEvent:Connect(function(Display)
	TimeUi.Main.TextLabel.Text = Display
end)