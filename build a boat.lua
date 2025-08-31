-- // Custom Settings
getgenv().TreasureAutoFarm = {
    Enabled = true,
    Teleport = 3.40,
    TimeBetweenRuns = 6
}

-- // Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")

-- // Vars
local LocalPlayer = Players.LocalPlayer
local screenGui = nil
local autoFarmRunning = false
local autoFarmRun = 1

-- // GUI Creation Function
local function createGUI()
    if screenGui then
        screenGui:Destroy()
    end
    
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "BrizNexucAutoFarm"
    screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.ResetOnSpawn = false

    -- Main Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 200, 0, 150)
    mainFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    mainFrame.BackgroundTransparency = 0.2
    mainFrame.BorderSizePixel = 0
    
    -- Apply rounded corners
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = mainFrame
    
    -- Apply shadow effect
    local UIStroke = Instance.new("UIStroke")
    UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    UIStroke.Color = Color3.fromRGB(60, 60, 70)
    UIStroke.Thickness = 2
    UIStroke.Parent = mainFrame

    -- Header Label
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
    
    -- Header corner rounding
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 8)
    headerCorner.Parent = headerLabel

    -- Toggle Button
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
    
    -- Toggle button rounded corners
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 6)
    toggleCorner.Parent = toggleButton

    -- Status Indicator
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "StatusLabel"
    statusLabel.Size = UDim2.new(0.8, 0, 0, 25)
    statusLabel.Position = UDim2.new(0.1, 0, 0.7, 0)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Status: Enabled"
    statusLabel.TextColor3 = Color3.fromRGB(100, 200, 100)
    statusLabel.TextSize = 14
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.Parent = mainFrame

    -- Toggle button functionality
    toggleButton.MouseButton1Click:Connect(function()
        getgenv().TreasureAutoFarm.Enabled = not getgenv().TreasureAutoFarm.Enabled
        
        if getgenv().TreasureAutoFarm.Enabled then
            statusLabel.Text = "Status: Enabled"
            statusLabel.TextColor3 = Color3.fromRGB(100, 200, 100)
        else
            statusLabel.Text = "Status: Disabled"
            statusLabel.TextColor3 = Color3.fromRGB(200, 100, 100)
        end
    end)

    -- Make GUI draggable
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

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)

    mainFrame.Parent = screenGui
    return screenGui
end

-- // Function to completely block player movements
local function blockPlayerMovements(block)
    if block then
        -- Disable all movement inputs
        local function blockInput(input)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                return true
            elseif input.UserInputType == Enum.UserInputType.Gamepad1 then
                return true
            elseif input.UserInputType == Enum.UserInputType.Touch then
                return true
            end
            return false
        end
        
        -- Block all input
        UserInputService.InputBegan:Connect(function(input)
            if blockInput(input) then
                input:Disallow()
            end
        end)
        
        -- Force character to stay in place by continuously setting velocity to zero
        local movementBlockConnection
        movementBlockConnection = RunService.Heartbeat:Connect(function()
            if autoFarmRunning and LocalPlayer.Character then
                local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
                local rootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                
                if humanoid and rootPart then
                    -- Completely stop any movement
                    humanoid:ChangeState(Enum.HumanoidStateType.Physics)
                    rootPart.Velocity = Vector3.new(0, 0, 0)
                    rootPart.RotVelocity = Vector3.new(0, 0, 0)
                    
                    -- Cancel any jump attempts
                    humanoid.Jump = false
                end
            else
                movementBlockConnection:Disconnect()
            end
        end)
    end
end

-- // Welcome Notification Function
local function showWelcomeNotification()
    local welcomeGui = Instance.new("ScreenGui")
    welcomeGui.Name = "WelcomeNotification"
    welcomeGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    welcomeGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    welcomeGui.ResetOnSpawn = false

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
    messageLabel.Size = UDim2.new(1, -60, 1, 0)
    messageLabel.Position = UDim2.new(0, 50, 0, 0)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = "BrizNexuc Auto Farm Loaded!"
    messageLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    messageLabel.TextSize = 14
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.Parent = notificationFrame

    notificationFrame.Parent = welcomeGui

    -- Animation: Slide in
    local slideIn = TweenService:Create(
        notificationFrame,
        TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Position = UDim2.new(0, 20, 1, -20)}
    )
    
    -- Animation: Slide out after delay
    local slideOut = TweenService:Create(
        notificationFrame,
        TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        {Position = UDim2.new(0, 20, 1, -100)}
    )
    
    slideIn:Play()
    wait(3)
    slideOut:Play()
    
    slideOut.Completed:Connect(function()
        welcomeGui:Destroy()
    end)
end

-- // Auto Farm Function with movement lock
local function autoFarm(currentRun)
    autoFarmRunning = true
    blockPlayerMovements(true)
    
    local Character = LocalPlayer.Character
    local NormalStages = Workspace.BoatStages.NormalStages

    for i = 1, 10 do
        if not getgenv().TreasureAutoFarm.Enabled then break end
        
        local Stage = NormalStages["CaveStage" .. i]
        local DarknessPart = Stage:FindFirstChild("DarknessPart")

        if (DarknessPart) then
            print("Teleporting to next stage: Stage " .. i)
            Character.HumanoidRootPart.CFrame = DarknessPart.CFrame

            local Part = Instance.new("Part", LocalPlayer.Character)
            Part.Anchored = true
            Part.Position = LocalPlayer.Character.HumanoidRootPart.Position - Vector3.new(0, 6, 0)

            wait(getgenv().TreasureAutoFarm.Teleport)
            Part:Destroy()
        end
    end

    if getgenv().TreasureAutoFarm.Enabled then
        print("Teleporting to the end")
        repeat 
            wait()
            Character.HumanoidRootPart.CFrame = NormalStages.TheEnd.GoldenChest.Trigger.CFrame
        until Lighting.ClockTime ~= 35 or not getgenv().TreasureAutoFarm.Enabled
    end

    -- Wait until you have respawned
    if getgenv().TreasureAutoFarm.Enabled then
        local Respawned = false
        local Connection
        Connection = LocalPlayer.CharacterAdded:Connect(function()
            Respawned = true
            Connection:Disconnect()
        end)

        repeat wait() until Respawned or not getgenv().TreasureAutoFarm.Enabled
        
        if getgenv().TreasureAutoFarm.Enabled then
            wait(getgenv().TreasureAutoFarm.TimeBetweenRuns)
            print("Auto Farm: Run " .. currentRun .. " finished")
        end
    end
    
    autoFarmRunning = false
    blockPlayerMovements(false)
end

-- // Initialize GUI and welcome message
createGUI()
showWelcomeNotification()

-- // Handle character respawns to recreate GUI if needed
LocalPlayer.CharacterAdded:Connect(function(character)
    wait(1) -- Small delay to ensure character is fully loaded
    if not screenGui or not screenGui.Parent then
        createGUI()
    end
end)

-- // Main loop
spawn(function()
    while wait() do
        if getgenv().TreasureAutoFarm.Enabled then
            print("Initialising Auto Farm: Run " .. autoFarmRun)
            autoFarm(autoFarmRun)
            autoFarmRun = autoFarmRun + 1
        end
    end
end)
