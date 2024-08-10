local Players_Service = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local Debris = game:GetService("Debris")

local Settings = require(ReplicatedStorage.Shared.Modules.Settings)
local FighterAttributes = require(ReplicatedStorage.Shared.Modules.FighterAttributes)

local Remotes = {

    Events = {
        Intro = ReplicatedStorage.Remotes.Events.Ring.Primary.Intro,
        Completion = ReplicatedStorage.Remotes.Events.Ring.Primary.Completion,
        Interface = ReplicatedStorage.Remotes.Events.Interface,
        Controls = ReplicatedStorage.Remotes.Events.Setup.Controls,
        Count = ReplicatedStorage.Remotes.Events.Ring.Other.Count,
        Transition = ReplicatedStorage.Remotes.Events.Transition,
        toggleCamera = ReplicatedStorage.Remotes.Events.Ring.Other.ToggleCamera,
        opponentData = ReplicatedStorage.Remotes.Events.Ring.Other.OpponentData,
        initializeViewports = ReplicatedStorage.Remotes.Events.Ring.Other.InitializeViewports
    },

    Functions = {
        State = ReplicatedStorage.Remotes.Functions.State
    },

}

local Bindables = {

    Functions = {
        Data = ReplicatedStorage.Bindables.Functions.Data
    }

}

local Ring = {}
Ring.__index = Ring

function Ring.new()
    local self = setmetatable({}, Ring)

    self.playerData = {

        player1 = {
            Player = "N/A",
            Fighter = "N/A",
            Knockdowns = 0
        },

        player2 = {
            Player = "N/A",
            Fighter = "N/A",
            Knockdowns = 0
        }

    }

    self.Time = {
        Minutes = Settings.Times.Round.Minutes,
        Seconds = Settings.Times.Round.Seconds
    }

    self.Status = "Inactive"
    self.Round = 0

    return self
end

function Ring:Count()
    local Minutes = self.Time.Minutes
    local Seconds = self.Time.Seconds
    local totalSeconds = (Minutes * 60) + Seconds
    local timeCutShort = false

    while totalSeconds > 0 do
        local player1State = Remotes.Functions.State:InvokeClient(self.playerData.player1.Player, "Get")
        local player2State = Remotes.Functions.State:InvokeClient(self.playerData.player2.Player, "Get")

        if self.Status == "Round/Complete" or player1State == "Default" or player2State == "Default" then
            timeCutShort = true
            break
        end

        local timeString = string.format("%02d:%02d", math.floor(totalSeconds / 60), totalSeconds % 60)
        Remotes.Events.Count:FireAllClients(timeString)
        task.wait(1)
        totalSeconds = totalSeconds - 1
    end

    Remotes.Events.Count:FireAllClients("0:00")

    if not timeCutShort then

        for _, Data in pairs(self.playerData) do
            local Player = Data.Player
            local Humanoid = Player.Character.Humanoid
            local Attributes = FighterAttributes[Humanoid:GetAttribute("Fighter")]

            Remotes.Events.Controls:FireClients(Player, "Disable")
            Remotes.Functions.State:InvokeClient(Player, "Update", "Default", nil)
            Humanoid:SetAttribute("HeadVigor", Attributes.headVigor)
            Humanoid:SetAttribute("BodyVigor", Attributes.bodyVigor)
        end

        task.wait(Settings.Delays.Default)
        self:CompleteRound(nil, nil, "Time")
    end

end

function Ring:Initialize(playerData)
    local player1 = self.playerData.player1
    local player2 = self.playerData.player2

    for _, Data in ipairs(playerData) do

        if Data.playerOrder == "Player1" then
            player1.Player = Players_Service:FindFirstChild(Data.playerName)
            player1.Fighter = Data.characterString
        elseif Data.playerOrder == "Player2" then
            player2.Player = Players_Service:FindFirstChild(Data.playerName)
            player2.Fighter = Data.characterString
        end

    end

    Remotes.Events.opponentData:FireClient(self.playerData.player1.Player, self.playerData.player2.Player)
    Remotes.Events.opponentData:FireClient(self.playerData.player2.Player, self.playerData.player1.Player)

    local character1 = player1.Player.Character
    local character2 = player2.Player.Character

    repeat
        task.wait()
    until character1:FindFirstChild("HumanoidRootPart") and character2:FindFirstChild("HumanoidRootPart")
    self:Spawn()
end

function Ring:Spawn()
    local character1 = self.playerData.player1.Player.Character
    local character2 = self.playerData.player2.Player.Character
    local character1Root = character1.HumanoidRootPart
    local character2Root = character2.HumanoidRootPart
    local spawn1 = workspace.Ring.Spawns.Round.Player1
    local spawn2 = workspace.Ring.Spawns.Round.Player2
    Remotes.Events.Controls:FireAllClients("Disable")
    character1Root.CFrame = CFrame.lookAt(spawn1.Position, workspace.CameraAngles.Center.Position)
    character2Root.CFrame = CFrame.lookAt(spawn2.Position, workspace.CameraAngles.Center.Position)
    task.wait(3)
    self:Intro()
end

function Ring:Intro()
    Remotes.Events.Intro:FireClient(self.playerData.player1.Player, "Player1")
    Remotes.Events.Intro:FireClient(self.playerData.player2.Player, "Player2")
    Remotes.Functions.State:InvokeClient(self.playerData.player1.Player, "Update", "Default", "Ready")
    Remotes.Functions.State:InvokeClient(self.playerData.player2.Player, "Update", "Default", "Ready")
    task.wait(Settings.Delays.introTime)
    self:InitializeRound()
end

function Ring:InitializeRound()
    local player1 = self.playerData.player1
    local player2 = self.playerData.player2

    self.Status = "Round/Initialize"
    self.Round = self.Round + 1
    player1.Player.Character.Humanoid.IKControl.Enabled = true
    player2.Player.Character.Humanoid.IKControl.Enabled = true
    Remotes.Events.initializeViewports:FireClient(player1.Player, self.playerData.player1.Fighter, self.playerData.player2.Fighter)
    Remotes.Events.initializeViewports:FireClient(player2.Player, self.playerData.player2.Fighter, self.playerData.player1.Fighter)
    Remotes.Events.toggleCamera:FireAllClients(true, "Round/Static")
    Remotes.Events.Controls:FireAllClients("Enable")
    Remotes.Functions.State:InvokeClient(self.playerData.player1.Player, "Update", "Idle")
    Remotes.Functions.State:InvokeClient(self.playerData.player2.Player, "Update", "Idle")
    workspace.Ring.Sounds.BeginRound:Play()
    task.wait(Settings.Delays.Default)

    task.spawn(function()
        self:Count()
    end)

end

function Ring:CompleteRound(Victor, Opponent, victoryType)

    local function LeastVigor()
        local lowestNetVigor = 1
        local victorByVigor = nil

        for _, Data in pairs(self.playerData) do
            local Humanoid = Data.Player.Character.Humanoid
            local Attributes = FighterAttributes[Humanoid:GetAttribute("Fighter")]
            local headVigor = Humanoid:GetAttribute("HeadVigor")
            local bodyVigor = Humanoid:GetAttribute("BodyVigor")
            local netVigor = headVigor + bodyVigor
            local maxVigor = Attributes.headVigor + Attributes.bodyVigor

            if netVigor / maxVigor > lowestNetVigor then
                lowestNetVigor = netVigor
                victorByVigor = Data.Player
            end

        end

        if victorByVigor then

            for _, Data in pairs(self.playerData) do

                if Data.Player == victorByVigor then
                    Data.Knockdowns = Data.Knockdowns + 1
                end

            end

        end

    end

    local function Complete(victorByKnockout, loserByKnockout)
        Remotes.Events.Transition:FireAllClients()
        task.wait(Settings.Delays.Transition - 0.4)
        self:Complete(victorByKnockout, loserByKnockout)
    end

    self.Status = "Round/Complete"

    if victoryType ~= "Time" then
        if not Victor then
            return
        end

        for _, Data in pairs(self.playerData) do

            if Data.Player == Victor then
                Data.Knockdowns = Data.Knockdowns + 1
            end

        end

    else
        LeastVigor()
    end

    if self.Round < Settings.Rounds and victoryType ~= "Knockout" then

        if self.playerData.player1.Knockdowns >= 3 or self.playerData.player2.Knockdowns >= 3 then
            Complete(nil, nil)
        else
            Remotes.Events.Transition:FireAllClients()
            task.wait(Settings.Delays.Transition)
            self:Spawn()
        end

    elseif self.Round >= Settings.Rounds and victoryType ~= "Knockout" then
        Complete(nil, nil)
    elseif victoryType == "Knockout" then
        Complete(Victor, Opponent)
    end

end

function Ring:Complete(victorByKnockout, loserByKnockout)
    local player1 = self.playerData.player1
    local player2 = self.playerData.player2
    local Victor = nil
    local Opponent = nil

    local function UpdateCredits(Player, Increment)
        -- methodType, profileName, Player, Key, Value
        print("Updating credits for", Player.Name, "Increment:", Increment)
        local success, result = pcall(function()
            return Bindables.Functions.Data:Invoke("Update", "Player", Player, "Fists", function(currentCredits)
                -- Ensure currentCredits is a number
                assert(type(currentCredits) == "number", "Expected currentCredits to be a number")
                
                if currentCredits + Increment < 0 then
                    return currentCredits
                else
                    return currentCredits + Increment
                end
                
            end)
        end)

        if success then
            print("Data updated successfully for", Player.Name)
        else
            warn("Failed to update data for", Player.Name, ":", result)
        end
    end

    if victorByKnockout then
        Victor = victorByKnockout
        Opponent = loserByKnockout
    else
        if player1.Knockdowns > player2.Knockdowns then
            Victor = player1.Player
            Opponent = player2.Player
        else
            Victor = player2.Player
            Opponent = player1.Player
        end
    end

    Remotes.Events.Interface:FireAllClients(false, "Transition")
    Remotes.Functions.State:InvokeClient(Victor, "Update", "Default", "Celebration")
    Remotes.Functions.State:InvokeClient(Opponent, "Update", "Default", "Defeat")

    UpdateCredits(Victor, Settings.Credits.Win)
    UpdateCredits(Opponent, -(Settings.Credits.Lose))

    task.wait(Settings.Delays.Default)
    
    Victor.Character.HumanoidRootPart.CFrame = workspace.Ring.Spawns.Completion.Victor.CFrame
    Opponent.Character.HumanoidRootPart.CFrame = workspace.Ring.Spawns.Completion.Opponent.CFrame

    task.wait(Settings.Delays.Transition - 0.25)

    Remotes.Events.Completion:FireAllClients()
    --TeleportService:TeleportAsync(Settings.homeId, {Victor, Opponent}, nil)
end


return Ring