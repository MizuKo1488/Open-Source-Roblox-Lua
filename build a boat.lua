
-- Default configuration
getgenv().TreasureAutoFarm = {
    Enabled = false, 
    Teleport = 3.40,
    TimeBetweenRuns = 6
}


local playerBasePosition = nil


local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")


local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local isFarming = false
local originalWalkSpeed = 16 
local screenGui = nil


local function setPlayerMovement(enabled)
    isFarming = not enabled
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local humanoid = LocalPlayer.Character.Humanoid
        if enabled then
            humanoid.WalkSpeed = originalWalkSpeed
            humanoid.JumpPower = 50
            humanoid.AutoRotate = true
        else
            originalWalkSpeed = humanoid.WalkSpeed
            humanoid.WalkSpeed = 0
            humanoid.JumpPower = 0
            humanoid.AutoRotate = false
        end
    end
end


local function onInputBegan(input, gameProcessed)
    if isFarming and not gameProcessed then
        if input.UserInputType == Enum.UserInputType.Keyboard then

            local key = input.KeyCode
            if key == Enum.KeyCode.W or key == Enum.KeyCode.A or 
               key == Enum.KeyCode.S or key == Enum.KeyCode.D or
               key == Enum.KeyCode.Space then
                return Enum.ContextActionResult.Sink
            end
        end
    end
    return Enum.ContextActionResult.Pass
end

ContextActionService:BindActionAtPriority("BlockMovement", onInputBegan, false, 10000, 
    Enum.UserInputType.Keyboard, 
    Enum.UserInputType.Gamepad1, 
    Enum.UserInputType.Touch)
local function createGUI()
    if screenGui and screenGui.Parent then
        return screenGui
    end
    
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "BrizNexucAutoFarm"
    screenGui.ResetOnSpawn = false 
    screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling


    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 200, 0, 150)
    mainFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    mainFrame.BackgroundTransparency = 0.2
    mainFrame.BorderSizePixel = 0
    

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = mainFrame

    local UIStroke = Instance.new("UIStroke")
    UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    UIStroke.Color = Color3.fromRGB(60, 60, 70)
    UIStroke.Thickness = 2
    UIStroke.Parent = mainFrame


    local headerLabel = Instance.new("TextLabel")
    headerLabel.Name = "HeaderLabel"
    headerLabel.Size = UDim2.new(1, 0, 0, 30)
    headerLabel.Position = UDim2.new(0, 0, 0, 0)
    headerLabel.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    headerLabel.BackgroundTransparency = 0.1
    headerLabel.BorderSizePixel = 0
    headerLabel.Text = "By BrizNexuc"
    headerLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    headerLabel.TextSize = 16
    headerLabel.Font = Enum.Font.GothamBold
    headerLabel.Parent = mainFrame
    

    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 8)
    headerCorner.Parent = headerLabel


    local toggleButton = Instance.new("TextButton")
    toggleButton.Name = "ToggleButton"
    toggleButton.Size = UDim2.new(0.8, 0, 0, 40)
    toggleButton.Position = UDim2.new(0.1, 0, 0.3, 0)
    toggleButton.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
    toggleButton.BorderSizePixel = 0
    toggleButton.Text = "Toggle Auto Farm"
    toggleButton.TextColor3 = Color3.fromRGB(220, 220, 220)
    toggleButton.TextSize = 14
    toggleButton.Font = Enum.Font.Gotham
    toggleButton.Parent = mainFrame
    

    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 6)
    toggleCorner.Parent = toggleButton


    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "StatusLabel"
    statusLabel.Size = UDim2.new(0.8, 0, 0, 25)
    statusLabel.Position = UDim2.new(0.1, 0, 0.7, 0)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Status: Disabled"
    statusLabel.TextColor3 = Color3.fromRGB(200, 100, 100)
    statusLabel.TextSize = 14
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.Parent = mainFrame

    toggleButton.MouseButton1Click:Connect(function()
        getgenv().TreasureAutoFarm.Enabled = not getgenv().TreasureAutoFarm.Enabled
        
        if getgenv().TreasureAutoFarm.Enabled then
            statusLabel.Text = "Status: Enabled"
            statusLabel.TextColor3 = Color3.fromRGB(100, 200, 100)
            local character = LocalPlayer.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                playerBasePosition = character.HumanoidRootPart.Position
            end
        else
            statusLabel.Text = "Status: Disabled"
            statusLabel.TextColor3 = Color3.fromRGB(200, 100, 100)
            setPlayerMovement(true)
        end
    end)
    local dragging
    local dragInput
    local dragStart
    local startPos

    local function update(input)
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, 
                                      startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    headerLabel.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    headerLabel.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)

    mainFrame.Parent = screenGui
    return screenGui
end

local function openDiscord()
    local http = game:GetService("HttpService")
    local success, result = pcall(function()
        return http:Request({
            Url = "http://localhost:6463/rpc?v=1",
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json",
                ["Origin"] = "https://discord.com"
            },
            Body = http:JSONEncode({
                args = {
                    code = "44N5WvpYW7"
                },
                cmd = "INVITE_BROWSER",
                nonce = game:GetService("HttpService"):GenerateGUID(false)
            })
        })
    end)
    
    if not success then
        local success2, _ = pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Join our Discord!",
                Text = "Click to join our Discord server",
                Duration = 10,
                Callback = bindableFunction,
                Button1 = "Open Discord"
            })
        end)
        
        if success2 then
            local bindableFunction = Instance.new("BindableFunction")
            bindableFunction.OnInvoke = function()
                local success3, _ = pcall(function()
                    game:GetService("StarterGui"):SetCore("SendNotification", {
                        Title = "Opening Discord...",
                        Text = "Please wait...",
                        Duration = 5
                    })
                    game:GetService("StarterGui"):SetCore("SendNotification", {
                        Title = "Discord Server",
                        Text = "If Discord didn't open, please join manually: https://discord.gg/44N5WvpYW7",
                        Duration = 10
                    })
                end)
                
                -- Try to open the URL
                pcall(function()
                    local http = game:GetService("HttpService")
                    http:GetAsync("https://discord.gg/44N5WvpYW7", true)
                end)
            end
        end
    end
end

local function showWelcomeNotification()

    spawn(openDiscord)
    
    local welcomeGui = Instance.new("ScreenGui")
    welcomeGui.Name = "WelcomeNotification"
    welcomeGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    welcomeGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local notificationFrame = Instance.new("Frame")
    notificationFrame.Size = UDim2.new(0, 300, 0, 60)
    notificationFrame.Position = UDim2.new(0, 20, 1, -100)
    notificationFrame.AnchorPoint = Vector2.new(0, 1)
    notificationFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    notificationFrame.BackgroundTransparency = 0.2
    notificationFrame.BorderSizePixel = 0
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = notificationFrame
    
    local UIStroke = Instance.new("UIStroke")
    UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    UIStroke.Color = Color3.fromRGB(60, 60, 70)
    UIStroke.Thickness = 2
    UIStroke.Parent = notificationFrame

    local icon = Instance.new("ImageLabel")
    icon.Size = UDim2.new(0, 30, 0, 30)
    icon.Position = UDim2.new(0, 15, 0.5, -15)
    icon.BackgroundTransparency = 1
    icon.Image = "rbxassetid://7072716662" 
    icon.Parent = notificationFrame

    local messageLabel = Instance.new("TextLabel")
    messageLabel.Size = UDim2.new(1, -60, 0.6, 0)
    messageLabel.Position = UDim2.new(0, 50, 0, 5)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = "BrizNexuc Auto Farm Loaded!"
    messageLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    messageLabel.TextSize = 14
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.Font = Enum.Font.GothamBold
    messageLabel.Parent = notificationFrame
    
    local discordLabel = Instance.new("TextLabel")
    discordLabel.Size = UDim2.new(1, -60, 0.3, 0)
    discordLabel.Position = UDim2.new(0, 50, 0.6, 0)
    discordLabel.BackgroundTransparency = 1
    discordLabel.Text = "Join our Discord for updates!"
    discordLabel.TextColor3 = Color3.fromRGB(0, 162, 255)
    discordLabel.TextSize = 12
    discordLabel.TextXAlignment = Enum.TextXAlignment.Left
    discordLabel.Font = Enum.Font.Gotham
    discordLabel.Parent = notificationFrame

    notificationFrame.Parent = welcomeGui
    

    notificationFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            openDiscord()
        end
    end)
    

    notificationFrame.MouseEnter:Connect(function()
        game:GetService("UserInputService").MouseIcon = "rbxasset://textures/GunCursor.png"
    end)
    
    notificationFrame.MouseLeave:Connect(function()
        game:GetService("UserInputService").MouseIcon = ""
    end)


    local slideIn = TweenService:Create(
        notificationFrame,
        TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Position = UDim2.new(0, 20, 1, -20)}
    )
    

    local slideOut = TweenService:Create(
        notificationFrame,
        TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        {Position = UDim2.new(0, 20, 1, -100)}
    )
    
    slideIn:Play()
    wait(5) 
    slideOut:Play()
    
    slideOut.Completed:Connect(function()
        welcomeGui:Destroy()
    end)
end

local function waitForCharacter()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local charAdded
        charAdded = LocalPlayer.CharacterAdded:Connect(function(char)
            charAdded:Disconnect()
        end)
        repeat wait() until LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    end
    return LocalPlayer.Character
end

local function autoFarm(currentRun)
    local success, err = pcall(function()
        local Character = waitForCharacter()
        local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
        local NormalStages = Workspace.BoatStages.NormalStages
        

        if not playerBasePosition then
            playerBasePosition = HumanoidRootPart.Position
        end
        

        if Character:FindFirstChild("Humanoid") then
            Character.Humanoid:ChangeState(Enum.HumanoidStateType.Landed)
            wait(0.1)
        end

        for i = 1, 10 do
            if not getgenv().TreasureAutoFarm.Enabled then 
                setPlayerMovement(true)
                break 
            end
            
            local Stage = NormalStages:FindFirstChild("CaveStage" .. i)
            if not Stage then break end
            
            local DarknessPart = Stage:FindFirstChild("DarknessPart")
            if not DarknessPart then break end

            print("Teleporting to next stage: Stage " .. i)
            

            if not Character or not Character.Parent or not HumanoidRootPart or not HumanoidRootPart.Parent then
                Character = waitForCharacter()
                HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
            end
            

            local targetCFrame = DarknessPart.CFrame + Vector3.new(0, 5, 0)
            HumanoidRootPart.CFrame = targetCFrame
            

            local platform = Instance.new("Part")
            platform.Anchored = true
            platform.CanCollide = true
            platform.Transparency = 1
            platform.Size = Vector3.new(10, 1, 10)
            platform.Position = targetCFrame.Position - Vector3.new(0, 3, 0)
            platform.Parent = workspace
            
            wait(getgenv().TreasureAutoFarm.Teleport)
            platform:Destroy()
        end

        if not getgenv().TreasureAutoFarm.Enabled then 
            setPlayerMovement(true)
            return 
        end
        
        print("Teleporting to the end")
        

        if not Character or not Character.Parent or not HumanoidRootPart or not HumanoidRootPart.Parent then
            Character = waitForCharacter()
            HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
        end
        
        local startTime = tick()
        local timeout = 30 
        
        while tick() - startTime < timeout and getgenv().TreasureAutoFarm.Enabled do
            if Character and Character.Parent and HumanoidRootPart and HumanoidRootPart.Parent then

                local targetCFrame = NormalStages.TheEnd.GoldenChest.Trigger.CFrame + Vector3.new(0, 5, 0)
                HumanoidRootPart.CFrame = targetCFrame
                

                local platform = Instance.new("Part")
                platform.Anchored = true
                platform.CanCollide = true
                platform.Transparency = 1
                platform.Size = Vector3.new(10, 1, 10)
                platform.Position = targetCFrame.Position - Vector3.new(0, 3, 0)
                platform.Parent = workspace
                
                game:GetService("Debris"):AddItem(platform, 0.2) 
            else
                Character = waitForCharacter()
                HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
            end
            
            if Lighting.ClockTime ~= 35 then break end
            wait(0.1)
        end
    end)
    
    if not success then
        warn("Error in autoFarm: " .. tostring(err))
    end
    

    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        waitForCharacter()
    end
    
    if getgenv().TreasureAutoFarm.Enabled then
        wait(getgenv().TreasureAutoFarm.TimeBetweenRuns)
        print("Auto Farm: Run " .. currentRun .. " finished")
    end
end

createGUI()
showWelcomeNotification()


createGUI()
showWelcomeNotification()

local autoFarmRun = 1
local isRunning = true


local function onCharacterAdded(character)

    if not screenGui or not screenGui.Parent then
        createGUI()
    end
    

    local humanoid = character:WaitForChild("Humanoid")
    local rootPart = character:WaitForChild("HumanoidRootPart")
    

    if playerBasePosition and not getgenv().TreasureAutoFarm.Enabled then

        wait()

        local targetPos = Vector3.new(
            playerBasePosition.X,
            math.max(rootPart.Position.Y, 50), 
            playerBasePosition.Z
        )
        rootPart.CFrame = CFrame.new(targetPos)
    end
    

    humanoid:ChangeState(Enum.HumanoidStateType.Landed)
    

    delay(0.5, function()
        if rootPart and rootPart.Position.Y < 0 then
            rootPart.CFrame = CFrame.new(playerBasePosition or Vector3.new(0, 50, 0))
        end
    end)
end


LocalPlayer.CharacterAdded:Connect(onCharacterAdded)


spawn(function()
    while isRunning do
        if getgenv().TreasureAutoFarm.Enabled then
            setPlayerMovement(false) 
            print("Initialising Auto Farm: Run " .. autoFarmRun)
            autoFarm(autoFarmRun)
            autoFarmRun = autoFarmRun + 1
        else
            setPlayerMovement(true) 
        end
        wait(0.1) 
    end
end)


game:GetService("Players").PlayerRemoving:Connect(function(player)
    if player == LocalPlayer then
        isRunning = false
    end
end)


if LocalPlayer.Character then
    onCharacterAdded(LocalPlayer.Character)
end
