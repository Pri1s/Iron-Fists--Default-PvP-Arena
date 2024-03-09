local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Functions = require(ReplicatedStorage.Shared.Modules.Primary.Combat.Functions)

local combatRemotes = ReplicatedStorage.Remotes.Ring.Combat
local AttackEvent = combatRemotes.Attack
local IKController = combatRemotes.IKController

AttackEvent.OnServerEvent:Connect(Functions.Damage)
IKController.OnServerEvent:Connect(Functions.IKController)