local Players_Service = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local RaycastHitboxV4 = require(ReplicatedStorage.Shared.Modules.Imported.RaycastHitboxV4.Hitbox)
local FighterAttributes = require(ReplicatedStorage.Shared.Modules.FighterAttributes)

local Remotes = {

	Events = {
		Controls = ReplicatedStorage.Remotes.Events.Setup.Controls,
		IKController = ReplicatedStorage.Remotes.Events.Ring.Combat.IKController,
		Attack = ReplicatedStorage.Remotes.Events.Ring.Combat.Attack,
		Health = ReplicatedStorage.Remotes.Events.Ring.Combat.Vitals.Health,
		Block = ReplicatedStorage.Remotes.Events.Ring.Combat.Vitals.Block
	},

	Functions = {
		State = ReplicatedStorage.Remotes.Functions.State,
	}

}

--local GetStateFunc = ReplicatedStorage.Remotes.States.Get
--local TransitionStateEvent = ReplicatedStorage.Remotes.States.Transition
--local ControlsEnabled = ReplicatedStorage.Remotes.Ring.Other["Controls/Enabled"]
--local IKController = ReplicatedStorage.Remotes.Ring.Combat.IKController
--local AttackEvent = ReplicatedStorage.Remotes.Ring.Combat.Attack
--local UpdateHealth = ReplicatedStorage.Remotes.Ring.Combat.Vitals.Health.Update
--local DrainBlockEvent = ReplicatedStorage.Remotes.Ring.Combat.Vitals.Stamina["Block/Drain"]

local Functions = {}

function Functions.LockOrientation(self)
	
	if self.Opponent and self:GetState() ~= "Default" then
		local HumanoidRootPart = self.Character.HumanoidRootPart
		local OpponentRootPart = self.Opponent.Character:WaitForChild("HumanoidRootPart")
		local targetAngle = Vector3.new(OpponentRootPart.Position.X, HumanoidRootPart.Position.Y, OpponentRootPart.Position.Z)

		if not HumanoidRootPart:FindFirstChild("BodyGyro") then
			local bodyGyro = Instance.new("BodyGyro", HumanoidRootPart)
			bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
			bodyGyro.P = 125000
		end

		HumanoidRootPart.BodyGyro.CFrame = CFrame.lookAt(HumanoidRootPart.Position, targetAngle)
	else
		if not self.Character.HumanoidRootPart:FindFirstChild("BodyGyro") then return end
		Debris:AddItem(self.Character.HumanoidRootPart.BodyGyro, 0)
	end
	
end

function Functions.OffensiveStamina(self)
	if self:GetState() == "Attack" then return end
	local Humanoid = self.Character.Humanoid
	local Attributes = self.Attributes
	local currentStamina = Humanoid:GetAttribute("OffensiveStamina")
	local maxStamina = Attributes.ofStamina
	local staminaRegen = Attributes.ofStaminaRegen
	local newStamina = math.min(currentStamina + staminaRegen, maxStamina)
	local barSize = UDim2.new(newStamina / maxStamina, 0, 1, 0)
	Humanoid:SetAttribute("OffensiveStamina", newStamina)
	self.VitalsUi.Stamina.Offensive.Bar.Size = barSize
end

function Functions.BlockStamina(self)
	if self:GetState() == "Block" then return end
	--local Bar = self.VitalsUi.Stamina.Block.BarSlot.Bar
	--if Bar.Size.X.Scale >= 1 then return end
	--if Bar.Size.X.Scale <= 0 then
		--if Bar.BackgroundTransparency >= 1 then
			--Bar.Transparency = 1 
		--end
	--end
	--Bar.Size = UDim2.new(Bar.Size.X.Scale + self.Attributes.dvStaminaRegen, 0, 1, 0)
	local Humanoid = self.Character.Humanoid
	local currentStamina = Humanoid:GetAttribute("DefensiveStamina")
	if currentStamina >= self.Attributes.dvStamina then return end
	local Attributes = self.Attributes
	local maxStamina = Attributes.dvStamina
	local staminaRegen = Attributes.dvStaminaRegen
	local newStamina = math.min(currentStamina + staminaRegen, maxStamina)
	local barSize = UDim2.new(newStamina / maxStamina, 0, 1, 0)
	print("block stamina regenning...")
	Humanoid:SetAttribute("DefensiveStamina", currentStamina + self.Attributes.dvStaminaRegen)
	self.VitalsUi.Stamina.Block.BarSlot.Bar.Size = barSize
end

function Functions.EnableIKControl(self, Enabled)

	if Enabled then
		self:UpdateTarget("Head")
	else
		self:UpdateTarget("Body")
	end

	Remotes.Events.IKController:FireServer(Enabled, self.Opponent.UserId)
end

function Functions.Attack(substate, self)
	local Humanoid = self.Character.Humanoid
	local Attributes = self.Attributes
	local punchAnimations = self.Animations.Punches
	local Target = self:GetTarget()

	local currentStamina = Humanoid:GetAttribute("OffensiveStamina")
	local maxStamina = Attributes.ofStamina
	local Track
	local staminaDrain

	if substate == "Jab" then
		print("current jab: ", tostring(self.currentJab))
		print("total jabs: ", tostring(self.maxJabs))
		if self.currentJab <= self.maxJabs then
			Track = punchAnimations.Jabs[tostring(self.currentJab)]
			self.currentJab = self.currentJab + 1
		else
			self.currentJab = 1
			Track = punchAnimations.Jabs["1"]
		end
	else
		Track = punchAnimations[substate]
	end

	local animLength = Track.Length
	local dbLength = animLength / 2
	local oldSpeed = Humanoid.WalkSpeed

	if Target == "Body" then
		staminaDrain = Attributes.ofStaminaDrain
	else
		staminaDrain = Attributes.ofStaminaDrain * Attributes.headshotStaminaDrainMultiplier
	end

	local newStamina = math.max(currentStamina - staminaDrain, 0)
	local barSize = UDim2.new(newStamina / maxStamina, 0, 1, 0)
	
	Humanoid:SetAttribute("OffensiveStamina", newStamina)
	print("Tweening bar")
	self.VitalsUi.Stamina.Offensive.Bar:TweenSize(barSize, Enum.EasingDirection.In, Enum.EasingStyle.Linear, 0.1)
	Humanoid.WalkSpeed = Humanoid.WalkSpeed / 2
	Track:Play()
	Remotes.Events.Attack:FireServer(Target, substate, animLength)
	task.wait(0.1)
	warn("is the bar tween done?")
	task.wait(dbLength - 0.1)
	print("Attack over!")
	Humanoid.WalkSpeed = oldSpeed
end

function Functions.DrainBlock(self)
	--local barXScale = Bar.Size.X.Scale
	--local barLength = barXScale - ((Drain / 100) * barXScale)
	--local barSize = UDim2.new(barLength, 0, 1, 0)
	local Humanoid = self.Character.Humanoid
	local currentStamina = Humanoid:GetAttribute("DefensiveStamina")
	local staminaDrain = self.Attributes.dvStaminaDrain
	local maxStamina = self.Attributes.dvStamina
	local blockBroken = false

	local newStamina = math.max(currentStamina - staminaDrain, 0)
	local barSize = UDim2.new(newStamina / maxStamina, 0, 1, 0)

	if currentStamina > staminaDrain then
		Humanoid:SetAttribute("DefensiveStamina", currentStamina - staminaDrain)
		self.VitalsUi.Stamina.Block.BarSlot.Bar:TweenSize(barSize, Enum.EasingDirection.In, Enum.EasingStyle.Linear, 0.1)
		print("block stamina drained!")
	else
		blockBroken = true
	end
	
	--[[
	if barLength > 0.01 then
		barSize = UDim2.new(barLength, 0, 1, 0)
	else
		blockBroken = true
		barSize = UDim2.new(0, 0, 1, 0)
	end
	]]

	--Bar:TweenSize(barSize, Enum.EasingDirection.In, Enum.EasingStyle.Linear, 0.1)
	return blockBroken
end

function Functions.IKController(Player, Enabled, userId)
	print("IKController")
	local Character = Player.Character
	local Humanoid = Character.Humanoid
	local IKControl = Character.Humanoid.IKControl
	local Opponent = nil

		for _, player in ipairs(Players_Service:GetChildren()) do
			if player.UserId ~= userId then continue end
			Opponent = player
		end

	if Enabled then
		IKControl.Target = Opponent.Character.Head
	else
		IKControl.Target = Opponent.Character.LowerTorso
	end

end

function Functions.Damage(Player, Target, attackType, animLength)
	local Character = Player.Character
	local cHumanoid = Character.Humanoid
	
	if cHumanoid:GetAttribute("BodyVigor") <= 0 or cHumanoid:GetAttribute("HeadVigor") <= 0 then return end
	
	local cAttributes = FighterAttributes[cHumanoid:GetAttribute("Fighter")]
	local cSounds = Character.HumanoidRootPart.Sounds
	local Hitbox = RaycastHitboxV4.new(Character)
	
	cSounds.Combat.Swing:Play()
	
	task.spawn(function()
		Hitbox:HitStart()
		task.wait(animLength)
		Hitbox:HitStop()
	end)
	
	Hitbox.OnHit:Connect(function(Hit, Humanoid)
		local Opponent = Players_Service:GetPlayerFromCharacter(Humanoid.Parent)
		local oAttributes = FighterAttributes[Humanoid:GetAttribute("Fighter")]
		local oSounds = Opponent.Character.HumanoidRootPart.Sounds
		
		local function Knock(knockType)
			Character.Humanoid.IKControl.Enabled = false
			Character.Humanoid.IKControl.Target = nil
			Humanoid.IKControl.Enabled = false
			Humanoid.IKControl.Target = nil
			Remotes.Events.Controls:FireAllClients("Disable")
			Remotes.Functions.State:InvokeClient(Player, "Update", "Default", "Disabled")
			Remotes.Functions.State:InvokeClient(Opponent, "Update", "Default", knockType)
			cHumanoid:SetAttribute("BodyVigor", cAttributes.bodyVigor)
			Humanoid:SetAttribute("BodyVigor", oAttributes.bodyVigor)
		end
		
		local function Damage(humVigor, attVigor)
			Humanoid:SetAttribute(humVigor, Humanoid:GetAttribute(humVigor) - cAttributes.Damage[attackType])
			Remotes.Events.Health:FireClient(Player, "Player", humVigor, Humanoid:GetAttribute(humVigor) / oAttributes[attVigor])
			Remotes.Events.Health:FireClient(Opponent, "Opponent", humVigor, Humanoid:GetAttribute(humVigor) / oAttributes[attVigor])
			Remotes.Functions.State:InvokeClient(Opponent, "Update", "Knockback", attackType)
		end
		
		if Opponent.Character == Character then return end
		if (Opponent.Character.HumanoidRootPart.Position - Character.HumanoidRootPart.Position).Magnitude > 5 then return end
		oSounds.Combat.Hit:Play()
		
		if  Remotes.Functions.State:InvokeClient(Opponent, "Get") == "Block" then
			Remotes.Events.Block:FireClient(Opponent, Humanoid:GetAttribute("BlockDrain"))
		else
			print(Player.Name, " hit ", Opponent.Name, " with a", attackType)
			--Humanoid:LoadAnimation(ReplicatedStorage.Animations.Collisions.Punches[attackType]):Play()

			if Target == "Head" or attackType == "Uppercut" then
				Damage("HeadVigor", "headVigor")
			else
				Damage("BodyVigor", "bodyVigor")
			end
			
			if Humanoid:GetAttribute("HeadVigor") <= 0 then
				Knock("Knockout")
			elseif Humanoid:GetAttribute("BodyVigor") <= 0 then
				print("Players's health when knocked down opponent: ", tostring(cHumanoid:GetAttribute("BodyVigor")))
				Knock("Knockdown")
			end 
			
		end
		
	end)
	
end

return Functions