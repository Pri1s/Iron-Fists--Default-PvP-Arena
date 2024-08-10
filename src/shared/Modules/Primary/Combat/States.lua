local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Functions = require(script.Parent.Functions)
local Interface = require(ReplicatedStorage.Shared.Modules.Primary.Interface)
local FighterAttributes = require(ReplicatedStorage.Shared.Modules.FighterAttributes)

local KnockedEvent = ReplicatedStorage.Remotes.Events.Ring.Combat.Knocked

local Emotes = ReplicatedStorage.Animations.Emotes

local function StopTracks(Tracks)

	for _, value in pairs(Tracks) do

		if typeof(value) == "Instance" and value:IsA("AnimationTrack") then
			value:Stop()
		elseif typeof(value) == "table" then
			StopTracks(value)
		end

	end

end

local function LoadAnimations(Humanoid, Animations)
	local loadedAnimations = {}

	for key, value in pairs(Animations) do

		if typeof(value) == "Instance" and value:IsA("Animation") then
			loadedAnimations[tostring(key)] = Humanoid:LoadAnimation(value)
		elseif typeof(value) == "table" then
			loadedAnimations[tostring(key)] = LoadAnimations(Humanoid, value)
		else
			loadedAnimations[tostring(key)] = value
		end

	end

	return loadedAnimations
end

local States = {}
States.__index = States

function States.new(Player)
    local self = setmetatable({}, States)

    self.Player = Player
    self.VitalsUi = Player.PlayerGui:WaitForChild("Vitals")
    self.TimeUi = Player.PlayerGui:WaitForChild("Time")

    self.Character = Player.Character
    self.Attributes = FighterAttributes[Player.Character.Humanoid:GetAttribute("Fighter")]
    
    local Humanoid = Player.Character.Humanoid
    local punchAnimations = ReplicatedStorage.Animations.Punches.Amputation[FighterAttributes[Player.Character.Humanoid:GetAttribute("Fighter")].Amputation]

    self.Animations = { -- For code efficiency, try to Load all these animations using the LoadAnimations() function, rather than loading each one individually, manually
        Walk = Humanoid:LoadAnimation(ReplicatedStorage.Animations.Walk),
        Block = Humanoid:LoadAnimation(ReplicatedStorage.Animations.Block),

        Emotes = {
            Ready = Humanoid:LoadAnimation(Emotes.Ready),
            Celebrate = Humanoid:LoadAnimation(Emotes.Celebrate),
            Defeat = Humanoid:LoadAnimation(Emotes.Defeat)
        },

        Punches = {
            Jabs = LoadAnimations(Humanoid, punchAnimations.Jabs:GetChildren()),
            Uppercut = Humanoid:LoadAnimation(punchAnimations.Uppercut),
            Hook = Humanoid:LoadAnimation(punchAnimations.Hook)
        },

        Collisions = {
            Knockdown  = Humanoid:LoadAnimation(ReplicatedStorage.Animations.Collisions.Knockdown),
            Knockout = Humanoid:LoadAnimation(ReplicatedStorage.Animations.Collisions.Knockout),

            Punches = {
                Hook = Humanoid:LoadAnimation(ReplicatedStorage.Animations.Collisions.Punches.Hook),
                Jab = Humanoid:LoadAnimation(ReplicatedStorage.Animations.Collisions.Punches.Jab),
                Uppercut = Humanoid:LoadAnimation(ReplicatedStorage.Animations.Collisions.Punches.Uppercut)
            }

        }

    }

    self.previousState = nil
    self.currentState = nil
    self.Opponent = nil
    self.Target = nil
    self.currentJab = 1
    self.maxJabs = #punchAnimations.Jabs:GetChildren()

    return self
end

function States:Initialize(Opponent)
    print("Initialized")
    local Humanoid = self.Character.Humanoid
    Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
    Humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
    Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)

    self.Opponent = Opponent
    self:UpdateTarget("Body")
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
    --warn("Changing state, new state is ", newState)
    self.previousState = self.currentState
    self.currentState = newState

    if newState == "Default" then
        self:Default(substate)
    elseif newState == "Idle" then
        self:Idle()
    elseif newState == "Attack" then
        -- self.previousAttack = substate
        self:Attack(substate)
    elseif newState == "Block" then
        self:Block()
    elseif newState == "Knockback" then
        self:Knockback(substate)
    end

end

function States:GetTarget()
    return self.Target
end

function States:UpdateTarget(Target)
    self.Target = Target
end

function States:Reset()
    self.VitalsUi.Stamina.Offensive.Bar.Size = UDim2.new(1, 0, 1, 0)
    self.VitalsUi.Stamina.Block.BarSlot.Bar.Size = UDim2.new(1, 0, 1, 0)
    self.VitalsUi.Health.Player.BodyVigor.Bar.Size = UDim2.new(1, 0, 1, 0)
    self.VitalsUi.Health.Opponent.BodyVigor.Bar.Size = UDim2.new(1, 0, 1, 0)
end

function States:Default(substate)
    --self.Animations.Walk:Stop()
    --self.Animations.Block:Stop()
    StopTracks(self.Animations)
    
    if self:GetTarget() == "Head" then
        Functions.EnableIKControl(self, false)
    end
    if self.previousState == "Block" then
        Interface.BlockStaminaFrameTransition(self.VitalsUi.Stamina.Block, false)
    end

    if substate == "Ready" then
        self.Animations.Emotes.Ready:Play()
    elseif substate == "Celebration" then
        self.Animations.Emotes.Celebrate:Play()
    elseif substate == "Defeat" then
        self.Animations.Emotes.Defeat:Play()
    elseif substate == "Knockdown" then
        self.Animations.Collisions.Knockdown:Play()
        print("Knock animation length: ", tostring(self.Animations.Collisions.Knockdown.Length))
        task.wait(self.Animations.Collisions.Knockdown.Length - 0.3)
        KnockedEvent:FireServer("Knockdown")
    elseif substate == "Knockout" then
        self.Animations.Collisions.Knockout:Play()
        print("Knock animation length: ", tostring(self.Animations.Collisions.Knockout.Length))
        task.wait(self.Animations.Collisions.Knockout.Length - 0.45)
        KnockedEvent:FireServer("Knockout")
    elseif substate == "Disabled" then
        
        if self.previousState ~= "Default" then
            self.Animations.Walk:Play()
        end

    end

end

function States:Idle()
    self.Animations.Block:Stop()
    self.Animations.Walk:Play()

    if self.Character.Humanoid.WalkSpeed ~= self.Attributes.maxSpeed then
        self.Character.Humanoid.WalkSpeed = self.Attributes.maxSpeed
    end

    if self.previousState == "Default" then
        self.VitalsUi.Enabled = true
        self.TimeUi.Enabled = true
        self:Reset()
    elseif self.previousState == "Block" then
        Interface.BlockStaminaFrameTransition(self.VitalsUi.Stamina.Block, false)
    end

end

function States:Attack(substate)
    self.Animations.Walk:Stop()
    Functions.Attack(substate, self)
    if self:GetState() == "Attack" then
        self:Transition("Idle")
    end
end

function States:Block()
    StopTracks(self.Animations)
    self.Animations.Block:Play()
    self.Character.Humanoid.WalkSpeed = self.Character.Humanoid.WalkSpeed / 2
    Interface.BlockStaminaFrameTransition(self.VitalsUi.Stamina.Block, true)
end

function States:Knockback(substate)
    StopTracks(self.Animations)
    local knockbackTrack = self.Animations.Collisions.Punches[substate]
    knockbackTrack:Play()

    task.delay((knockbackTrack.Length / 2), function() -- Add a knockback recovery time Attribute in each Fighter
        
        if self:GetState() == "Knockback" then
            self:Transition("Idle")
        end

    end)
    
end

return States