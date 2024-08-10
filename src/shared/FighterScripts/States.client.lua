local Players_Service = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Settings = require(ReplicatedStorage.Shared.Modules.Settings)
local States = require(ReplicatedStorage.Shared.Modules.Primary.Combat.States)
local Functions = require(ReplicatedStorage.Shared.Modules.Primary.Combat.Functions)
local Interface = require(ReplicatedStorage.Shared.Modules.Primary.Interface)

local Remotes = {

    Events = {
        Block = ReplicatedStorage.Remotes.Events.Ring.Combat.Vitals.Block,
        opponentData = ReplicatedStorage.Remotes.Events.Ring.Other.OpponentData
    },

    Functions = {
        State = ReplicatedStorage.Remotes.Functions.State
    }

}

--local GetStateFunc = ReplicatedStorage.Remotes.States.Get
--local TransitionStateEvent = ReplicatedStorage.Remotes.States.Transition
--local DrainBlock = ReplicatedStorage.Remotes.Ring.Combat.Vitals.Stamina["Block/Drain"]
--local OpponentData = ReplicatedStorage.Remotes.Ring.Other["Opponent/Data"]

local Player = Players_Service.LocalPlayer
local PlayerGui = Player.PlayerGui
local VitalsUi = PlayerGui:WaitForChild("Vitals")
local TimeUi = PlayerGui:WaitForChild("Time")

local Character = Player.Character
local Humanoid = Character.Humanoid
local Head = Character.Head
local UpperTorso = Character.UpperTorso

local stateEngine = States.new(Player)

local Cooldowns = { -- Idea: Every player gets a different uppercut cooldown depending on their strengths and weaknesses
    Uppercut = {
        Duration = 1.5,
        previousInputTime = 0 -- Perhaps, I should have this in the States metatable?
    }
}

repeat
    task.wait()
until #Players_Service:GetChildren() >= 2
task.wait(Settings.Delays.initializeMatch)

for _, v in ipairs(Players_Service:GetChildren()) do

    if v:IsA("Player") and v.UserId ~= Player.UserId then
        stateEngine:Initialize(v) -- Passing in the other player (Opponent)
    end

end

UserInputService.MouseIconEnabled = false

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then return end

    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.KeyCode == Enum.KeyCode.ButtonX then
        --local staminaBarXScale = VitalsUi.Stamina.Offensive.Bar.Size.X.Scale
        --local staminaBarXCalculated = staminaBarXScale - ((stateEngine.Attributes.ofStaminaDrain / stateEngine.Attributes.ofStamina) * staminaBarXScale)
        --if staminaBarXCalculated <= 0 then return end -- Checking if the attack will drain more stamina than is currently available
        warn(Humanoid:GetAttribute("OffensiveStamina"))
        if Humanoid:GetAttribute("OffensiveStamina") <= stateEngine.Attributes.ofStaminaDrain then return end

        if stateEngine:GetState() == "Idle" then
            stateEngine:Transition("Attack", "Jab")
        end

    elseif input.UserInputType == Enum.UserInputType.MouseButton2 or input.KeyCode == Enum.KeyCode.ButtonL2 then
        --local staminaBarXScale = VitalsUi.Stamina.Block.BarSlot.Bar.Size.X.Scale
        --local staminaBarXCalculated = staminaBarXScale - ((stateEngine.Attributes.dvStaminaDrain / stateEngine.Attributes.dvStamina) * staminaBarXScale)
        --if staminaBarXCalculated <= 0 then return end -- Checking if the next attack will drain more block stamina than is currently left
        if Humanoid:GetAttribute("DefensiveStamina") <= stateEngine.Attributes.ofStaminaDrain then return end

        if stateEngine:GetState() == "Idle" then
            stateEngine:Transition("Block")
        end

    elseif input.KeyCode == Enum.KeyCode.E or input.KeyCode == Enum.KeyCode.ButtonB then
        --local staminaBarXScale = VitalsUi.Stamina.Offensive.Bar.Size.X.Scale
        --local staminaBarXCalculated = staminaBarXScale - ((stateEngine.Attributes.ofStaminaDrain / stateEngine.Attributes.ofStamina) * staminaBarXScale)
        --if staminaBarXCalculated <= 0 then return end -- Checking if the attack will drain more stamina than is currently available
        --warn(staminaBarXCalculated)
        if Humanoid:GetAttribute("OffensiveStamina") <= stateEngine.Attributes.ofStaminaDrain then return end

        if stateEngine:GetState() == "Idle" then
            stateEngine:Transition("Attack", "Hook")
        end

    elseif input.KeyCode == Enum.KeyCode.F or input.KeyCode == Enum.KeyCode.ButtonY then
        --local staminaBarXScale = VitalsUi.Stamina.Offensive.Bar.Size.X.Scale
        --local staminaBarXCalculated = staminaBarXScale - ((stateEngine.Attributes.ofStaminaDrain / stateEngine.Attributes.ofStamina) * staminaBarXScale)
        --if staminaBarXCalculated <= 0 then return end -- Checking if the attack will drain more stamina than is currently available
        if tick() - Cooldowns.Uppercut.previousInputTime < Cooldowns.Uppercut.Duration then return end -- Checking if the player's uppercut cooldown is still active
        --warn(staminaBarXCalculated)
        if Humanoid:GetAttribute("OffensiveStamina") <= stateEngine.Attributes.ofStaminaDrain then return end

        if stateEngine:GetState() == "Idle" and stateEngine:GetTarget() == "Head" then -- Checking if the player is targetting the head
            stateEngine:Transition("Attack", "Uppercut")
            Cooldowns.Uppercut.previousInputTime = tick() -- Resetting the previous uppercut input value to restart the cooldown
        end

    elseif input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.ButtonL1 then
        if stateEngine:GetTarget() == "Head" then return end -- Checking if the player is already targetting the head

        if stateEngine:GetState() == "Idle" then
            warn("Targetting the Head!")
            Functions.EnableIKControl(stateEngine, true) -- Making the IK point to the Opponent's head
        end

    end

end)

UserInputService.InputEnded:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then return end

    if input.UserInputType == Enum.UserInputType.MouseButton2 or input.KeyCode == Enum.KeyCode.ButtonL2 then

        if stateEngine:GetState() == "Block" then
            stateEngine:Transition("Idle") -- Unblocking
        end

    elseif input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.ButtonL1 then
        Functions.EnableIKControl(stateEngine, false) -- Disabling the IK/not making it point to the Opponent's head anymore
    end

end)

Remotes.Functions.State.OnClientInvoke = function(Method, State, subState)

    if Method == "Get" then
        return stateEngine:GetState()
    elseif Method == "Update" then
        stateEngine:Transition(State, subState)
        return true
    end

end

Remotes.Events.Block.OnClientEvent:Connect(function()

    local blockBroken = Functions.DrainBlock(stateEngine) -- Returns true if block stamina bar is empty

    if blockBroken then
        stateEngine:Transition("Idle")
    end

end)