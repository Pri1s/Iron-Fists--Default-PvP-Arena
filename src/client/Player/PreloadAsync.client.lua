local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContentProvider = game:GetService("ContentProvider")

local PreloadAsync = ReplicatedStorage.Remotes.Setup.PreloadAsync

local assetsToLoad = {}

for _, Object in ipairs(workspace:GetDescendants()) do
  table.insert(assetsToLoad, Object)
end

for _, Asset in ipairs(assetsToLoad) do
	ContentProvider:PreloadAsync({Asset})
end

print("Assets loaded!")
PreloadAsync:FireServer()