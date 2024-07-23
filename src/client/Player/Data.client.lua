local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataRemoteFunction = ReplicatedStorage.Remotes.Functions.Data
local DataBindableFunction = ReplicatedStorage.Bindables.Functions.Data

-- Example function to fetch or set player data via RemoteFunction
local function PlayerDataRequest(profileName, methodType, Key, Value)
    print("PlayerDataRequest called with:", profileName, methodType, Key, Value)
	return DataRemoteFunction:InvokeServer(profileName, methodType, Key, Value)
end

-- Retry mechanism to fetch player data until successful with error handling
local function FetchPlayerDataWithRetry(profileName, methodType, Key, Value)
	local result

	repeat
		print("Attempting to fetch player data:", profileName, methodType, Key, Value)
		local success, response = pcall(PlayerDataRequest, profileName, methodType, Key, Value)

		if success then
			result = response
			if result then
				print("Successfully fetched player data:", result)
			else
				print("Received no data in response.")
			end
		else
			warn("Failed to fetch player data: " .. tostring(response))
		end

		if not result then
			print("Retrying in 1 second...")
			task.wait(1)  -- Wait for 1 second before retrying
		end

	until result

	return result
end

-- Methods to get, set, and update data

local function GetPlayerData(profileName, Key)
    print("Getting player data for:", profileName, Key)
	return FetchPlayerDataWithRetry(profileName, "Get", Key)
end

local function SetPlayerData(profileName, Key, Value)
	local success

	repeat
		print("Attempting to set player data:", profileName, Key, Value)
		local success, response = pcall(PlayerDataRequest, profileName, "Set", Key, Value)

		if success then
			success = response
			if success then
				print("Successfully set player data.")
			else
				print("Failed to set player data, response was false.")
			end
		else
			warn("Failed to set player data: " .. tostring(response))
		end

		if not success then
			print("Retrying in 1 second...")
			wait(1)  -- Wait for 1 second before retrying
		end

	until success

end

local function UpdatePlayerData(profileName, Key, callback)
	local success

	repeat
		print("Attempting to update player data for:", profileName, Key)
		-- Fetch the current value first
		local currentValue = GetPlayerData(profileName, Key)

		if currentValue then
			print("Current value fetched:", currentValue)
		else
			print("Failed to fetch current value.")
		end

		-- Use the callback to compute the new value
		local newValue = callback(currentValue)
		print("Computed new value:", newValue)

		local success, response = pcall(PlayerDataRequest, profileName, "Update", Key, newValue)

		if success then
			success = response
			if success then
				print("Successfully updated player data.")
			else
				print("Failed to update player data, response was false.")
			end
		else
			warn("Failed to update player data: " .. tostring(response))
		end

		if not success then
			print("Retrying in 1 second...")
			task.wait(1)  -- Wait for 1 second before retrying
		end

	until success

end

-- Bindable function to handle Get, Set, and Update
DataBindableFunction.OnInvoke = function(methodType, profileName, Key, ValueOrCallback)
	print("DataBindableFunction.OnInvoke called with:", methodType, profileName, Key, ValueOrCallback)

	if methodType == "Get" then
		return GetPlayerData(profileName, Key)
	elseif methodType == "Set" then
		SetPlayerData(profileName, Key, ValueOrCallback)
	elseif methodType == "Update" then
		UpdatePlayerData(profileName, Key, ValueOrCallback)
	else
		error("Unsupported method type: " .. tostring(methodType))
	end
	
end