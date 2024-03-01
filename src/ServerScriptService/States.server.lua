local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Functions = require(ReplicatedStorage.Modules.Primary.Combat.Functions)

local combatRemotes = ReplicatedStorage.Remotes.Ring.Combat
local AttackEvent = combatRemotes.Attack

AttackEvent.OnServerEvent:Connect(Functions.Damage)