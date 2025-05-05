local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Lemon",
    SubTitle = "by notCitruss",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true, -- The blur may be detectable, setting this to false disables blur entirely
    Theme = "Lemon",
    MinimizeKey = Enum.KeyCode.LeftControl -- Used when theres no MinimizeKeybind
})

--Fluent provides Lucide Icons https://lucide.dev/icons/ for the tabs, icons are optional
local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

do
    Fluent:Notify({
        Title = "Join Our Discord",
        Content = "https://discord.gg/u3DdQZSUg5",
        SubContent = "", -- Optional
        Duration = 5 -- Set to nil to make the notification not disappear
    })



    Tabs.Main:AddParagraph({
        Title = "Support Future Projects",
        Content = "Join the discord!!!"
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

local Toggle = Tabs.Main:AddToggle("MyToggle", { Title = "Esp", Default = false })

Toggle:OnChanged(function(Value)
    if Value then
        -- Enable ESP
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

    local Toggle = Tabs.Main:AddToggle("MyToggle", { Title = "Infinite Jump", Default = false })

    Toggle:OnChanged(function(Value)
        MyToggleVariable = Value
    end)
    
    local gameService = game:GetService("UserInputService")
    local players = game:GetService("Players")
    local enum = Enum

    gameService.InputBegan:Connect(function(input, gameProcessed)
        if MyToggleVariable and not gameProcessed and input.KeyCode == enum.KeyCode.Space then
            local player = players.LocalPlayer
            if not player then
                warn("LocalPlayer is not available. Ensure this script is running as a LocalScript.")
                return
            end
    
            local character = player.Character or player.CharacterAdded:Wait()
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:ChangeState(enum.HumanoidStateType.Jumping)
            else
                warn("Humanoid not found in character.")
            end
        end
    end)
    
    Options.MyToggle:SetValue(false)
end

-- Addons:
-- SaveManager (Allows you to have a configuration system)
-- InterfaceManager (Allows you to have a interface managment system)

-- Hand the library over to our managers
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

-- Ignore keys that are used by ThemeManager.
-- (we dont want configs to save themes, do we?)
SaveManager:IgnoreThemeSettings()

-- You can add indexes of elements the save manager should ignore
SaveManager:SetIgnoreIndexes({})

-- use case for doing it this way:
-- a script hub could have themes in a global folder
-- and game configs in a separate folder per game
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

-- You can use the SaveManager:LoadAutoloadConfig() to load a config
-- which has been marked to be one that auto loads!
SaveManager:LoadAutoloadConfig()
