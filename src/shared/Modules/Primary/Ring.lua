local Players_Service = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local Debris = game:GetService("Debris")

local Settings = require(ReplicatedStorage.Shared.Modules.Settings)
local FighterAttributes = require(ReplicatedStorage.Shared.Modules.FighterAttributes)

local GetStateFunc = ReplicatedStorage.Remotes.States.Get
local TransitionStateEvent = ReplicatedStorage.Remotes.States.Transition

local InitializeViewports = ReplicatedStorage.Remotes.Ring.Combat.Vitals.Health.Initialize
local IntroEvent = ReplicatedStorage.Remotes.Ring.Primary.Intro
local CompletionEvent = ReplicatedStorage.Remotes.Ring.Primary.Completion

local InterfaceEnabled  = ReplicatedStorage.Remotes.Other["Interface/Enabled"]
local TransitionEvent = ReplicatedStorage.Remotes.Other.Transition
local ControlsEnabled = ReplicatedStorage.Remotes.Ring.Other["Controls/Enabled"]
local ToggleCamera = ReplicatedStorage.Remotes.Ring.Other.ToggleCamera
local CountEvent = ReplicatedStorage.Remotes.Ring.Other.Count

local Ring = {}
Ring.__index = Ring

function Ring.new()
	local self = setmetatable({}, Ring)
	
	self.playerData = {
		
		player1 = {
			Player = "N/A",
			Fighter = "N/A",
			Wins = 0
		},
		
		player2 = {
			Player = "N/A",
			Fighter = "N/A",
			Wins = 0
		}
		
	}
	
	self.Time = {
		Minutes = Settings.Times.Round.Minutes,
		Seconds = Settings.Times.Round.Seconds
	}
	
	self.Status = "Inactive"
	self.Round = 0
	
	return self
end

function Ring:Count()
	local Minutes = self.Time.Minutes
	local Seconds = self.Time.Seconds
	local totalSeconds = (Minutes * 60) + Seconds
	local timeCutShort = false
	
	while totalSeconds > 0 do
		local player1State = GetStateFunc:InvokeClient(self.playerData.player1.Player)
		local player2State = GetStateFunc:InvokeClient(self.playerData.player2.Player)
		
		if self.Status == "Round/Complete" or player1State == "Default" or player2State == "Default" then
			timeCutShort = true
			break
		end
		
		local timeString = string.format("%02d:%02d", math.floor(totalSeconds / 60), totalSeconds % 60)
		print(timeString)
		CountEvent:FireAllClients(timeString)
		task.wait(1)
		totalSeconds = totalSeconds - 1
	end
	
	CountEvent:FireAllClients("0:00")
	
	if not timeCutShort then
		
		for _, Data in pairs(self.playerData) do
			local Player = Data.Player
			local Humanoid = Player.Character.Humanoid
			local Attributes = FighterAttributes[Humanoid:GetAttribute("Fighter")]
			
			ControlsEnabled:FireClient(Player, "Disable")
			TransitionStateEvent:FireClient(Player, "Default", nil)
			Humanoid:SetAttribute("HeadVigor", Attributes.headVigor)
			Humanoid:SetAttribute("BodyVigor", Attributes.bodyVigor)
		end
		
		task.wait(Settings.Delays.Default)
		self:CompleteRound(nil, nil, "Time")
	end
	
end

function Ring:Initialize(playerData)
	local player1 = self.playerData.player1
	local player2 = self.playerData.player2
	
	for _, Data in ipairs(playerData) do
		
		if Data.playerOrder == "Player1" then
			player1.Player = Players_Service:FindFirstChild(Data.playerName)
			player1.Fighter = Data.characterString
		else
			player2.Player = Players_Service:FindFirstChild(Data.playerName)
			player2.Fighter = Data.characterString
		end
		
	end
	
	local character1 = player1.Player.Character
	local character2 = player2.Player.Character

	repeat task.wait() until character1:FindFirstChild("HumanoidRootPart") and character2:FindFirstChild("HumanoidRootPart")
	self:Spawn()
end

function Ring:Spawn()
	local character1 = self.playerData.player1.Player.Character
	local character2 = self.playerData.player2.Player.Character
	local character1Root = character1.HumanoidRootPart
	local character2Root = character2.HumanoidRootPart
	local spawn1 = workspace.Ring.Spawns.Round.Player1
	local spawn2 = workspace.Ring.Spawns.Round.Player2
	ControlsEnabled:FireAllClients("Disable")
	print("Positioning...")
	print(GetStateFunc:InvokeClient(self.playerData.player1.Player))
	character1Root.CFrame = CFrame.lookAt(spawn1.Position, workspace.CameraAngles.Center.Position)
	character2Root.CFrame = CFrame.lookAt(spawn2.Position, workspace.CameraAngles.Center.Position)
	print("Positioned!")
	task.wait(3)
	self:Intro()
end

function Ring:Intro()
	print("Ring:Intro()")
	IntroEvent:FireClient(self.playerData.player1.Player, "Player1")
	IntroEvent:FireClient(self.playerData.player2.Player, "Player2")
	print("IntroEvent:FireAllClients()")
	TransitionStateEvent:FireAllClients("Default", "Ready")
	task.wait(Settings.Delays.introTime)
	self:InitializeRound()
end

function Ring:InitializeRound()
	self.Status = "Round/Initialize"
	self.Round = self.Round + 1
	InitializeViewports:FireClient(self.playerData.player1.Player, self.playerData.player1.Fighter, self.playerData.player2.Fighter)
	InitializeViewports:FireClient(self.playerData.player2.Player, self.playerData.player2.Fighter, self.playerData.player1.Fighter)
	ToggleCamera:FireAllClients(true, "Main")
	ControlsEnabled:FireAllClients("Enable")
	TransitionStateEvent:FireAllClients("Idle", nil)
	
	task.wait(Settings.Delays.Default)
	
	task.spawn(function()
		self:Count()
	end)
	
end

function Ring:CompleteRound(Victor, Opponent, victoryType)
	
	local function LeastVigor()
		local lowestNetVigor = 1 -- Expressed as a percentage
		local victorByVigor = nil
		
		for _, Data in pairs(self.playerData) do
			local Humanoid = Data.Player.Character.Humanoid
			local Attributes = FighterAttributes[Humanoid:GetAttribute("Fighter")]
			local headVigor = Humanoid:GetAttribute("HeadVigor")
			local bodyVigor = Humanoid:GetAttribute("BodyVigor")
			local netVigor = headVigor + bodyVigor
			local maxVigor = Attributes.headVigor + Attributes.bodyVigor
			
			if netVigor / maxVigor > lowestNetVigor then
				lowestNetVigor = netVigor 
				victorByVigor = Data.Player
			end
			
		end
		
		if victorByVigor then
			
			for _, Data in pairs(self.playerData) do

				if Data.Player == victorByVigor then
					Data.Wins = Data.Wins + 1
				end

			end
			
		end
		
	end
	
	self.Status = "Round/Complete"
	print("Ring status changed!")
	
	if victoryType ~= "Time" then
		if not Victor then return end
		
		for _, Data in pairs(self.playerData) do

			if Data.Player == Victor then
				Data.Wins = Data.Wins + 1
			end

		end
		
	else
		LeastVigor()
	end
	
	if self.Round < Settings.Rounds and victoryType ~= "Knockout" then
		TransitionEvent:FireAllClients()
		task.wait(Settings.Delays.Transition)
		self:Spawn()
	elseif self.Round >= Settings.Rounds and victoryType ~= "Knockout" then
		TransitionEvent:FireAllClients()
		task.wait(Settings.Delays.Transition - 0.4)
		self:Complete(nil)
	elseif victoryType == "Knockout" then
		TransitionEvent:FireAllClients()
		task.wait(Settings.Delays.Transition - 0.4)
		self:Complete(Victor, Opponent)
	end
	
end

function Ring:Complete(victorByKnockout, loserByKnockout)
	local player1 = self.playerData.player1
	local player2 = self.playerData.player2
	local Victor = nil
	local Opponent = nil
	
	if victorByKnockout then
		Victor = victorByKnockout
		Opponent = loserByKnockout
	else
		
		if player1.Wins > player2.Wins then
			Victor = player1.Player
			Opponent = player2.Player
		else
			Victor = player2.Player
			Opponent = player1.Player
		end
		
	end
	
	Victor.Character.HumanoidRootPart.CFrame = workspace.Ring.Spawns.Completion.Victor.CFrame
	Opponent.Character.HumanoidRootPart.CFrame = workspace.Ring.Spawns.Completion.Opponent.CFrame
	InterfaceEnabled:FireAllClients(false, "Transition")
	TransitionStateEvent:FireClient(Victor, "Default", "Celebration")
	TransitionEvent:FireClient(Opponent, "Default", "Defeat")
	task.wait(Settings.Delays.Transition - 0.4)
	CompletionEvent:FireAllClients()
	--TeleportService:TeleportAsync(Settings.homeId, {Victor, Opponent}, nil)
end


return Ring