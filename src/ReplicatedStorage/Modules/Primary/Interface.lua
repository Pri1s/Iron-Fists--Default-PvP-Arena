local TweenService = game:GetService("TweenService")

local Interface = {}

Interface.BlockTweenInfo = {
	
	Stamina = TweenInfo.new(
		0.25,
		Enum.EasingStyle.Quad,
		Enum.EasingDirection.InOut
	),
	
	Border = TweenInfo.new(
		0.5,
		Enum.EasingStyle.Quad,
		Enum.EasingDirection.InOut
	)
	
}

function Interface.DisableUi(PlayerGui, Amount)
	if Amount == "All" then
		
		for _, screenGui in ipairs(PlayerGui:GetChildren()) do
			if not screenGui:IsA("ScreenGui") then continue end
			screenGui.Enabled = false
		end

	end

end

function Interface.InitializeHealthVitals(VitalsUi, fighter1, fighter2) -- Player's Fighter, Opponent's Fighter
	local playerVitals = VitalsUi.Health.Player
	local opponentVitals = VitalsUi.Health.Opponent
	playerVitals.Visible = true
	opponentVitals.Visible = true
	playerVitals.FighterViewportOutline.Fighters[fighter1].Visible = true
	opponentVitals.FighterViewportOutline.Fighters[fighter2].Visible = true
end

function Interface.UpdateHealthVitals(VitalsUi, Humanoid, playerType, Attribute, Length)
	local Bar = nil
	local barSize = nil

	if playerType == "Player" then
		Bar = VitalsUi.Health.Opponent[Attribute].Bar
	else
		Bar = VitalsUi.Health.Player[Attribute].Bar
	end

	if Attribute == "HeadVigor" then
		barSize = UDim2.new(Length, 0, 1, 0)
	else
		barSize = UDim2.new(Length, 0, 1, 0)
	end
	
	if Length <= 0 then
		barSize = UDim2.new(0, 0, 1, 0)
	end
	
	Bar:TweenSize(barSize, Enum.EasingDirection.In, Enum.EasingStyle.Linear, 0.1)
end

function Interface.BlockStaminaFrameTransition(blockStaminaFrame, Visible)
	
	if Visible then
		TweenService:Create(blockStaminaFrame, Interface.BlockTweenInfo.Stamina, {BackgroundTransparency = blockStaminaFrame:GetAttribute("VisibleTransparency")}):Play()

		for _, v in ipairs(blockStaminaFrame:GetDescendants()) do

			if v:IsA("Frame") then
				TweenService:Create(v, Interface.BlockTweenInfo.Stamina, {BackgroundTransparency = v:GetAttribute("VisibleBackgroundTransparency")}):Play()
			elseif v:IsA("TextLabel") then
				TweenService:Create(v, Interface.BlockTweenInfo.Stamina, {BackgroundTransparency = v:GetAttribute("VisibleBackgroundTransparency")}):Play()
				TweenService:Create(v, Interface.BlockTweenInfo.Stamina, {TextTransparency = v:GetAttribute("VisibleTextTransparency")}):Play()
			elseif v:IsA("UIStroke") then
				TweenService:Create(v, Interface.BlockTweenInfo.Border, {Transparency = 0}):Play()
			end

		end

	else
		TweenService:Create(blockStaminaFrame, Interface.BlockTweenInfo.Stamina, {BackgroundTransparency = 1}):Play()

		for _, v in ipairs(blockStaminaFrame:GetDescendants()) do

			if v:IsA("Frame") then
				TweenService:Create(v, Interface.BlockTweenInfo.Stamina, {BackgroundTransparency = 1}):Play()
			elseif v:IsA("TextLabel") then
				TweenService:Create(v, Interface.BlockTweenInfo.Stamina, {BackgroundTransparency = 1}):Play()
				TweenService:Create(v, Interface.BlockTweenInfo.Stamina, {TextTransparency = 1}):Play()
			elseif v:IsA("UIStroke") then
				TweenService:Create(v, Interface.BlockTweenInfo.Border, {Transparency = 1}):Play()
			end

		end

	end
	
end

return Interface