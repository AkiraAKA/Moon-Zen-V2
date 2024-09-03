-- Moon Zen V2
-- Discord: meowbucks
-- Script created by: meowbucks

local library = loadstring(game:HttpGet('https://raw.githubusercontent.com/jakepscripts/moonlib/main/moonlibv1.lua'))()

-- Notify the user that the script has loaded
pcall(function()
    game.StarterGui:SetCore("SendNotification", {
        Title = "MOON-ZEN V2 HAS LOADED!",
        Text = "Discord - meowbucks",
        Duration = 5;
    })
end)

-- Settings
local settings = {
    RainbowFov = true,
    AimbotKeybind = Enum.KeyCode.E,
    KillAllZombiesKeybind = Enum.KeyCode.R,
    HvHMode = true,
    HvHMessage = "MOON-ZEN V2 ON TOP MADE BY MEOWBUCKS",
    ESPEnabled = true,
    TracersEnabled = true,
    BoxESPEnabled = true,
    NameESPEnabled = true,
    RainbowESP = true,
    AntiChatLogging = true,
    SmoothExecution = true,
    FOVCircleRadius = 100,
    FOVCircleThickness = 2
}

-- Anti-Chat Logging
if settings.AntiChatLogging then
    local mt = getrawmetatable(game)
    setreadonly(mt, false)
    local oldIndex = mt.__index
    mt.__index = newcclosure(function(self, key)
        if tostring(self) == "Chat" and key == "Log" then
            return nil
        end
        return oldIndex(self, key)
    end)
    setreadonly(mt, true)
end

-- Function to create a rainbow color effect
local function createRainbowEffect()
    local counter = 0
    return function()
        counter = counter + 0.01
        return Color3.fromHSV(counter % 1, 1, 1)
    end
end

local rainbowEffect = createRainbowEffect()

-- Function to create and update the rainbow FOV circle
local function createAndUpdateFOVCircle()
    local fovCircle = Drawing.new("Circle")
    fovCircle.Thickness = settings.FOVCircleThickness
    fovCircle.Radius = settings.FOVCircleRadius
    fovCircle.Filled = false
    fovCircle.Transparency = 1
    fovCircle.Position = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y / 2)
    
    spawn(function()
        while settings.RainbowFov do
            fovCircle.Color = rainbowEffect()
            fovCircle.Position = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y / 2)
            wait(0.01)
        end
        fovCircle:Remove() -- Clean up when no longer needed
    end)
end

-- Function to handle aimbot
local function aimbot()
    xpcall(function()
        local player = game.Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        local head = character:FindFirstChild("Head")

        local nearestZombie = nil
        local nearestDistance = math.huge

        for _, zombie in ipairs(workspace.Zombies:GetChildren()) do
            if zombie:IsA("Model") and zombie:FindFirstChild("Head") then
                local distance = (head.Position - zombie.Head.Position).magnitude
                if distance < nearestDistance then
                    nearestDistance = distance
                    nearestZombie = zombie
                end
            end
        end

        if nearestZombie then
            game:GetService("TweenService"):Create(
                character:FindFirstChildOfClass("Humanoid").RootPart,
                TweenInfo.new(0.1, Enum.EasingStyle.Linear),
                {CFrame = CFrame.new(head.Position, nearestZombie.Head.Position)}
            ):Play()
        end
    end, function(err)
        warn("Error in aimbot function: " .. tostring(err))
    end)
end

-- Function to kill all zombies
local function killAllZombies()
    xpcall(function()
        for _, zombie in ipairs(workspace.Zombies:GetChildren()) do
            if zombie:IsA("Model") and zombie:FindFirstChild("Humanoid") then
                zombie.Humanoid:TakeDamage(zombie.Humanoid.Health)
            end
        end
    end, function(err)
        warn("Error in killAllZombies function: " .. tostring(err))
    end)
end

-- Function to bring all zombies to the player
local function bringZombiesToPlayer()
    xpcall(function()
        local player = game.Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        local rootPart = character:WaitForChild("HumanoidRootPart")

        for _, zombie in ipairs(workspace.Zombies:GetChildren()) do
            if zombie:IsA("Model") and zombie:FindFirstChild("HumanoidRootPart") then
                zombie.HumanoidRootPart.CFrame = rootPart.CFrame
            end
        end
    end, function(err)
        warn("Error in bringZombiesToPlayer function: " .. tostring(err))
    end)
end

-- Function to set up ESP
local function setupESP()
    xpcall(function()
        while settings.ESPEnabled do
            for _, zombie in ipairs(workspace.Zombies:GetChildren()) do
                if zombie:IsA("Model") and not zombie:FindFirstChild("ESPBox") then
                    local espBox = Instance.new("BoxHandleAdornment")
                    espBox.Name = "ESPBox"
                    espBox.Adornee = zombie
                    espBox.Size = zombie:GetExtentsSize()
                    espBox.AlwaysOnTop = true
                    espBox.ZIndex = 1
                    espBox.Transparency = 0.5
                    espBox.Color3 = settings.RainbowESP and rainbowEffect() or Color3.new(1, 0, 0)
                    espBox.Parent = zombie
                end
            end
            wait(0.1)
        end
    end, function(err)
        warn("Error in setupESP function: " .. tostring(err))
    end)
end

-- Function to create tracers
local function createTracers()
    xpcall(function()
        while settings.TracersEnabled do
            for _, zombie in ipairs(workspace.Zombies:GetChildren()) do
                if zombie:IsA("Model") and not zombie:FindFirstChild("TracerLine") then
                    local tracer = Instance.new("Beam")
                    tracer.Name = "TracerLine"
                    tracer.Color = ColorSequence.new(settings.RainbowESP and rainbowEffect() or Color3.new(0, 1, 0))
                    tracer.FaceCamera = true
                    tracer.AlwaysOnTop = true
                    tracer.Parent = zombie
                end
            end
            wait(0.1)
        end
    end, function(err)
        warn("Error in createTracers function: " .. tostring(err))
    end)
end

-- Bind keys for actions
local UserInputService = game:GetService("UserInputService")

UserInputService.InputBegan:Connect(function(input)
    pcall(function()
        if input.KeyCode == settings.AimbotKeybind then
            aimbot()
        elseif input.KeyCode == settings.KillAllZombiesKeybind then
            killAllZombies()
        end
    end)
end)

-- HVH Mode
spawn(function()
    xpcall(function()
        while settings.HvHMode do
            killAllZombies()
            bringZombiesToPlayer()
            game.StarterGui:SetCore("ChatMakeSystemMessage", {Text = settings.HvHMessage; Color = Color3.fromRGB(255, 255, 255)})
            wait(0.1)
        end
    end, function(err)
        warn("Error in HVH Mode loop: " .. tostring(err))
    end)
end)

-- Setup ESP
spawn(function()
    setupESP()
end)

-- Setup Tracers
spawn(function()
    createTracers()
end)

-- Create and Update FOV Circle
if settings.RainbowFov then
    createAndUpdateFOVCircle()
end

-- Main loop for continuous updates
spawn(function()
    xpcall(function()
        while true do
            if settings.RainbowFov then
                createAndUpdateFOVCircle()
            end

            if settings.ESPEnabled then
                setupESP()
            end

            if settings.TracersEnabled then
                createTracers()
            end

            wait(0.1)
        end
    end, function(err)
        warn("Error in main loop: " .. tostring(err))
    end)
end)
