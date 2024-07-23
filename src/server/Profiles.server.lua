local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local DataRemoteFunction = ReplicatedStorage.Remotes.Functions.Data
local DataBindableFunction = ReplicatedStorage.Bindables.Functions.Data

-- Example: assuming profile managers are modules that handle player data
local profileManagers = {
    Player = require(ServerScriptService.Server.Modules.Data.Managers.Player)
}

-- Initialize each profile manager
for _, Profile in pairs(profileManagers) do
    Profile:Init()
end

-- Methods to get, set, and update data
local function GetPlayerData(profileName, Player, Key)
    return profileManagers[profileName]:Get(Player, Key)
end

local function SetPlayerData(profileName, Player, Key, Value)
    profileManagers[profileName]:Set(Player, Key, Value)
    return true
end

local function UpdatePlayerData(profileName, Player, Key, Value)
    profileManagers[profileName]:Update(Player, Key, Value)
    return true
end

-- Bindable function to handle Get, Set, and Update
DataBindableFunction.OnInvoke = function(methodType, profileName, Player, Key, ValueOrCallback)
    if methodType == "Get" then
        return GetPlayerData(profileName, Player, Key)
    elseif methodType == "Set" then
        return SetPlayerData(profileName, Player, Key, ValueOrCallback)
    elseif methodType == "Update" then
        return UpdatePlayerData(profileName, Player, Key, ValueOrCallback)
    else
        error("Unsupported method type: " .. tostring(methodType))
    end
end

-- Handle client requests via RemoteFunction OnServerInvoke
DataRemoteFunction.OnServerInvoke = function(Player, profileName, methodType, Key, Value)
    return DataBindableFunction:Invoke(methodType, profileName, Player, Key, Value)
end