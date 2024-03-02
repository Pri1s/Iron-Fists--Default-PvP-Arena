local Players_Service = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local RaycastHitboxV4 = require(ReplicatedStorage.Shared.Modules.Imported.RaycastHitboxV4.Hitbox)
local FighterAttributes = require(ReplicatedStorage.Shared.Modules.FighterAttributes)

local GetStateFunc = ReplicatedStorage.Remotes.States.Get
local TransitionStateEvent = ReplicatedStorage.Remotes.States.Transition
local ControlsEnabled = ReplicatedStorage.Remotes.Ring.Other["Controls/Enabled"]
local UpdateHealth = ReplicatedStorage.Remotes.Ring.Combat.Vitals.Health.Update
local AttackEvent = ReplicatedStorage.Remotes.Ring.Combat.Attack
local DrainBlockEvent = ReplicatedStorage.Remotes.Ring.Combat.Vitals.Stamina["Block/Drain"]

local Functions = {}

function Functions.LockOrientation(self)
	
	if self.Opponent and self:GetState() ~= "Default" then
		local HumanoidRootPart = self.Character.HumanoidRootPart
		local OpponentRootPart = self.Opponent:WaitForChild("HumanoidRootPart")
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

function Functions.Attack(substate, VitalsUi, Humanoid, Attributes, Animations)
	local Track = Animations.Punches[substate]
	local animLength = Track.Length
	local dbLength = animLength / 2
	
	local oldSpeed = Humanoid.WalkSpeed
	local staminaDrain = Attributes.ofStaminaDrain / Attributes.ofStamina
	
	local Bar = VitalsUi.Stamina.Offensive.Bar
	local barSize = UDim2.new(Bar.Size.X.Scale - staminaDrain, 0, 1, 0)
	local staminaBarTween = Bar:TweenSize(barSize, Enum.EasingDirection.In, Enum.EasingStyle.Linear, 0.1)
	
	Humanoid.WalkSpeed = Humanoid.WalkSpeed / 2
	Track:Play()
	AttackEvent:FireServer(substate, animLength)
	task.wait(dbLength)
	Humanoid.WalkSpeed = oldSpeed
end

function Functions.DrainBlock(Bar, Drain)
	print("Bar.Size.X.Scale: ", tostring(Bar.Size.X.Scale))
	print("Drain: ", Drain)
	print("barLength: ", Bar.Size.X.Scale - Drain)
	local barLength = Bar.Size.X.Scale - Drain
	local barSize = UDim2.new(barLength, 0, 1, 0)
	local blockBroken = false
	
	if barLength > 0 then
		barSize = UDim2.new(barLength, 0, 1, 0)
	else
		warn("blockBroken = true")
		blockBroken = true
		barSize = UDim2.new(0, 0, 1, 0)
	end

	Bar:TweenSize(barSize, Enum.EasingDirection.In, Enum.EasingStyle.Linear, 0.1)
	return blockBroken
end

function Functions.Damage(Player, attackType, animLength)
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
		local Enemy = Players_Service:GetPlayerFromCharacter(Humanoid.Parent)
		local Opponent = Enemy.Character
		local oAttributes = FighterAttributes[Humanoid:GetAttribute("Fighter")]
		local opponentState = GetStateFunc:InvokeClient(Enemy)
		
		local function Knock(knockType)
			ControlsEnabled:FireAllClients("Disable")
			TransitionStateEvent:FireClient(Player, "Default", nil)
			TransitionStateEvent:FireClient(Enemy, "Default", knockType)
			cHumanoid:SetAttribute("HeadVigor", cAttributes.headVigor)
			cHumanoid:SetAttribute("BodyVigor", cAttributes.bodyVigor)
			Humanoid:SetAttribute("HeadVigor", oAttributes.headVigor)
			Humanoid:SetAttribute("BodyVigor", oAttributes.bodyVigor)
		end
		
		local function Damage(humVigor, attVigor)
			print(Humanoid:GetAttribute(humVigor) - cAttributes.Damage)
			Humanoid:SetAttribute(humVigor, Humanoid:GetAttribute(humVigor) - cAttributes.Damage)
			UpdateHealth:FireClient(Player, "Player", humVigor, Humanoid:GetAttribute(humVigor) / oAttributes[attVigor])
			UpdateHealth:FireClient(Enemy, "Opponent", humVigor, Humanoid:GetAttribute(humVigor) / oAttributes[attVigor])
		end
		
		if Opponent == Character then return end
		if (Opponent.HumanoidRootPart.Position - Character.HumanoidRootPart.Position).Magnitude > 5 then return end
		
		if opponentState == "Block" then
			DrainBlockEvent:FireClient(Enemy, Humanoid:GetAttribute("BlockDrain"))
		else
			print(Player.Name, " hit ", Opponent.Name, " with a", attackType)
			Humanoid:LoadAnimation(ReplicatedStorage.Animations.Collisions.Punches[attackType]):Play()
			
			if attackType == "Uppercut" then
				Damage("HeadVigor", "headVigor")
			else
				Damage("BodyVigor", "bodyVigor")
			end
			
			if Humanoid:GetAttribute("HeadVigor") <= 0 then
				Knock("Knockout")
			elseif Humanoid:GetAttribute("BodyVigor") <= 0 then
				Knock("Thump")
			end 
			
		end
		
	end)
	
end

return Functions