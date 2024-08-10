local Players_Service = game:GetService("Players")
local ProfileService = require(script.Parent.Parent.ProfileService)

local playerProfile = {
	["Fists"] = 0,
	["Fighters"] = {"Paul"}
}

local profileStore = ProfileService.GetProfileStore("PlayerProfile(1)", playerProfile)
local Profiles = {}

local function PlayerAdded(Player: Player)
    local Profile = profileStore:LoadProfileAsync("Player_".. Player.UserId)

    if Profile then
        Profile:AddUserId(Player.UserId)
        Profile:Reconcile()

        Profile:ListenToRelease(function()
            Profiles[Player] = nil
            Player:Kick()
        end)

        if Player:IsDescendantOf(Players_Service) then
            Profiles[Player] = Profile
            print(Profiles[Player])
        else
            Profile:Release()
        end
    else
        warn("Failed to load profile for player: " .. Player.Name)
        Player:Kick()
    end
end

local function PlayerRemoving(Player: Player)
    if Profiles[Player] then
        Profiles[Player]:Release()
    end
end

local function GetProfile(Player: Player)
    assert(Profiles[Player], string.format("Profile does not exist for %s", Player.UserId))
    return Profiles[Player]
end

local ProfileManager = {}

function ProfileManager:Init()
    for _, Player in ipairs(Players_Service:GetPlayers()) do
        task.spawn(function()
            PlayerAdded(Player)
        end)
    end

    Players_Service.PlayerAdded:Connect(PlayerAdded)
    Players_Service.PlayerRemoving:Connect(PlayerRemoving)
end

function ProfileManager:Get(Player: Player, Key)
    local Profile = GetProfile(Player)
    assert(Profile.Data[Key] ~= nil, string.format("Data does not exist for key: %s", Key))
    return Profile.Data[Key]
end

function ProfileManager:Set(Player: Player, Key, Value)
    local Profile = GetProfile(Player)
    assert(Profile.Data[Key] ~= nil, string.format("Data does not exist for key: %s", Key))
    assert(type(Profile.Data[Key]) == type(Value), string.format("Type mismatch for key: %s. Expected %s, got %s", Key, type(Profile.Data[Key]), type(Value)))
    Profile.Data[Key] = Value
end

function ProfileManager:Update(Player: Player, Key, Callback)
    local Profile = GetProfile(Player)

    local oldData = self:Get(Player, Key)
    local newData = Callback(oldData)

    self:Set(Player, Key, newData)
end

return ProfileManager
