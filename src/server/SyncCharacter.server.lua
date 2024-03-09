local Player_Service = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CharacterData = ReplicatedStorage.Remotes.Setup.Data.Character

for _, Character in ipairs(ReplicatedStorage.Characters:GetChildren()) do
	ReplicatedStorage.Shared.FighterScripts:Clone().Parent = Character
	ReplicatedStorage.CharacterObjects.Sounds:Clone().Parent = Character.HumanoidRootPart
end

Player_Service.PlayerAdded:Connect(function(Player)
	
	Player.CharacterAdded:Connect(function(Character)
		local IKControl = Instance.new("IKControl", Character.Humanoid)
		warn("instanced IKControl for ", Player.Name)
		IKControl.Type = Enum.IKControlType.LookAt
		IKControl.EndEffector = Character.Head
		IKControl.ChainRoot = Character.UpperTorso
		IKControl.Weight = 1
		IKControl.SmoothTime = 0.1
	end)

end)

CharacterData.OnServerEvent:Connect(function(Player, characterName)
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