--[[
local Players_Service = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local ContextProvider = game:GetService("ContentProvider")
local TeleportService = game:GetService("TeleportService")

local Player = Players_Service.LocalPlayer
local PlayerGui = Player.PlayerGui
local teleportData = TeleportService:GetLocalPlayerTeleportData()

local Settings = require(ReplicatedStorage.Shared.Modules.Settings)
local IntroEvent = ReplicatedStorage.Remotes.Ring.Primary.Intro

local TaleOfTapeUi = PlayerGui:WaitForChild("TaleOfTape")
local mainFrame = TaleOfTapeUi.Main
local characterOneViewport = mainFrame.Fighters[teleportData.player1.characterString]--:Clone()
local characterTwoViewport = mainFrame.Fighters[teleportData.player2.characterString]--:Clone()
local taleOfTapeTransitionTweenInfo = TweenInfo.new(
	0.25,
	Enum.EasingStyle.Quad,
	Enum.EasingDirection.InOut
)

local assetsToLoad = {}

local function PositionCharacterViewports()
	characterOneViewport.Visible = true
	characterTwoViewport.Visible = true
	characterOneViewport.Position = UDim2.new(0, 0, 0, 0)
	characterTwoViewport.Position = UDim2.new(1, 0, 0, 0)
	characterTwoViewport.AnchorPoint = Vector2.new(1, 0)
end

for _, Object in ipairs(workspace:GetChildren()) do
	table.insert(assetsToLoad, Object)
end

for _, Asset in ipairs(assetsToLoad) do
	ContextProvider:PreloadAsync({Asset})
end

repeat task.wait() until #Players_Service:GetChildren() == 2
task.wait(Settings.Delays.loadToT)
PositionCharacterViewports()
TaleOfTapeUi.Enabled = true
TweenService:Create(mainFrame, taleOfTapeTransitionTweenInfo, {Size = mainFrame:GetAttribute("ExpandSize")}):Play()
print("Enabled ToT!")

IntroEvent.OnClientEvent:Connect(function()
	local collapseTween = TweenService:Create(mainFrame, taleOfTapeTransitionTweenInfo, {Size = UDim2.new(0, 0, 0 ,0)})
	collapseTween:Play()
	collapseTween.Completed:Wait()
	TaleOfTapeUi.Enabled = false
	print("Collapsed ToT!")
end)
]]

