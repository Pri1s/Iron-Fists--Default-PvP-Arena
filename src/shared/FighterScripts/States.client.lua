local Players_Service = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Settings = require(ReplicatedStorage.Shared.Modules.Settings)
local States = require(ReplicatedStorage.Shared.Modules.Primary.Combat.States)
local Functions = require(ReplicatedStorage.Shared.Modules.Primary.Combat.Functions)
local Interface = require(ReplicatedStorage.Shared.Modules.Primary.Interface)

local Player = Players_Service.LocalPlayer
local PlayerGui = Player.PlayerGui
local VitalsUi = PlayerGui:WaitForChild("Vitals")
local TimeUi = PlayerGui:WaitForChild("Time")

local Character = Player.Character
local Humanoid = Character:WaitForChild("Humanoid")

local GetStateFunc = ReplicatedStorage.Remotes.States.Get
local TransitionStateEvent = ReplicatedStorage.Remotes.States.Transition
local DrainBlock = ReplicatedStorage.Remotes.Ring.Combat.Vitals.Stamina["Block/Drain"]
local OpponentData = ReplicatedStorage.Remotes.Ring.Other["Opponent/Data"]

local Emotes = ReplicatedStorage.Animations.Emotes
local punchAnimations = ReplicatedStorage.Animations.Punches

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
		Jab = Humanoid:LoadAnimation(punchAnimations.Jab),
		Cross = Humanoid:LoadAnimation(punchAnimations.Cross),
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

repeat task.wait() until #Players_Service:GetChildren() >= 2
task.wait(Settings.Delays.initializeMatch)

for _, v in ipairs(Players_Service:GetChildren()) do
	
	if v:IsA("Player") and v.UserId ~= Player.UserId then
		repeat task.wait() until v.Character
		stateEngine:Initialize(v.Character)
	end
	
end

UserInputService.MouseIconEnabled = false

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
	if gameProcessedEvent then return end
	
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		
		if stateEngine:GetState() == "Idle" then
			print(VitalsUi.Stamina.Offensive.Bar.Size.X.Scale)
			print(stateEngine.Attributes.ofStaminaDrain / stateEngine.Attributes.ofStamina)
			print(VitalsUi.Stamina.Offensive.Bar.Size.X.Scale - (stateEngine.Attributes.ofStaminaDrain / stateEngine.Attributes.ofStamina))
			if VitalsUi.Stamina.Offensive.Bar.Size.X.Scale - (stateEngine.Attributes.ofStaminaDrain / stateEngine.Attributes.ofStamina) <= 0 then return end
			
			if not stateEngine.previousAttack or stateEngine.previousAttack ~= "Jab" then
				stateEngine:Transition("Attack", "Jab")
			elseif stateEngine.previousAttack == "Jab" then
				stateEngine:Transition("Attack", "Cross")
			end
			
		end
		
	elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
		if VitalsUi.Stamina.Block.BarSlot.Bar.Size.X.Scale - (stateEngine.Attributes.dvStaminaDrain / stateEngine.Attributes.dvStamina) <= 0 then return end
		
		if stateEngine:GetState() == "Idle" then
			stateEngine:Transition("Block")
		end
		
	elseif input.KeyCode == Enum.KeyCode.E then
		if VitalsUi.Stamina.Offensive.Bar.Size.X.Scale - (stateEngine.Attributes.ofStaminaDrain / stateEngine.Attributes.ofStamina) <= 0 then return end

		if stateEngine:GetState() == "Idle" then
			stateEngine:Transition("Attack", "Hook")
		end
		
	elseif input.KeyCode == Enum.KeyCode.F then
		if VitalsUi.Stamina.Offensive.Bar.Size.X.Scale - (stateEngine.Attributes.ofStaminaDrain / stateEngine.Attributes.ofStamina) <= 0 then return end
		if tick() - Cooldowns.Uppercut.previousInputTime < Cooldowns.Uppercut.Duration then return end

		if stateEngine:GetState() == "Idle" then
			stateEngine:Transition("Attack", "Uppercut")
		end
		
		Cooldowns.Uppercut.previousInputTime = tick()
	elseif input.KeyCode == Enum.KeyCode.Space then
		
		if stateEngine:GetState() == "Idle" then
			if stateEngine.Target == "Head" then return end
			warn("Targetting the Head!")
			stateEngine:UpdateTarget("Head")
		end

	end
	
end)

UserInputService.InputEnded:Connect(function(input, gameProcessedEvent)
	if gameProcessedEvent then return end
	
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		
		if stateEngine:GetState() == "Block" then
			stateEngine:Transition("Idle")
		end

	elseif input.KeyCode == Enum.KeyCode.Space then
		
		if stateEngine:GetState() == "Idle" then
			warn("Stopped targetting the Head")
			stateEngine:UpdateTarget("Head")
		end

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