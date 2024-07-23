local Player_Service = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportData = ReplicatedStorage.Remotes.Setup.TeleportData

for _, Character in ipairs(ReplicatedStorage.Characters:GetChildren()) do
    local fighterBoolean = Instance.new("BoolValue", Character)
    fighterBoolean.Name = "Fighter"
    fighterBoolean.Value = true

    local fighterScripts = ReplicatedStorage.Shared.FighterScripts:Clone()
    fighterScripts.Parent = Character

    local userServerSounds = ReplicatedStorage.Sounds.User.Server:Clone()
    userServerSounds.Name = "Sounds"
    userServerSounds.Parent = Character.HumanoidRootPart
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

TeleportData.OnServerEvent:Connect(function(Player, playerData)
    local characterName = playerData.characterString
    repeat
        task.wait()
    until ReplicatedStorage.Characters[characterName]:FindFirstChild("FighterScripts")

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