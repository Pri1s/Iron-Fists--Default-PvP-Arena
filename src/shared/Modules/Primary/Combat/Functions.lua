local Players_Service = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local RaycastHitboxV4 = require(ReplicatedStorage.Shared.Modules.Imported.RaycastHitboxV4.Hitbox)
local FighterAttributes = require(ReplicatedStorage.Shared.Modules.FighterAttributes)

local GetStateFunc = ReplicatedStorage.Remotes.States.Get
local TransitionStateEvent = ReplicatedStorage.Remotes.States.Transition
local ControlsEnabled = ReplicatedStorage.Remotes.Ring.Other["Controls/Enabled"]
local IKController = ReplicatedStorage.Remotes.Ring.Combat.IKController
local AttackEvent = ReplicatedStorage.Remotes.Ring.Combat.Attack
local UpdateHealth = ReplicatedStorage.Remotes.Ring.Combat.Vitals.Health.Update
local DrainBlockEvent = ReplicatedStorage.Remotes.Ring.Combat.Vitals.Stamina["Block/Drain"]

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
	local Bar = self.VitalsUi.Stamina.Offensive.Bar
	if Bar.Size.X.Scale >= 1 then return end
	Bar.Size = UDim2.new(Bar.Size.X.Scale + self.Attributes.ofStaminaRegen, 0, 1, 0)
end

function Functions.BlockStamina(self)
	if self:GetState() == "Block" then return end
	local Bar = self.VitalsUi.Stamina.Block.BarSlot.Bar
	if Bar.Size.X.Scale >= 1 then return end
	
	if Bar.Size.X.Scale <= 0 then
		
		if Bar.BackgroundTransparency >= 1 then
			Bar.Transparency = 1 
		end
		
	end
	
	Bar.Size = UDim2.new(Bar.Size.X.Scale + self.Attributes.dvStaminaRegen, 0, 1, 0)
end

function Functions.EnableIKControl(self, Enabled)

	if Enabled then
		self:UpdateTarget("Head")
	else
		self:UpdateTarget("Body")
	end

	IKController:FireServer(Enabled, self.Opponent.UserId)
end

function Functions.Attack(substate, self)
	local VitalsUi = self.VitalsUi
	local Humanoid = self.Character.Humanoid
	local Attributes = self.Attributes
	local punchAnimations = self.Animations.Punches
	local Target = self:GetTarget()
	
	local Track
	local staminaDrain

	if substate == "Jab" then

		if self.currentJab <= #punchAnimations.Jabs:GetChildren() then
			Track = Humanoid:LoadAnimation(punchAnimations.Jabs[tostring(self.currentJab)])
			self.currentJab = self.currentJab + 1
		else
			self.currentJab = 1
			Track = Humanoid:LoadAnimation(punchAnimations.Jabs["1"])
		end

	else
		Track = punchAnimations[substate]
	end

	if Target == "Body" then
		staminaDrain = Attributes.ofStaminaDrain / Attributes.ofStamina
	elseif Target == "Head" then
		staminaDrain = (Attributes.ofStaminaDrain * Attributes.headshotStaminaDrainMultiplier) / Attributes.ofStamina
	end

	local animLength = Track.Length
	local dbLength = animLength / 2
	
	local oldSpeed = Humanoid.WalkSpeed
	
	local Bar = VitalsUi.Stamina.Offensive.Bar
	local barSize = UDim2.new(Bar.Size.X.Scale - staminaDrain, 0, 1, 0)
	local staminaBarTween = Bar:TweenSize(barSize, Enum.EasingDirection.In, Enum.EasingStyle.Linear, 0.1)
	
	Humanoid.WalkSpeed = Humanoid.WalkSpeed / 2
	Track:Play()
	AttackEvent:FireServer(Target, substate, animLength)
	task.wait(dbLength)
	Humanoid.WalkSpeed = oldSpeed
end

function Functions.DrainBlock(Bar, Drain)
	local barLength = Bar.Size.X.Scale - (Drain / 100)
	local barSize = UDim2.new(barLength, 0, 1, 0)
	local blockBroken = false
	
	if barLength > 0.01 then
		barSize = UDim2.new(barLength, 0, 1, 0)
	else
		blockBroken = true
		barSize = UDim2.new(0, 0, 1, 0)
	end

	Bar:TweenSize(barSize, Enum.EasingDirection.In, Enum.EasingStyle.Linear, 0.1)
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
	local cAttributes = FighterAttributes[cHumanoid:GetAttribute("Fighter")]
	local cSounds = Character.HumanoidRootPart.Sounds
	local Hitbox = RaycastHitboxV4.new(Character)
	
	cSounds.Combat.Swing:Play()
	cHumanoid:SetAttribute("OffensiveStamina", cHumanoid:GetAttribute("OffensiveStamina") - cAttributes.ofStaminaDrain)
	
	task.spawn(function()
		Hitbox:HitStart()
		task.wait(animLength)
		Hitbox:HitStop()
	end)
	
	Hitbox.OnHit:Connect(function(Hit, Humanoid)
		local Opponent = Players_Service:GetPlayerFromCharacter(Humanoid.Parent)
		local oAttributes = FighterAttributes[Humanoid:GetAttribute("Fighter")]
		local oSounds = Opponent.Character.HumanoidRootPart.Sounds
		local oState = GetStateFunc:InvokeClient(Opponent)
		
		local function Knock(knockType)
			Character.Humanoid.IKControl.Enabled = false
			Character.Humanoid.IKControl.Target = nil
			Humanoid.IKControl.Enabled = false
			Humanoid.IKControl.Target = nil
			ControlsEnabled:FireAllClients("Disable")
			TransitionStateEvent:FireClient(Player, "Default", "Disabled")
			TransitionStateEvent:FireClient(Opponent, "Default", knockType)
			cHumanoid:SetAttribute("BodyVigor", cAttributes.bodyVigor)
			Humanoid:SetAttribute("BodyVigor", oAttributes.bodyVigor)
		end
		
		local function Damage(humVigor, attVigor)
			Humanoid:SetAttribute(humVigor, Humanoid:GetAttribute(humVigor) - cAttributes.Damage[attackType])
			UpdateHealth:FireClient(Player, "Player", humVigor, Humanoid:GetAttribute(humVigor) / oAttributes[attVigor])
			UpdateHealth:FireClient(Opponent, "Opponent", humVigor, Humanoid:GetAttribute(humVigor) / oAttributes[attVigor])
		end
		
		if Opponent.Character == Character then return end
		if (Opponent.Character.HumanoidRootPart.Position - Character.HumanoidRootPart.Position).Magnitude > 5 then return end
		oSounds.Combat.Hit:Play()
		
		if oState == "Block" then
			DrainBlockEvent:FireClient(Opponent, Humanoid:GetAttribute("BlockDrain"))
		else
			print(Player.Name, " hit ", Opponent.Name, " with a", attackType)
			Humanoid:LoadAnimation(ReplicatedStorage.Animations.Collisions.Punches[attackType]):Play()

			if Target == "Head" or attackType == "Uppercut" then
				Damage("HeadVigor", "headVigor")
			else
				Damage("BodyVigor", "bodyVigor")
			end
			
			if Humanoid:GetAttribute("HeadVigor") <= 0 then
				Knock("Knockout")
			elseif Humanoid:GetAttribute("BodyVigor") <= 0 then
				Knock("Knockdown")
			end 
			
		end
		
	end)
	
end

return Functions