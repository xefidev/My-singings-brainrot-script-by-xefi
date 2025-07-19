-- Xefi Script - My Singing Brainrot Edition
local player = game.Players.LocalPlayer
local runService = game:GetService("RunService")
local tweenService = game:GetService("TweenService")

-- Переменные состояний
local isAutoCollect = false
local isAutoBuyEggs = false
local selectedEgg = "Basic Egg" -- По умолчанию
local isAutoHatch = false
local isAutoExpand = false
local isAntiAFK = false

-- Создание GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "XefiScriptGui"
screenGui.Parent = player:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false

-- Иконка
local toggleIcon = Instance.new("ImageButton")
toggleIcon.Size = UDim2.new(0, 60, 0, 60)
toggleIcon.Position = UDim2.new(1, -70, 0, 10)
toggleIcon.BackgroundColor3 = Color3.fromRGB(0, 255, 127)
toggleIcon.BorderSizePixel = 0
local iconCorner = Instance.new("UICorner")
iconCorner.CornerRadius = UDim.new(0, 15)
iconCorner.Parent = toggleIcon
toggleIcon.Parent = screenGui

-- Меню
local menuFrame = Instance.new("Frame")
menuFrame.Size = UDim2.new(0, 320, 0, 400)
menuFrame.Position = UDim2.new(0.5, -160, 0.5, -200)
menuFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
menuFrame.BorderSizePixel = 0
local menuCorner = Instance.new("UICorner")
menuCorner.CornerRadius = UDim.new(0, 12)
menuCorner.Parent = menuFrame
menuFrame.Parent = screenGui

-- Тень
local menuShadow = Instance.new("ImageLabel")
menuShadow.Size = UDim2.new(1, 20, 1, 20)
menuShadow.Position = UDim2.new(0, -10, 0, -10)
menuShadow.BackgroundTransparency = 1
menuShadow.Image = "rbxassetid://1316045217"
menuShadow.ImageTransparency = 0.8
menuShadow.ScaleType = Enum.ScaleType.Slice
menuShadow.SliceCenter = Rect.new(10, 10, 118, 118)
menuShadow.Parent = menuFrame

-- Название
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 50)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Xefi Script"
titleLabel.TextColor3 = Color3.fromRGB(0, 255, 127)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 24
titleLabel.Parent = menuFrame

-- Контент с прокруткой
local scrollingFrame = Instance.new("ScrollingFrame")
scrollingFrame.Size = UDim2.new(1, -10, 1, -60)
scrollingFrame.Position = UDim2.new(0, 5, 0, 55)
scrollingFrame.BackgroundTransparency = 1
scrollingFrame.ScrollBarThickness = 4
scrollingFrame.Parent = menuFrame

local content = Instance.new("Frame")
content.Size = UDim2.new(1, 0, 0, 500)
content.BackgroundTransparency = 1
content.Parent = scrollingFrame

-- Кнопки
local autoCollectToggle = Instance.new("TextButton")
autoCollectToggle.Size = UDim2.new(0, 250, 0, 50)
autoCollectToggle.Position = UDim2.new(0, 30, 0, 10)
autoCollectToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
autoCollectToggle.Text = "Auto Collect Coins: OFF"
autoCollectToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
autoCollectToggle.Font = Enum.Font.Gotham
autoCollectToggle.TextSize = 16
autoCollectToggle.Parent = content

local autoBuyEggsToggle = Instance.new("TextButton")
autoBuyEggsToggle.Size = UDim2.new(0, 250, 0, 50)
autoBuyEggsToggle.Position = UDim2.new(0, 30, 0, 70)
autoBuyEggsToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
autoBuyEggsToggle.Text = "Auto Buy Eggs: OFF"
autoBuyEggsToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
autoBuyEggsToggle.Font = Enum.Font.Gotham
autoBuyEggsToggle.TextSize = 16
autoBuyEggsToggle.Parent = content

local eggSelect = Instance.new("TextButton")
eggSelect.Size = UDim2.new(0, 250, 0, 50)
eggSelect.Position = UDim2.new(0, 30, 0, 130)
eggSelect.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
eggSelect.Text = "Selected Egg: " .. selectedEgg
eggSelect.TextColor3 = Color3.fromRGB(255, 255, 255)
eggSelect.Font = Enum.Font.Gotham
eggSelect.TextSize = 16
eggSelect.Parent = content

local autoHatchToggle = Instance.new("TextButton")
autoHatchToggle.Size = UDim2.new(0, 250, 0, 50)
autoHatchToggle.Position = UDim2.new(0, 30, 0, 190)
autoHatchToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
autoHatchToggle.Text = "Auto Hatch Eggs: OFF"
autoHatchToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
autoHatchToggle.Font = Enum.Font.Gotham
autoHatchToggle.TextSize = 16
autoHatchToggle.Parent = content

local autoExpandToggle = Instance.new("TextButton")
autoExpandToggle.Size = UDim2.new(0, 250, 0, 50)
autoExpandToggle.Position = UDim2.new(0, 30, 0, 250)
autoExpandToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
autoExpandToggle.Text = "Auto Expand Territory: OFF"
autoExpandToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
autoExpandToggle.Font = Enum.Font.Gotham
autoExpandToggle.TextSize = 16
autoExpandToggle.Parent = content

local antiAFKToggle = Instance.new("TextButton")
antiAFKToggle.Size = UDim2.new(0, 250, 0, 50)
antiAFKToggle.Position = UDim2.new(0, 30, 0, 310)
antiAFKToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
antiAFKToggle.Text = "Anti-AFK: OFF"
antiAFKToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
antiAFKToggle.Font = Enum.Font.Gotham
antiAFKToggle.TextSize = 16
antiAFKToggle.Parent = content

-- Закруглённые углы
for _, btn in pairs({autoCollectToggle, autoBuyEggsToggle, eggSelect, autoHatchToggle, autoExpandToggle, antiAFKToggle}) do
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn
end

-- Список яиц
local eggTypes = {"Basic Egg", "Rare Egg", "Epic Egg", "Shard Egg", "Golden Egg", "Diamond Egg", "Electric Egg", "Fire Egg", "Plastic Egg", "Mythic Plastic Egg", "Seasonal Egg"}

-- Логика функций
local function collectCoins()
    if isAutoCollect then
        local coinsFolder = nil
        for _, child in pairs(game.Workspace:GetChildren()) do
            if string.find(child.Name:lower(), "coin") or string.find(child.Name:lower(), "collect") then
                coinsFolder = child
                break
            end
        end
        if coinsFolder and (coinsFolder:IsA("Folder") or coinsFolder:IsA("Model")) then
            for _, coin in pairs(coinsFolder:GetChildren()) do
                if coin:IsA("BasePart") then
                    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                    local tween = tweenService:Create(player.Character.HumanoidRootPart, tweenInfo, {CFrame = CFrame.new(coin.Position + Vector3.new(0, 3, 0))})
                    tween:Play()
                    tween.Completed:Wait()
                    firetouchinterest(player.Character.HumanoidRootPart, coin, 0)
                    wait(0.1)
                end
            end
        else
            print("Warning: No coins folder found. Check Workspace for 'coin' or 'collect' in name.")
        end
    end
end

local function buyEggs()
    if isAutoBuyEggs then
        local shopFolder = nil
        for _, child in pairs(game.Workspace:GetChildren()) do
            if string.find(child.Name:lower(), "shop") or string.find(child.Name:lower(), "eggconveyor") then
                shopFolder = child
                break
            end
        end
        if shopFolder then
            local egg = shopFolder:FindFirstChild(selectedEgg)
            if egg and egg:FindFirstChild("ClickDetector") then
                fireclickdetector(egg.ClickDetector)
            else
                print("Warning: Egg '" .. selectedEgg .. "' or its ClickDetector not found in " .. shopFolder.Name)
            end
        else
            print("Warning: No shop folder found. Check Workspace for 'shop' or 'eggconveyor' in name.")
        end
    end
end

local function hatchEggs()
    if isAutoHatch then
        local inventory = player.Backpack or player.Character
        local egg = inventory:FindFirstChild(selectedEgg)
        if egg then
            local remoteEvents = game:GetService("ReplicatedStorage"):FindFirstChild("RemoteEvents")
            if remoteEvents then
                local hatchEvent = remoteEvents:FindFirstChild("HatchEvent") or remoteEvents:FindFirstChild("HatchEgg")
                if hatchEvent then
                    local success, err = pcall(function()
                        hatchEvent:FireServer(egg)
                    end)
                    if not success then print("Error hatching egg: " .. err) end
                else
                    print("Warning: HatchEvent or HatchEgg not found in RemoteEvents.")
                end
            else
                print("Warning: RemoteEvents not found in ReplicatedStorage.")
            end
        else
            print("Warning: Egg '" .. selectedEgg .. "' not found in inventory.")
        end
    end
end

local territoryLevels = {"SmallPlot", "MediumPlot", "LargePlot", "HugePlot"} -- Уточни имена
local currentLevel = 1
local function expandTerritory()
    if isAutoExpand then
        local territoryShop = nil
        for _, child in pairs(game.Workspace:GetChildren()) do
            if string.find(child.Name:lower(), "territory") or string.find(child.Name:lower(), "land") or string.find(child.Name:lower(), "upgrade") then
                territoryShop = child
                break
            end
        end
        if territoryShop then
            local upgrade = territoryShop:FindFirstChild(territoryLevels[currentLevel])
            if upgrade and upgrade:FindFirstChild("ClickDetector") then
                fireclickdetector(upgrade.ClickDetector)
                currentLevel = math.min(currentLevel + 1, #territoryLevels)
            else
                print("Warning: Upgrade '" .. territoryLevels[currentLevel] .. "' or its ClickDetector not found.")
            end
        else
            print("Warning: No territory shop found. Check Workspace for 'territory', 'land', or 'upgrade' in name.")
        end
    end
end

local function antiAFK()
    if isAntiAFK then
        while wait(15) do
            local virtualUser = game:GetService("VirtualUser")
            virtualUser:CaptureController()
            virtualUser:ClickButton2(Vector2.new())
            wait(1)
            virtualUser:Button1Down(Vector2.new(0, 0))
            wait(0.1)
            virtualUser:Button1Up(Vector2.new(0, 0))
            print("Anti-AFK triggered")
        end
    end
end

-- Обновление каждую секунду
runService.Heartbeat:Connect(function()
    collectCoins()
    buyEggs()
    hatchEggs()
    expandTerritory()
    if not isAntiAFK then return end
end)

-- Обработчики кнопок
toggleIcon.MouseButton1Click:Connect(function()
    menuFrame.Visible = not menuFrame.Visible
    toggleIcon.BackgroundColor3 = menuFrame.Visible and Color3.fromRGB(255, 0, 127) or Color3.fromRGB(0, 255, 127)
end)

autoCollectToggle.MouseButton1Click:Connect(function()
    isAutoCollect = not isAutoCollect
    autoCollectToggle.Text = "Auto Collect Coins: " .. (isAutoCollect and "ON" or "OFF")
    autoCollectToggle.BackgroundColor3 = isAutoCollect and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(50, 50, 50)
end)

autoBuyEggsToggle.MouseButton1Click:Connect(function()
    isAutoBuyEggs = not isAutoBuyEggs
    autoBuyEggsToggle.Text = "Auto Buy Eggs: " .. (isAutoBuyEggs and "ON" or "OFF")
    autoBuyEggsToggle.BackgroundColor3 = isAutoBuyEggs and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(50, 50, 50)
end)

eggSelect.MouseButton1Click:Connect(function()
    local index = table.find(eggTypes, selectedEgg) or 1
    selectedEgg = eggTypes[(index % #eggTypes) + 1]
    eggSelect.Text = "Selected Egg: " .. selectedEgg
end)

autoHatchToggle.MouseButton1Click:Connect(function()
    isAutoHatch = not isAutoHatch
    autoHatchToggle.Text = "Auto Hatch Eggs: " .. (isAutoHatch and "ON" or "OFF")
    autoHatchToggle.BackgroundColor3 = isAutoHatch and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(50, 50, 50)
end)

autoExpandToggle.MouseButton1Click:Connect(function()
    isAutoExpand = not isAutoExpand
    autoExpandToggle.Text = "Auto Expand Territory: " .. (isAutoExpand and "ON" or "OFF")
    autoExpandToggle.BackgroundColor3 = isAutoExpand and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(50, 50, 50)
end)

antiAFKToggle.MouseButton1Click:Connect(function()
    isAntiAFK = not isAntiAFK
    antiAFKToggle.Text = "Anti-AFK: " .. (isAntiAFK and "ON" or "OFF")
    antiAFKToggle.BackgroundColor3 = isAntiAFK and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(50, 50, 50)
    if not isAntiAFK then
        local virtualUser = game:GetService("VirtualUser")
        virtualUser:CaptureController()
        virtualUser:ClickButton2(Vector2.new())
    end
end)

-- Инициализация
scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 500)
print("Xefi Script Loaded Successfully!")