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

Interface.TransitionTweenInfo = {

	In = TweenInfo.new(
		0.5,
		Enum.EasingStyle.Quad,
		Enum.EasingDirection.InOut
	),

	Out = TweenInfo.new(
		0.1,
		Enum.EasingStyle.Quad,
		Enum.EasingDirection.InOut
	)

}

Interface.TransitionGoals = {
	Default = UDim2.new(-1, 0, 0, 0),
	In = {Position = UDim2.new(0, 0, 0, 0)},
	Out = {Position = UDim2.new(1, 0, 0, 0)}
}

function Interface.DisableUi(PlayerGui, Enabled, Exceptions)

	if not Enabled then
		
		for _, screenGui in ipairs(PlayerGui:GetChildren()) do
			if not screenGui:IsA("ScreenGui") then continue end 
			if screenGui.Name == Exceptions then continue end
			screenGui.Enabled = false
		end

	end

end

function Interface.Transition(TransitionUi)
	local bInTween = TweenService:Create(TransitionUi.Black, Interface.TransitionTweenInfo.In, Interface.TransitionGoals.In)
	local bOutTween = TweenService:Create(TransitionUi.Black, Interface.TransitionTweenInfo.Out, Interface.TransitionGoals.Out)
	local iconInTween = TweenService:Create(TransitionUi.Icon, Interface.TransitionTweenInfo.In, Interface.TransitionGoals.In)
	local iconOutTween = TweenService:Create(TransitionUi.Icon, Interface.TransitionTweenInfo.Out, Interface.TransitionGoals.Out)

	TransitionUi.Enabled = true
	bInTween:Play()
	bInTween.Completed:Wait()
	iconInTween:Play()
	iconInTween.Completed:Wait()
	task.wait(1)
	iconOutTween:Play()
	iconOutTween.Completed:Wait()
	bOutTween:Play()
	bOutTween.Completed:Wait()
	TransitionUi.Black.Position = Interface.TransitionGoals.Default
	TransitionUi.Icon.Position = Interface.TransitionGoals.Default
	TransitionUi.Enabled = false
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