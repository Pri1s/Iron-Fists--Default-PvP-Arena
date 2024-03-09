local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Functions = require(script.Parent.Functions)
local Interface = require(ReplicatedStorage.Shared.Modules.Primary.Interface)
local FighterAttributes = require(ReplicatedStorage.Shared.Modules.FighterAttributes)

local KnockedEvent = ReplicatedStorage.Remotes.Ring.Combat.Knocked

local States = {}
States.__index =  States

function States.new(Player, Animations, Attributes)
	local self = setmetatable({}, States)
	
	self.Player = Player
	self.VitalsUi = Player.PlayerGui:WaitForChild("Vitals")
	self.TimeUi = Player.PlayerGui:WaitForChild("Time")
	
	self.Character = Player.Character
	self.Animations = Animations
	self.Attributes = FighterAttributes[Player.Character.Humanoid:GetAttribute("Fighter")]
	
	self.previousState = nil
	self.currentState = nil
	self.previousAttack  = nil
	self.Opponent = nil
	self.Target = nil
	
	return self
end

function States:Initialize(Opponent)
	print("Initialized")
	self.Opponent = Opponent
	self.Target = "Body"
	self:Transition("Default", nil)
	
	RunService.RenderStepped:Connect(function()
		Functions.LockOrientation(self)
		Functions.OffensiveStamina(self)
		Functions.BlockStamina(self)
	end)
	
end

function States:GetState()
	return self.currentState
end

function States:Transition(newState, substate)
	warn("Changing state, new state is ", newState)
	self.previousState = self.currentState
	self.currentState = newState
	
	if newState == "Default" then
		self:Default(substate)
	elseif newState == "Idle" then
		self:Idle()
	elseif newState == "Attack" then
		self.previousAttack = substate
		self:Attack(substate)
	elseif newState == "Block" then
		self:Block()
	end
	
end

function States:UpdateTarget(Target)
	self.Target = Target
end

function States:Reset()
	self.VitalsUi.Stamina.Offensive.Bar.Size = UDim2.new(1, 0, 1, 0)
	self.VitalsUi.Stamina.Block.BarSlot.Bar.Size = UDim2.new(1, 0, 1, 0)
	self.VitalsUi.Health.Player.HeadVigor.Bar.Size = UDim2.new(1, 0, 1, 0)
	self.VitalsUi.Health.Player.BodyVigor.Bar.Size = UDim2.new(1, 0, 1, 0)
	self.VitalsUi.Health.Opponent.HeadVigor.Bar.Size = UDim2.new(1, 0, 1, 0)
	self.VitalsUi.Health.Opponent.BodyVigor.Bar.Size = UDim2.new(1, 0, 1, 0)
end

function States:Default(substate)
	self.Animations.Walk:Stop()
	self.Animations.Block:Stop()
	if self.Target == "Head" then Functions.EnableIKControl(self, false) end
	if self.previousState == "Block" then Interface.BlockStaminaFrameTransition(self.VitalsUi.Stamina.Block, false) end
	
	if substate == "Ready" then
		self.Animations.Emotes.Ready:Play()
	elseif substate == "Celebration" then
		self.Animations.Emotes.Celebrate:Play()
	elseif substate == "Defeat" then
		self.Animations.Emotes.Defeat:Play()
	elseif substate == "Knockdown" then
		self.Animations.Thump:Play()
		print("Knock animation length: ", tostring(self.Animations.Thump.Length))
		task.wait(self.Animations.Thump.Length - 0.3)
		KnockedEvent:FireServer("Knockdown")
	elseif substate == "Knockout" then
		self.Animations.Knockout:Play()
		print("Knock animation length: ", tostring(self.Animations.Knockout.Length))
		task.wait(self.Animations.Knockout.Length - 0.45)
		KnockedEvent:FireServer("Knockout")
	elseif substate == "Disabled" then
		if self.previousState ~= "Default" then self.Animations.Walk:Play() end
	end
	
end

function States:Idle()
	self.Animations.Block:Stop()
	self.Animations.Walk:Play()
	
	if self.previousState == "Default" then
		self.VitalsUi.Enabled = true
		self.TimeUi.Enabled = true
		self:Reset()
	elseif self.previousState == "Block" then
		self.Character.Humanoid.WalkSpeed = self.Character.Humanoid.WalkSpeed * 2
		Interface.BlockStaminaFrameTransition(self.VitalsUi.Stamina.Block, false)
	end
	
end

function States:Attack(substate)
	self.Animations.Walk:Stop()
	Functions.Attack(substate, self.VitalsUi, self.Character.Humanoid, self.Attributes, self.Animations, self.Target)
	if self:GetState() == "Attack" then self:Transition("Idle") end
end

function States:Block()
	self.Animations.Walk:Stop()
	self.Animations.Block:Play()
	self.Character.Humanoid.WalkSpeed = self.Character.Humanoid.WalkSpeed / 2
	Interface.BlockStaminaFrameTransition(self.VitalsUi.Stamina.Block, true)
end

return States