local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Functions = require(ReplicatedStorage.Shared.Modules.Primary.Combat.Functions)

local Remotes = {

  Events = {
    Attack = ReplicatedStorage.Remotes.Events.Ring.Combat.Attack,
    IKController = ReplicatedStorage.Remotes.Events.Ring.Combat.IKController
  },
  
}

Remotes.Events.Attack.OnServerEvent:Connect(Functions.Damage)
Remotes.Events.IKController.OnServerEvent:Connect(Functions.IKController)