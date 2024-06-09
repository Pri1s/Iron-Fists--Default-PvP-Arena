local Players_Service = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Settings = require(ReplicatedStorage.Shared.Modules.Settings)
local States = require(ReplicatedStorage.Shared.Modules.Primary.Combat.States)
local Functions = require(ReplicatedStorage.Shared.Modules.Primary.Combat.Functions)
local Interface = require(ReplicatedStorage.Shared.Modules.Primary.Interface)

local GetStateFunc = ReplicatedStorage.Remotes.States.Get
local TransitionStateEvent = ReplicatedStorage.Remotes.States.Transition
local DrainBlock = ReplicatedStorage.Remotes.Ring.Combat.Vitals.Stamina["Block/Drain"]
local OpponentData = ReplicatedStorage.Remotes.Ring.Other["Opponent/Data"]

local Player = Players_Service.LocalPlayer
local PlayerGui = Player.PlayerGui
local VitalsUi = PlayerGui:WaitForChild("Vitals")
local TimeUi = PlayerGui:WaitForChild("Time")

local Character = Player.Character
local Humanoid = Character.Humanoid
local Amputation = Humanoid:GetAttribute("Amputation")
local Head = Character.Head
local UpperTorso = Character.UpperTorso

local Emotes = ReplicatedStorage.Animations.Emotes
local punchAnimations

if Amputation == "None" then
	punchAnimations = ReplicatedStorage.Animations.Punches.Default
else
	punchAnimations = ReplicatedStorage.Animations.Punches.Amputation[Amputation]
end

print("Loaded Punch Animations: ", tostring(punchAnimations))

local Animations = {
	Walk = Humanoid:LoadAnimation(ReplicatedStorage.Animations.Walk),
	Block = Humanoid:LoadAnimation(ReplicatedStorage.Animations.Block),
	Thump = Humanoid:LoadAnimation(ReplicatedStorage.Animations.Collisions.Thump),
	Knockout = Humanoid:LoadAnimation(ReplicatedStorage.Animations.Collisions.Knockout),
	
	Emotes = {
		Ready = Humanoid:LoadAnimation(Emotes.Ready),
		Celebrate = Humanoid:LoadAnimation(Emotes.Celebrate),
		Defeat = Humanoid:LoadAnimation(Emotes.Defeat)
	},
	
	Punches = {
		Jabs = punchAnimations.Jabs,
		Uppercut = Humanoid:LoadAnimation(punchAnimations.Uppercut),
		Hook = Humanoid:LoadAnimation(punchAnimations.Hook)
	}
	
}

local Cooldowns = {
	Uppercut = {
		Duration = 1.5,
		previousInputTime = 0
	}
}

local stateEngine = States.new(Player, Animations)

Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
Humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)

repeat task.wait() until #Players_Service:GetChildren() >= 2
task.wait(Settings.Delays.initializeMatch)

for _, v in ipairs(Players_Service:GetChildren()) do
	
	if v:IsA("Player") and v.UserId ~= Player.UserId then
		stateEngine:Initialize(v)
	end
	
end

UserInputService.MouseIconEnabled = false

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
	if gameProcessedEvent then return end
	
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.KeyCode == Enum.KeyCode.ButtonX then
		if VitalsUi.Stamina.Offensive.Bar.Size.X.Scale - (stateEngine.Attributes.ofStaminaDrain / stateEngine.Attributes.ofStamina) <= 0 then return end
		
		if stateEngine:GetState() == "Idle" then
			stateEngine:Transition("Attack", "Jab")
		end
		
	elseif input.UserInputType == Enum.UserInputType.MouseButton2 or input.KeyCode == Enum.KeyCode.ButtonL2 then
		if VitalsUi.Stamina.Block.BarSlot.Bar.Size.X.Scale - (stateEngine.Attributes.dvStaminaDrain / stateEngine.Attributes.dvStamina) <= 0 then return end
		
		if stateEngine:GetState() == "Idle" then
			stateEngine:Transition("Block")
		end
		
	elseif input.KeyCode == Enum.KeyCode.E or input.KeyCode == Enum.KeyCode.ButtonB then
		if VitalsUi.Stamina.Offensive.Bar.Size.X.Scale - (stateEngine.Attributes.ofStaminaDrain / stateEngine.Attributes.ofStamina) <= 0 then return end

		if stateEngine:GetState() == "Idle" then
			stateEngine:Transition("Attack", "Hook")
		end
		
	elseif input.KeyCode == Enum.KeyCode.F or input.KeyCode == Enum.KeyCode.ButtonY then
		if VitalsUi.Stamina.Offensive.Bar.Size.X.Scale - (stateEngine.Attributes.ofStaminaDrain / stateEngine.Attributes.ofStamina) <= 0 then return end
		if tick() - Cooldowns.Uppercut.previousInputTime < Cooldowns.Uppercut.Duration then return end

		if stateEngine:GetState() == "Idle" then
			stateEngine:Transition("Attack", "Uppercut")
		end
		
		Cooldowns.Uppercut.previousInputTime = tick()
	elseif input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.ButtonL1 then
		if stateEngine.Target == "Head" then return end
		
		if stateEngine:GetState() == "Idle" then
			warn("Targetting the Head!")
			Functions.EnableIKControl(stateEngine, true)
		end

	end
	
end)

UserInputService.InputEnded:Connect(function(input, gameProcessedEvent)
	if gameProcessedEvent then return end
	
	if input.UserInputType == Enum.UserInputType.MouseButton2 or input.KeyCode == Enum.KeyCode.ButtonL2 then
		
		if stateEngine:GetState() == "Block" then
			stateEngine:Transition("Idle")
		end

	elseif input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.ButtonL1 then
		Functions.EnableIKControl(stateEngine, false)
	end
	
end)

GetStateFunc.OnClientInvoke = function()
	return stateEngine:GetState()
end

TransitionStateEvent.OnClientEvent:Connect(function(newState, substate)
	print("TransitionStateEvent.OnClientEvent()")
	stateEngine:Transition(newState, substate)
end)

DrainBlock.OnClientEvent:Connect(function()
	print("stateEngine.Attributes.dvStaminaDrain: ", tostring(stateEngine.Attributes.dvStaminaDrain))
	local blockBroken = Functions.DrainBlock(VitalsUi.Stamina.Block.BarSlot.Bar, stateEngine.Attributes.dvStaminaDrain)
	
	if blockBroken then
		stateEngine:Transition("Idle") 
	end
	
end)