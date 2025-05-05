local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Lemon",
    SubTitle = "by notCitruss",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Lemon",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local FlySpeed = 50 -- Default fly speed
local flying = false
local ctrl = { f = 0, b = 0, l = 0, r = 0 }
local speed = 0
local bg, bv = nil, nil

-- Notify
Fluent:Notify({
    Title = "Join Our Discord",
    Content = "https://discord.gg/u3DdQZSUg5",
    Duration = 5
})

Tabs.Main:AddButton({
    Title = "Copy Discord Link",
    Description = "Copies the Discord Link",
    Callback = function()
        Window:Dialog({
            Title = "Are you sure?",
            Content = "Will copy Discord Link to your clipboard",
            Buttons = {
                {
                    Title = "Copy",
                    Callback = setclipboard("https://discord.gg/u3DdQZSUg5")
                },
                {
                    Title = "Cancel",
                    Callback = function()
                        print("Cancelled")
                    end
                }
            }
        })
    end
})

-- Add Fly Speed Slider
local SpeedSlider = Tabs.Main:AddSlider("FlySpeedSlider", {
    Title = "Fly Speed",
    Description = "Adjust the fly speed",
    Default = 50,
    Min = 0,
    Max = 300,
    Rounding = 0,
    Callback = function(Value)
        FlySpeed = Value
        print("Fly speed set to:", FlySpeed)
    end
})

-- Add Fly Toggle
local FlyToggle = Tabs.Main:AddToggle("FlyToggle", { Title = "Fly", Default = false })

-- Add Fly Keybind
local FlyKeybind = Tabs.Main:AddKeybind("FlyKeybind", {
    Title = "Fly Keybind",
    Mode = "Toggle",
    Default = "E",
    Callback = function(Value)
        FlyToggle:SetValue(Value) -- Sync the keybind with the toggle
    end
})

-- Fly Functionality
local function StartFly()
    local plr = game.Players.LocalPlayer
    local character = plr.Character or plr.CharacterAdded:Wait()
    local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
    if not torso then
        warn("Torso or UpperTorso not found!")
        return
    end

    bg = Instance.new("BodyGyro", torso)
    bg.P = 9e4
    bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
    bg.cframe = torso.CFrame
    bv = Instance.new("BodyVelocity", torso)
    bv.velocity = Vector3.new(0, 0.1, 0)
    bv.maxForce = Vector3.new(9e9, 9e9, 9e9)

    flying = true
    game.StarterGui:SetCore("SendNotification", { Title = "Fly Activated", Text = "Flying Enabled", Duration = 1 })

    while flying do
        wait()
        character.Humanoid.PlatformStand = true
        if ctrl.f + ctrl.b ~= 0 or ctrl.l + ctrl.r ~= 0 then
            speed = math.min(speed + 0.5 + (speed / FlySpeed), FlySpeed)
        else
            speed = math.max(speed - 1, 0)
        end
        bv.velocity = ((game.Workspace.CurrentCamera.CFrame.LookVector * (ctrl.f + ctrl.b)) +
            ((game.Workspace.CurrentCamera.CFrame * CFrame.new(ctrl.l + ctrl.r, (ctrl.f + ctrl.b) * 0.2, 0).p) -
                game.Workspace.CurrentCamera.CFrame.p)) * speed
        bg.cframe = game.Workspace.CurrentCamera.CFrame
    end
end

local function StopFly()
    flying = false
    if bg then bg:Destroy() end
    if bv then bv:Destroy() end

    local plr = game.Players.LocalPlayer
    local character = plr.Character or plr.CharacterAdded:Wait()
    character.Humanoid.PlatformStand = false

    -- Ensure the player lands on their feet
    character.Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    game.StarterGui:SetCore("SendNotification", { Title = "Fly Deactivated", Text = "Flying Disabled", Duration = 1 })
end

FlyToggle:OnChanged(function(Value)
    if Value then
        StartFly()
    else
        StopFly()
    end
end)

-- Fly Controls
local mouse = game.Players.LocalPlayer:GetMouse()

mouse.KeyDown:Connect(function(key)
    if key:lower() == "w" then
        ctrl.f = 1
    elseif key:lower() == "s" then
        ctrl.b = -1
    elseif key:lower() == "a" then
        ctrl.l = -1
    elseif key:lower() == "d" then
        ctrl.r = 1
    end
end)

mouse.KeyUp:Connect(function(key)
    if key:lower() == "w" then
        ctrl.f = 0
    elseif key:lower() == "s" then
        ctrl.b = 0
    elseif key:lower() == "a" then
        ctrl.l = 0
    elseif key:lower() == "d" then
        ctrl.r = 0
    end
end)

-- Infinite Jump Toggle
local InfiniteJumpToggle = Tabs.Main:AddToggle("InfiniteJumpToggle", { Title = "Infinite Jump", Default = false })
InfiniteJumpToggle:OnChanged(function(Value)
    _G.InfiniteJumpEnabled = Value
end)

game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
    if _G.InfiniteJumpEnabled and not gameProcessed and input.KeyCode == Enum.KeyCode.Space then
        local player = game.Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- ESP Toggle
local ESPToggle = Tabs.Main:AddToggle("ESPToggle", { Title = "ESP", Default = false })
ESPToggle:OnChanged(function(Value)
    if Value then
        _G.FriendColor = Color3.fromRGB(0, 0, 255)
        _G.EnemyColor = Color3.fromRGB(255, 0, 0)
        _G.UseTeamColor = true

        if not _G.ESPFolder then
            _G.ESPFolder = Instance.new("Folder", game.CoreGui)
            _G.ESPFolder.Name = "ESP"
        end

        local function esp(target, color)
            if target.Character then
                if not target.Character:FindFirstChild("GetReal") then
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "GetReal"
                    highlight.Adornee = target.Character
                    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    highlight.FillColor = color
                    highlight.Parent = target.Character
                else
                    target.Character.GetReal.FillColor = color
                end
            end
        end

        local players = game:GetService("Players")
        local plr = players.LocalPlayer

        _G.ESPConnection = game:GetService("RunService").RenderStepped:Connect(function()
            for _, v in pairs(players:GetPlayers()) do
                if v ~= plr then
                    esp(v, _G.UseTeamColor and v.TeamColor.Color or ((plr.TeamColor == v.TeamColor) and _G.FriendColor or _G.EnemyColor))
                end
            end
        end)
    else
        -- Disable ESP
        if _G.ESPConnection then
            _G.ESPConnection:Disconnect()
            _G.ESPConnection = nil
        end

        if _G.ESPFolder then
            _G.ESPFolder:Destroy()
            _G.ESPFolder = nil
        end

        -- Remove all "GetReal" highlights from characters
        for _, v in pairs(game:GetService("Players"):GetPlayers()) do
            if v.Character and v.Character:FindFirstChild("GetReal") then
                v.Character.GetReal:Destroy()
            end
        end
    end
end)

-- SaveManager and InterfaceManager
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/specific-game")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

Fluent:Notify({
    Title = "Lemon",
    Content = "The script has been loaded.",
    Duration = 8
})

SaveManager:LoadAutoloadConfig()
