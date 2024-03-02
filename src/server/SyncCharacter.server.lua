local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CharacterEvent = ReplicatedStorage.Remotes.TeleportAsync.Character

for _, Character in ipairs(ReplicatedStorage.Characters:GetChildren()) do
	ReplicatedStorage.Shared.FighterScripts:Clone().Parent = Character
	ReplicatedStorage.CharacterObjects.Sounds:Clone().Parent = Character.HumanoidRootPart
end

CharacterEvent.OnServerEvent:Connect(function(Player, characterName)
	repeat task.wait() until ReplicatedStorage.Characters[characterName]:FindFirstChild("FighterScripts")
	
	local Character = Player.Character
	local selectedCharacter = ReplicatedStorage.Characters[characterName]:Clone()
	local HumanoidRootPart = Character.HumanoidRootPart
	local selectedCharacterHRP = selectedCharacter.HumanoidRootPart
	
	selectedCharacter.PrimaryPart = selectedCharacter.HumanoidRootPart
	selectedCharacter:SetPrimaryPartCFrame(Character.PrimaryPart.CFrame)
	selectedCharacter.Name = Player.Name

	if Character.Animate and not selectedCharacter.Animate then
		Character.Animate:Clone().Parent = selectedCharacter
	end

	if Character:FindFirstChild("Health") and not selectedCharacter:FindFirstChild("Health") then
		Character.Health:Clone().Parent = selectedCharacter
	end
	
	Player.Character = selectedCharacter
	
	if HumanoidRootPart and selectedCharacterHRP then
		selectedCharacterHRP.CFrame = HumanoidRootPart.CFrame
	end

	selectedCharacter.Parent = workspace
end)