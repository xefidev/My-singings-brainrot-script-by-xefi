-- Проверка совместимости executor'а
local function checkExecutorCompatibility()
    local success, _ = pcall(function()
        return game:GetService("HttpService")
    end)
    if not success or not game:IsLoaded() then
        warn("Executor не поддерживает базовые функции или игра не загружена")
        return false
    end
    print("Executor совместим, начинаем запуск Xefi Hub") -- Отладка
    return true
end

if not checkExecutorCompatibility() then
    return
end

-- Очистка глобальных переменных
local function clearGlobalVariables()
    local env = getfenv and getfenv() or _G
    for key, _ in pairs(env) do
        if key ~= "game" and key ~= "shared" then
            pcall(function() rawset(env, key, nil) end)
            print("Очищена глобальная переменная: " .. key) -- Отладка
        end
    end
end
clearGlobalVariables()

-- Логирование всех сервисов
print("Список сервисов в game:GetService():")
for _, service in pairs(game:GetService("CoreGui"):GetChildren()) do
    if service:IsA("Instance") then
        print(" - " .. service.Name .. " (" .. service.ClassName .. ")")
    end
end

-- Ожидание полной загрузки игры
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui", 50)
if not playerGui then
    warn("PlayerGui не найден после 50 секунд, скрипт остановлен")
    return
end
local character = player.Character or player.CharacterAdded:Wait()
if not character then
    warn("Персонаж не найден, скрипт остановлен")
    return
end
print("Игра загружена, начинаем инициализацию Xefi Hub") -- Отладка

-- Очистка всех сторонних ScreenGui
local systemGuis = {"RobloxGui", "HeadsetDisconnectedDialog", "CoreGuiPrompt", "TeleportGui"}
for _, existingGui in pairs(game:GetService("CoreGui"):GetChildren()) do
    if existingGui:IsA("ScreenGui") and not table.find(systemGuis, existingGui.Name) and existingGui.Name ~= "XefiHubUI" then
        local zIndex = 0
        pcall(function() zIndex = existingGui.ZIndex or 0 end)
        print("Обнаружен ScreenGui: " .. existingGui.Name .. " (DisplayOrder: " .. (existingGui.DisplayOrder or 0) .. ", ZIndex: " .. zIndex .. ")") -- Отладка
        for _, child in pairs(existingGui:GetDescendants()) do
            if child:IsA("TextLabel") or child.Name:lower():find("styledtextlabel") then
                print("Обнаружен UI элемент: " .. child.Name .. " в " .. existingGui.Name) -- Отладка
            end
        end
        pcall(function() existingGui:Destroy() end)
        print("Удалён ScreenGui: " .. existingGui.Name) -- Отладка
    end
end

local gui = Instance.new("ScreenGui")
gui.Name = "XefiHubUI"
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.ResetOnSpawn = false
gui.DisplayOrder = 400000 -- Очень высокий приоритет
gui.Parent = game:GetService("CoreGui")
print("ScreenGui создан в CoreGui с DisplayOrder 400000") -- Отладка

local colors = {
    background = Color3.fromRGB(30, 30, 35),
    header = Color3.fromRGB(20, 20, 25),
    primary = Color3.fromRGB(50, 50, 60),
    accent = Color3.fromRGB(85, 255, 85), -- Зелёный для иконки
    text = Color3.fromRGB(240, 240, 240),
    error = Color3.fromRGB(255, 85, 85),
    success = Color3.fromRGB(85, 255, 85),
    hover = Color3.fromRGB(70, 70, 80)
}

-- Функция уведомлений
local function showNotification(text, color)
    color = color or colors.text
    print("Уведомление: " .. text) -- Отладка
    local screenGui = gui:FindFirstChild("NotificationGui") or Instance.new("ScreenGui")
    screenGui.Name = "NotificationGui"
    screenGui.Parent = gui
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.DisplayOrder = 400001

    local notification = Instance.new("Frame")
    notification.Name = "Notification"
    notification.BackgroundColor3 = colors.background
    notification.BackgroundTransparency = 0.2
    notification.BorderSizePixel = 0
    notification.Size = UDim2.new(0.3, 0, 0.08, 0)
    notification.Position = UDim2.new(0.85, 0, 0.9, 0)
    notification.AnchorPoint = Vector2.new(0.5, 0.5)
    notification.Parent = screenGui
    notification.ZIndex = 400002
    notification.ClipsDescendants = true

    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 10)
    uiCorner.Parent = notification

    local glow = Instance.new("ImageLabel")
    glow.Name = "Glow"
    glow.Image = "rbxassetid://5028857084"
    glow.ImageColor3 = color
    glow.ImageTransparency = 0.7
    glow.ScaleType = Enum.ScaleType.Slice
    glow.SliceCenter = Rect.new(24, 24, 24, 24)
    glow.Size = UDim2.new(1, 20, 1, 20)
    glow.Position = UDim2.new(0, -10, 0, -10)
    glow.BackgroundTransparency = 1
    glow.Parent = notification
    glow.ZIndex = 400001

    local textLabel = Instance.new("TextLabel")
    textLabel.Name = "Text"
    textLabel.Text = text
    textLabel.TextColor3 = color
    textLabel.TextSize = 16
    textLabel.BackgroundTransparency = 1
    textLabel.Size = UDim2.new(0.9, 0, 0.8, 0)
    textLabel.Position = UDim2.new(0.05, 0, 0.1, 0)
    textLabel.Font = Enum.Font.GothamMedium
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.TextWrapped = true
    textLabel.Parent = notification
    textLabel.ZIndex = 400003

    notification.BackgroundTransparency = 1
    textLabel.TextTransparency = 1

    local success, err = pcall(function()
        local appearTween = TweenService:Create(
            notification,
            TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {BackgroundTransparency = 0.2}
        )

        local textAppearTween = TweenService:Create(
            textLabel,
            TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {TextTransparency = 0}
        )

        appearTween:Play()
        textAppearTween:Play()

        task.wait(3)

        local disappearTween = TweenService:Create(
            notification,
            TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {BackgroundTransparency = 1}
        )

        local textDisappearTween = TweenService:Create(
            textLabel,
            TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {TextTransparency = 1}
        )

        disappearTween:Play()
        textDisappearTween:Play()

        disappearTween.Completed:Connect(function()
            notification:Destroy()
            if #screenGui:GetChildren() == 0 then
                screenGui:Destroy()
            end
        end)
    end)
    if not success then
        warn("Ошибка в уведомлении: " .. tostring(err))
        notification:Destroy()
    end
end

-- Функция для эффекта кнопок
local function createButtonEffect(button)
    local originalSize = button.Size
    local originalPos = button.Position
    local originalColor = button.BackgroundColor3
    
    button.MouseEnter:Connect(function()
        pcall(function()
            TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                BackgroundColor3 = colors.hover,
                Size = originalSize + UDim2.new(0, 5, 0, 5)
            }):Play()
        end)
    end)
    
    button.MouseLeave:Connect(function()
        pcall(function()
            TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                BackgroundColor3 = originalColor,
                Size = originalSize
            }):Play()
        end)
    end)
    
    button.MouseButton1Down:Connect(function()
        pcall(function()
            TweenService:Create(button, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
                Size = originalSize - UDim2.new(0, 5, 0, 5),
                Position = originalPos + UDim2.new(0, 2.5, 0, 2.5)
            }):Play()
        end)
    end)
    
    button.MouseButton1Up:Connect(function()
        pcall(function()
            TweenService:Create(button, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
                Size = originalSize,
                Position = originalPos
            }):Play()
        end)
    end)
end

-- Функция для перетаскивания
local function makeDraggable(frame)
    local dragStartPos
    local frameStartPos
    local dragging = false

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStartPos = Vector2.new(input.Position.X, input.Position.Y)
            frameStartPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = Vector2.new(input.Position.X, input.Position.Y) - dragStartPos
            frame.Position = UDim2.new(
                frameStartPos.X.Scale,
                frameStartPos.X.Offset + delta.X,
                frameStartPos.Y.Scale,
                frameStartPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- Создание интерфейса
print("Создаём главное окно UI") -- Отладка
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 320, 0, 500)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = colors.background
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = gui
mainFrame.ZIndex = 400000

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = mainFrame

local glow = Instance.new("ImageLabel")
glow.Name = "Glow"
glow.Image = "rbxassetid://5028857084"
glow.ImageColor3 = colors.accent
glow.ImageTransparency = 0.7
glow.ScaleType = Enum.ScaleType.Slice
glow.SliceCenter = Rect.new(24, 24, 24, 24)
glow.Size = UDim2.new(1, 20, 1, 20)
glow.Position = UDim2.new(0, -10, 0, -10)
glow.BackgroundTransparency = 1
glow.Parent = mainFrame
glow.ZIndex = 399999

local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = colors.header
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame
titleBar.ZIndex = 400001
titleBar.ClipsDescendants = true

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, -40, 1, 0)
titleLabel.Position = UDim2.new(0, 20, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Xefi Hub - Grow a Garden"
titleLabel.TextColor3 = colors.accent
titleLabel.TextSize = 18
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar
titleLabel.ZIndex = 400002

local closeButton = Instance.new("ImageButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 24, 0, 24)
closeButton.Position = UDim2.new(1, -32, 0.5, -12)
closeButton.BackgroundTransparency = 1
closeButton.Image = "rbxassetid://3926305904"
closeButton.ImageColor3 = colors.text
closeButton.ImageRectOffset = Vector2.new(284, 4)
closeButton.ImageRectSize = Vector2.new(24, 24)
closeButton.Parent = titleBar
closeButton.ZIndex = 400003

-- Выпадающий список для выбора семян
local seedList = {
    "Apple", "Avocado", "Bamboo", "Carrot", "Potato", "Strawberry", "Pumpkin", "Tomato", "Corn",
    "Coconut", "Cactus", "Pitaya", "Mango", "Grape", "Pepper", "Cocoa",
    "Cherry Blossom", "Durian", "Cranberry", "Lotus", "Eggplant", "Venus Flytrap",
    "Candy Blossom", "Lunar Mango", "Lunar Melon", "Hive Fruit", "Lumira"
}
local selectedSeed = seedList[1]

print("Создаём выпадающий список семян") -- Отладка
local dropdownFrame = Instance.new("Frame")
dropdownFrame.Name = "DropdownFrame"
dropdownFrame.Size = UDim2.new(0.8, 0, 0, 40)
dropdownFrame.Position = UDim2.new(0.1, 0, 0, 60)
dropdownFrame.BackgroundColor3 = colors.primary
dropdownFrame.BorderSizePixel = 0
dropdownFrame.Parent = mainFrame
dropdownFrame.ZIndex = 400005
dropdownFrame.ClipsDescendants = true

local dropdownCorner = Instance.new("UICorner")
dropdownCorner.CornerRadius = UDim.new(0, 10)
dropdownCorner.Parent = dropdownFrame

local dropdownButton = Instance.new("TextButton")
dropdownButton.Name = "DropdownButton"
dropdownButton.Size = UDim2.new(1, 0, 1, 0)
dropdownButton.BackgroundTransparency = 1
dropdownButton.Text = "Seed: " .. selectedSeed
dropdownButton.TextColor3 = colors.text
dropdownButton.TextSize = 16
dropdownButton.Font = Enum.Font.GothamMedium
dropdownButton.Parent = dropdownFrame
dropdownButton.ZIndex = 400006

local dropdownList = Instance.new("Frame")
dropdownList.Name = "DropdownList"
dropdownList.Size = UDim2.new(1, 0, 0, 150)
dropdownList.Position = UDim2.new(0, 0, 1, 5)
dropdownList.BackgroundColor3 = colors.background
dropdownList.BackgroundTransparency = 0.2
dropdownList.BorderSizePixel = 0
dropdownList.Visible = false
dropdownList.ClipsDescendants = true
dropdownList.Parent = dropdownFrame
dropdownList.ZIndex = 400010

local dropdownListCorner = Instance.new("UICorner")
dropdownListCorner.CornerRadius = UDim.new(0, 10)
dropdownListCorner.Parent = dropdownList

local dropdownListLayout = Instance.new("UIListLayout")
dropdownListLayout.SortOrder = Enum.SortOrder.LayoutOrder
dropdownListLayout.Padding = UDim.new(0, 5)
dropdownListLayout.Parent = dropdownList

-- Создание кнопок для выбора семян
for i, seed in ipairs(seedList) do
    local seedButton = Instance.new("TextButton")
    seedButton.Size = UDim2.new(1, -10, 0, 30)
    seedButton.Position = UDim2.new(0, 5, 0, 5)
    seedButton.BackgroundColor3 = colors.primary
    seedButton.BorderSizePixel = 0
    seedButton.Text = seed
    seedButton.TextColor3 = colors.text
    seedButton.TextSize = 14
    seedButton.Font = Enum.Font.GothamMedium
    seedButton.Parent = dropdownList
    seedButton.ZIndex = 400011

    local seedCorner = Instance.new("UICorner")
    seedCorner.CornerRadius = UDim.new(0, 8)
    seedCorner.Parent = seedButton

    createButtonEffect(seedButton)

    seedButton.MouseButton1Click:Connect(function()
        selectedSeed = seed
        dropdownButton.Text = "Seed: " .. seed
        dropdownList.Visible = false
        showNotification("Выбрано семя: " .. seed, colors.success)
    end)
end

dropdownButton.MouseButton1Click:Connect(function()
    dropdownList.Visible = not dropdownList.Visible
    print("Dropdown " .. (dropdownList.Visible and "открыт" or "закрыт")) -- Отладка
end)

-- Поле для ввода скорости
print("Создаём поле для ввода скорости") -- Отладка
local speedFrame = Instance.new("Frame")
speedFrame.Name = "SpeedFrame"
speedFrame.Size = UDim2.new(0.8, 0, 0, 40)
speedFrame.Position = UDim2.new(0.1, 0, 0, 410)
speedFrame.BackgroundColor3 = colors.primary
speedFrame.BorderSizePixel = 0
speedFrame.Parent = mainFrame
speedFrame.ZIndex = 400005
speedFrame.ClipsDescendants = true

local speedCorner = Instance.new("UICorner")
speedCorner.CornerRadius = UDim.new(0, 10)
speedCorner.Parent = speedFrame

local speedTextBox = Instance.new("TextBox")
speedTextBox.Name = "SpeedTextBox"
speedTextBox.Size = UDim2.new(0.7, 0, 1, 0)
speedTextBox.Position = UDim2.new(0, 5, 0, 0)
speedTextBox.BackgroundTransparency = 1
speedTextBox.Text = "32 (дефолт)"
speedTextBox.TextColor3 = colors.text
speedTextBox.TextSize = 16
speedTextBox.Font = Enum.Font.GothamMedium
speedTextBox.PlaceholderText = "Введите скорость (16-100)"
speedTextBox.Parent = speedFrame
speedTextBox.ZIndex = 400006

local speedApplyButton = Instance.new("TextButton")
speedApplyButton.Name = "SpeedApplyButton"
speedApplyButton.Size = UDim2.new(0.25, 0, 1, 0)
speedApplyButton.Position = UDim2.new(0.75, 0, 0, 0)
speedApplyButton.BackgroundColor3 = colors.primary
speedApplyButton.BorderSizePixel = 0
speedApplyButton.Text = "OK"
speedApplyButton.TextColor3 = colors.text
speedApplyButton.TextSize = 16
speedApplyButton.Font = Enum.Font.GothamMedium
speedApplyButton.Parent = speedFrame
speedApplyButton.ZIndex = 400006

local speedApplyCorner = Instance.new("UICorner")
speedApplyCorner.CornerRadius = UDim.new(0, 10)
speedApplyCorner.Parent = speedApplyButton

createButtonEffect(speedApplyButton)

-- Кнопки для функций
print("Создаём кнопки функций") -- Отладка
local autoBuyButton = Instance.new("TextButton")
autoBuyButton.Name = "AutoBuyButton"
autoBuyButton.Size = UDim2.new(0.8, 0, 0, 40)
autoBuyButton.Position = UDim2.new(0.1, 0, 0, 110)
autoBuyButton.BackgroundColor3 = colors.primary
autoBuyButton.BorderSizePixel = 0
autoBuyButton.Text = "Auto Buy Seeds: OFF"
autoBuyButton.TextColor3 = colors.text
autoBuyButton.TextSize = 16
autoBuyButton.Font = Enum.Font.GothamMedium
autoBuyButton.Parent = mainFrame
autoBuyButton.ZIndex = 400002
autoBuyButton.ClipsDescendants = true

local autoBuyCorner = Instance.new("UICorner")
autoBuyCorner.CornerRadius = UDim.new(0, 10)
autoBuyCorner.Parent = autoBuyButton

local autoPlantButton = Instance.new("TextButton")
autoPlantButton.Name = "AutoPlantButton"
autoPlantButton.Size = UDim2.new(0.8, 0, 0, 40)
autoPlantButton.Position = UDim2.new(0.1, 0, 0, 160)
autoPlantButton.BackgroundColor3 = colors.primary
autoPlantButton.BorderSizePixel = 0
autoPlantButton.Text = "Auto Plant: OFF"
autoPlantButton.TextColor3 = colors.text
autoPlantButton.TextSize = 16
autoPlantButton.Font = Enum.Font.GothamMedium
autoPlantButton.Parent = mainFrame
autoPlantButton.ZIndex = 400002
autoPlantButton.ClipsDescendants = true

local autoPlantCorner = Instance.new("UICorner")
autoPlantCorner.CornerRadius = UDim.new(0, 10)
autoPlantCorner.Parent = autoPlantButton

local autoHarvestButton = Instance.new("TextButton")
autoHarvestButton.Name = "AutoHarvestButton"
autoHarvestButton.Size = UDim2.new(0.8, 0, 0, 40)
autoHarvestButton.Position = UDim2.new(0.1, 0, 0, 210)
autoHarvestButton.BackgroundColor3 = colors.primary
autoHarvestButton.BorderSizePixel = 0
autoHarvestButton.Text = "Auto Harvest: OFF"
autoHarvestButton.TextColor3 = colors.text
autoHarvestButton.TextSize = 16
autoHarvestButton.Font = Enum.Font.GothamMedium
autoHarvestButton.Parent = mainFrame
autoHarvestButton.ZIndex = 400002
autoHarvestButton.ClipsDescendants = true

local autoHarvestCorner = Instance.new("UICorner")
autoHarvestCorner.CornerRadius = UDim.new(0, 10)
autoHarvestCorner.Parent = autoHarvestButton

local autoSellButton = Instance.new("TextButton")
autoSellButton.Name = "AutoSellButton"
autoSellButton.Size = UDim2.new(0.8, 0, 0, 40)
autoSellButton.Position = UDim2.new(0.1, 0, 0, 260)
autoSellButton.BackgroundColor3 = colors.primary
autoSellButton.BorderSizePixel = 0
autoSellButton.Text = "Auto Sell: OFF"
autoSellButton.TextColor3 = colors.text
autoSellButton.TextSize = 16
autoSellButton.Font = Enum.Font.GothamMedium
autoSellButton.Parent = mainFrame
autoSellButton.ZIndex = 400002
autoSellButton.ClipsDescendants = true

local autoSellCorner = Instance.new("UICorner")
autoSellCorner.CornerRadius = UDim.new(0, 10)
autoSellCorner.Parent = autoSellButton

local autoGearButton = Instance.new("TextButton")
autoGearButton.Name = "AutoGearButton"
autoGearButton.Size = UDim2.new(0.8, 0, 0, 40)
autoGearButton.Position = UDim2.new(0.1, 0, 0, 310)
autoGearButton.BackgroundColor3 = colors.primary
autoGearButton.BorderSizePixel = 0
autoGearButton.Text = "Auto Buy Gears: OFF"
autoGearButton.TextColor3 = colors.text
autoGearButton.TextSize = 16
autoGearButton.Font = Enum.Font.GothamMedium
autoGearButton.Parent = mainFrame
autoGearButton.ZIndex = 400002
autoGearButton.ClipsDescendants = true

local autoGearCorner = Instance.new("UICorner")
autoGearCorner.CornerRadius = UDim.new(0, 10)
autoGearCorner.Parent = autoGearButton

local autoCandyButton = Instance.new("TextButton")
autoCandyButton.Name = "AutoCandyButton"
autoCandyButton.Size = UDim2.new(0.8, 0, 0, 40)
autoCandyButton.Position = UDim2.new(0.1, 0, 0, 360)
autoCandyButton.BackgroundColor3 = colors.primary
autoCandyButton.BorderSizePixel = 0
autoCandyButton.Text = "Auto Buy Candy Blossom: OFF"
autoCandyButton.TextColor3 = colors.text
autoCandyButton.TextSize = 16
autoCandyButton.Font = Enum.Font.GothamMedium
autoCandyButton.Parent = mainFrame
autoCandyButton.ZIndex = 400002
autoCandyButton.ClipsDescendants = true

local autoCandyCorner = Instance.new("UICorner")
autoCandyCorner.CornerRadius = UDim.new(0, 10)
autoCandyCorner.Parent = autoCandyButton

createButtonEffect(autoBuyButton)
createButtonEffect(autoPlantButton)
createButtonEffect(autoHarvestButton)
createButtonEffect(autoSellButton)
createButtonEffect(autoGearButton)
createButtonEffect(autoCandyButton)
createButtonEffect(dropdownButton)

-- Зелёная иконка для открытия/закрытия
print("Создаём перетаскиваемую иконку") -- Отладка
local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.new(0, 50, 0, 50)
toggleButton.Position = UDim2.new(0.05, 0, 0.05, 0)
toggleButton.BackgroundColor3 = colors.accent
toggleButton.BorderSizePixel = 0
toggleButton.Text = "☰"
toggleButton.TextColor3 = colors.text
toggleButton.TextSize = 24
toggleButton.Font = Enum.Font.GothamBold
toggleButton.Parent = gui
toggleButton.ZIndex = 400020
toggleButton.ClipsDescendants = true

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(1, 0)
toggleCorner.Parent = toggleButton

createButtonEffect(toggleButton)
makeDraggable(toggleButton)

-- Функции для Grow a Garden
local autoBuyEnabled = false
local autoPlantEnabled = false
local autoHarvestEnabled = false
local autoSellEnabled = false
local autoGearEnabled = false
local autoCandyEnabled = false

local function getOwnedFarm()
    local farms = Workspace:WaitForChild("Farm", 20)
    if not farms then
        warn("Workspace.Farm не найден")
        showNotification("Ошибка: Workspace.Farm не найден", colors.error)
        return nil
    end
    for _, farm in ipairs(farms:GetChildren()) do
        local success, isOwned = pcall(function()
            return farm:FindFirstChild("Important") and farm.Important.Data.Owner.Value == player.Name
        end)
        if success and isOwned then
            print("Найдена ферма игрока: " .. farm.Name) -- Отладка
            return farm
        end
    end
    warn("Ферма игрока не найдена")
    showNotification("Ошибка: Ферма игрока не найдена", colors.error)
    return nil
end

local function findAllRemotes()
    print("Поиск всех RemoteEvent в игре") -- Отладка
    local remotes = {}
    
    -- Поиск в ReplicatedStorage
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            table.insert(remotes, {name = obj.Name, remote = obj, path = obj:GetFullName()})
            print("Найден RemoteEvent: " .. obj.Name .. " в " .. obj:GetFullName()) -- Отладка
        end
    end
    
    -- Поиск в Workspace
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            table.insert(remotes, {name = obj.Name, remote = obj, path = obj:GetFullName()})
            print("Найден RemoteEvent: " .. obj.Name .. " в " .. obj:GetFullName()) -- Отладка
        end
    end
    
    -- Поиск в Players
    for _, obj in pairs(Players:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            table.insert(remotes, {name = obj.Name, remote = obj, path = obj:GetFullName()})
            print("Найден RemoteEvent: " .. obj.Name .. " в " .. obj:GetFullName()) -- Отладка
        end
    end
    
    return remotes
end

local function checkRemotes()
    print("Проверка RemoteEvents") -- Отладка
    local gameEvents = ReplicatedStorage:FindFirstChild("GameEvents")
    local remotes = {}
    
    if gameEvents then
        remotes = {
            Purchase = gameEvents:FindFirstChild("Purchase") or gameEvents:FindFirstChild("BuySeed") or gameEvents:FindFirstChild("Buy") or gameEvents:FindFirstChild("PurchaseItem"),
            Plant = gameEvents:FindFirstChild("Plant") or gameEvents:FindFirstChild("PlantSeed") or gameEvents:FindFirstChild("Grow") or gameEvents:FindFirstChild("Sow"),
            SummerHarvestRemoteEvent = gameEvents:FindFirstChild("SummerHarvestRemoteEvent") or gameEvents:FindFirstChild("Harvest") or gameEvents:FindFirstChild("Collect") or gameEvents:FindFirstChild("Reap"),
            Sell = gameEvents:FindFirstChild("Sell") or gameEvents:FindFirstChild("SellCrops") or gameEvents:FindFirstChild("SellItems") or gameEvents:FindFirstChild("Trade"),
            PurchaseGear = gameEvents:FindFirstChild("PurchaseGear") or gameEvents:FindFirstChild("BuyGear") or gameEvents:FindFirstChild("Equip") or gameEvents:FindFirstChild("GearPurchase"),
            PurchaseEventItem = gameEvents:FindFirstChild("PurchaseEventItem") or gameEvents:FindFirstChild("BuyEventItem") or gameEvents:FindFirstChild("EventBuy") or gameEvents:FindFirstChild("EventPurchase")
        }
        for name, remote in pairs(remotes) do
            if not remote then
                warn(name .. " RemoteEvent не найден в GameEvents")
                showNotification("Ошибка: " .. name .. " не найден в GameEvents", colors.error)
            else
                print(name .. " RemoteEvent найден: " .. remote.Name .. " в " .. remote:GetFullName()) -- Отладка
            end
        end
    else
        warn("GameEvents не найден в ReplicatedStorage")
        showNotification("Ошибка: GameEvents не найден", colors.error)
    end
    
    -- Если основные RemoteEvent не найдены, ищем все RemoteEvent
    if not remotes.Purchase or not remotes.Plant or not remotes.SummerHarvestRemoteEvent or not remotes.Sell or not remotes.PurchaseGear or not remotes.PurchaseEventItem then
        print("Попытка найти альтернативные RemoteEvent") -- Отладка
        local allRemotes = findAllRemotes()
        
        -- Пробуем угадать RemoteEvent по сигнатурам
        for _, remoteInfo in ipairs(allRemotes) do
            local remote = remoteInfo.remote
            if not remotes.Purchase and remoteInfo.name:lower():find("buy") or remoteInfo.name:lower():find("purchase") then
                remotes.Purchase = remote
                print("Предполагаемый Purchase RemoteEvent: " .. remoteInfo.name .. " в " .. remoteInfo.path) -- Отладка
            elseif not remotes.Plant and remoteInfo.name:lower():find("plant") or remoteInfo.name:lower():find("grow") or remoteInfo.name:lower():find("sow") then
                remotes.Plant = remote
                print("Предполагаемый Plant RemoteEvent: " .. remoteInfo.name .. " в " .. remoteInfo.path) -- Отладка
            elseif not remotes.SummerHarvestRemoteEvent and remoteInfo.name:lower():find("harvest") or remoteInfo.name:lower():find("collect") or remoteInfo.name:lower():find("reap") then
                remotes.SummerHarvestRemoteEvent = remote
                print("Предполагаемый Harvest RemoteEvent: " .. remoteInfo.name .. " в " .. remoteInfo.path) -- Отладка
            elseif not remotes.Sell and remoteInfo.name:lower():find("sell") or remoteInfo.name:lower():find("trade") then
                remotes.Sell = remote
                print("Предполагаемый Sell RemoteEvent: " .. remoteInfo.name .. " в " .. remoteInfo.path) -- Отладка
            elseif not remotes.PurchaseGear and remoteInfo.name:lower():find("gear") or remoteInfo.name:lower():find("equip") then
                remotes.PurchaseGear = remote
                print("Предполагаемый PurchaseGear RemoteEvent: " .. remoteInfo.name .. " в " .. remoteInfo.path) -- Отладка
            elseif not remotes.PurchaseEventItem and remoteInfo.name:lower():find("event") or remoteInfo.name:lower():find("candy") then
                remotes.PurchaseEventItem = remote
                print("Предполагаемый PurchaseEventItem RemoteEvent: " .. remoteInfo.name .. " в " .. remoteInfo.path) -- Отладка
            end
        end
    end
    
    return remotes
end

local function autoBuy()
    local remotes = checkRemotes()
    local purchaseRemote = remotes.Purchase
    if not purchaseRemote then
        showNotification("Ошибка: Purchase RemoteEvent не найден", colors.error)
        return
    end
    while autoBuyEnabled do
        local success, err = pcall(function()
            purchaseRemote:FireServer(selectedSeed)
            print("Попытка купить семя: " .. selectedSeed .. " через " .. purchaseRemote.Name .. " в " .. purchaseRemote:GetFullName()) -- Отладка
        end)
        if not success then
            showNotification("AutoBuy ошибка: " .. tostring(err), colors.error)
            autoBuyEnabled = false
            autoBuyButton.Text = "Auto Buy Seeds: OFF"
            autoBuyButton.BackgroundColor3 = colors.primary
            warn("AutoBuy ошибка: " .. tostring(err))
            return
        end
        task.wait(20 + math.random(0, 5))
    end
end

local function autoPlant()
    local remotes = checkRemotes()
    local plantRemote = remotes.Plant
    if not plantRemote then
        showNotification("Ошибка: Plant RemoteEvent не найден", colors.error)
        return
    end
    while autoPlantEnabled do
        local success, err = pcall(function()
            local farm = getOwnedFarm()
            if not farm then
                error("Ферма не найдена")
            end
            for _, plot in ipairs(farm:GetChildren()) do
                if plot:IsA("Model") and plot:FindFirstChild("Plant") then
                    plantRemote:FireServer(plot, selectedSeed)
                    print("Попытка посадить: " .. selectedSeed .. " на " .. plot.Name .. " через " .. plantRemote.Name .. " в " .. plantRemote:GetFullName()) -- Отладка
                    task.wait(0.1)
                end
            end
        end)
        if not success then
            showNotification("AutoPlant ошибка: " .. tostring(err), colors.error)
            autoPlantEnabled = false
            autoPlantButton.Text = "Auto Plant: OFF"
            autoPlantButton.BackgroundColor3 = colors.primary
            warn("AutoPlant ошибка: " .. tostring(err))
            return
        end
        task.wait(12 + math.random(0, 4))
    end
end

local function autoHarvest()
    local remotes = checkRemotes()
    local harvestRemote = remotes.SummerHarvestRemoteEvent
    if not harvestRemote then
        showNotification("Ошибка: Harvest RemoteEvent не найден", colors.error)
        return
    end
    while autoHarvestEnabled do
        local success, err = pcall(function()
            local farm = getOwnedFarm()
            if not farm then
                error("Ферма не найдена")
            end
            for _, plot in ipairs(farm:GetChildren()) do
                if plot:IsA("Model") and plot:FindFirstChild("Plant") and plot.Plant:FindFirstChild("Growth") then
                    if plot.Plant.Growth.Value >= 100 then
                        harvestRemote:FireServer(plot)
                        print("Сбор урожая с: " .. plot.Name .. " через " .. harvestRemote.Name .. " в " .. harvestRemote:GetFullName()) -- Отладка
                        task.wait(0.1)
                    end
                end
            end
        end)
        if not success then
            showNotification("AutoHarvest ошибка: " .. tostring(err), colors.error)
            autoHarvestEnabled = false
            autoHarvestButton.Text = "Auto Harvest: OFF"
            autoHarvestButton.BackgroundColor3 = colors.primary
            warn("AutoHarvest ошибка: " .. tostring(err))
            return
        end
        task.wait(2 + math.random(0, 2))
    end
end

local function autoSell()
    local remotes = checkRemotes()
    local sellRemote = remotes.Sell
    if not sellRemote then
        showNotification("Ошибка: Sell RemoteEvent не найден", colors.error)
        return
    end
    while autoSellEnabled do
        local success, err = pcall(function()
            sellRemote:FireServer()
            print("Попытка продать урожай через " .. sellRemote.Name .. " в " .. sellRemote:GetFullName()) -- Отладка
        end)
        if not success then
            showNotification("AutoSell ошибка: " .. tostring(err), colors.error)
            autoSellEnabled = false
            autoSellButton.Text = "Auto Sell: OFF"
            autoSellButton.BackgroundColor3 = colors.primary
            warn("AutoSell ошибка: " .. tostring(err))
            return
        end
        task.wait(12 + math.random(0, 4))
    end
end

local function autoBuyGear()
    local remotes = checkRemotes()
    local gearRemote = remotes.PurchaseGear
    if not gearRemote then
        showNotification("Ошибка: PurchaseGear RemoteEvent не найден", colors.error)
        return
    end
    while autoGearEnabled do
        local success, err = pcall(function()
            gearRemote:FireServer("WateringCan") -- Пример покупки лейки
            print("Попытка купить снаряжение: WateringCan через " .. gearRemote.Name .. " в " .. gearRemote:GetFullName()) -- Отладка
        end)
        if not success then
            showNotification("AutoBuyGear ошибка: " .. tostring(err), colors.error)
            autoGearEnabled = false
            autoGearButton.Text = "Auto Buy Gears: OFF"
            autoGearButton.BackgroundColor3 = colors.primary
            warn("AutoBuyGear ошибка: " .. tostring(err))
            return
        end
        task.wait(20 + math.random(0, 5))
    end
end

local function autoBuyCandyBlossom()
    local remotes = checkRemotes()
    local eventItemRemote = remotes.PurchaseEventItem
    if not eventItemRemote then
        showNotification("Ошибка: PurchaseEventItem RemoteEvent не найден", colors.error)
        return
    end
    while autoCandyEnabled do
        local success, err = pcall(function()
            eventItemRemote:FireServer("CandyBlossom")
            print("Попытка купить Candy Blossom через " .. eventItemRemote.Name .. " в " .. eventItemRemote:GetFullName()) -- Отладка
        end)
        if not success then
            showNotification("AutoBuyCandy ошибка: " .. tostring(err), colors.error)
            autoCandyEnabled = false
            autoCandyButton.Text = "Auto Buy Candy Blossom: OFF"
            autoCandyButton.BackgroundColor3 = colors.primary
            warn("AutoBuyCandy ошибка: " .. tostring(err))
            return
        end
        task.wait(20 + math.random(0, 5))
    end
end

local function setSpeed()
    local speed = tonumber(speedTextBox.Text)
    if not speed then
        showNotification("Ошибка: Введите число (16-100)", colors.error)
        return
    end
    if speed < 16 or speed > 100 then
        showNotification("Ошибка: Скорость должна быть от 16 до 100", colors.error)
        return
    end
    local success, err = pcall(function()
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = speed
            showNotification("Скорость установлена: " .. speed, colors.success)
            print("Скорость установлена: " .. speed) -- Отладка
        else
            error("Humanoid не найден")
        end
    end)
    if not success then
        showNotification("Ошибка установки скорости: " .. tostring(err), colors.error)
        warn("Ошибка установки скорости: " .. tostring(err))
    end
end

-- Anti-AFK
local function antiAFK()
    print("Запуск Anti-AFK") -- Отладка
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
    task.wait(60)
end

-- Обработчики кнопок
autoBuyButton.MouseButton1Click:Connect(function()
    autoBuyEnabled = not autoBuyEnabled
    autoBuyButton.Text = "Auto Buy Seeds: " .. (autoBuyEnabled and "ON" or "OFF")
    autoBuyButton.BackgroundColor3 = autoBuyEnabled and colors.success or colors.primary
    showNotification("Auto Buy Seeds: " .. (autoBuyEnabled and "Включено" or "Выключено"), autoBuyEnabled and colors.success or colors.text)
    if autoBuyEnabled then
        coroutine.wrap(autoBuy)()
    end
end)

autoPlantButton.MouseButton1Click:Connect(function()
    autoPlantEnabled = not autoPlantEnabled
    autoPlantButton.Text = "Auto Plant: " .. (autoPlantEnabled and "ON" or "OFF")
    autoPlantButton.BackgroundColor3 = autoPlantEnabled and colors.success or colors.primary
    showNotification("Auto Plant: " .. (autoPlantEnabled and "Включено" or "Выключено"), autoPlantEnabled and colors.success or colors.text)
    if autoPlantEnabled then
        coroutine.wrap(autoPlant)()
    end
end)

autoHarvestButton.MouseButton1Click:Connect(function()
    autoHarvestEnabled = not autoHarvestEnabled
    autoHarvestButton.Text = "Auto Harvest: " .. (autoHarvestEnabled and "ON" or "OFF")
    autoHarvestButton.BackgroundColor3 = autoHarvestEnabled and colors.success or colors.primary
    showNotification("Auto Harvest: " .. (autoHarvestEnabled and "Включено" or "Выключено"), autoHarvestEnabled and colors.success or colors.text)
    if autoHarvestEnabled then
        coroutine.wrap(autoHarvest)()
    end
end)

autoSellButton.MouseButton1Click:Connect(function()
    autoSellEnabled = not autoSellEnabled
    autoSellButton.Text = "Auto Sell: " .. (autoSellEnabled and "ON" or "OFF")
    autoSellButton.BackgroundColor3 = autoSellEnabled and colors.success or colors.primary
    showNotification("Auto Sell: " .. (autoSellEnabled and "Включено" or "Выключено"), autoSellEnabled and colors.success or colors.text)
    if autoSellEnabled then
        coroutine.wrap(autoSell)()
    end
end)

autoGearButton.MouseButton1Click:Connect(function()
    autoGearEnabled = not autoGearEnabled
    autoGearButton.Text = "Auto Buy Gears: " .. (autoGearEnabled and "ON" or "OFF")
    autoGearButton.BackgroundColor3 = autoGearEnabled and colors.success or colors.primary
    showNotification("Auto Buy Gears: " .. (autoGearEnabled and "Включено" or "Выключено"), autoGearEnabled and colors.success or colors.text)
    if autoGearEnabled then
        coroutine.wrap(autoBuyGear)()
    end
end)

autoCandyButton.MouseButton1Click:Connect(function()
    autoCandyEnabled = not autoCandyEnabled
    autoCandyButton.Text = "Auto Buy Candy Blossom: " .. (autoCandyEnabled and "ON" or "OFF")
    autoCandyButton.BackgroundColor3 = autoCandyEnabled and colors.success or colors.primary
    showNotification("Auto Buy Candy Blossom: " .. (autoCandyEnabled and "Включено" or "Выключено"), autoCandyEnabled and colors.success or colors.text)
    if autoCandyEnabled then
        coroutine.wrap(autoBuyCandyBlossom)()
    end
end)

speedApplyButton.MouseButton1Click:Connect(setSpeed)

closeButton.MouseButton1Click:Connect(function()
    gui:Destroy()
    showNotification("Xefi Hub закрыт", colors.text)
end)

toggleButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
    showNotification("Xefi Hub: " .. (mainFrame.Visible and "Открыт" or "Скрыт"), colors.text)
end)

-- Оптимизация производительности
local lastOptimization = 0
RunService:BindToRenderStep("PerformanceOptimization", Enum.RenderPriority.Camera.Value + 1, function()
    if tick() - lastOptimization < 0.5 then return end
    lastOptimization = tick()
    pcall(function()
        local farm = getOwnedFarm()
        if farm then
            for _, part in ipairs(farm:GetDescendants()) do
                if part:IsA("BasePart") and part.Transparency < 1 and (part.Position - character.HumanoidRootPart.Position).Magnitude > 200 then
                    part.Transparency = 1
                end
            end
        end
    end)
end)

-- Запуск Anti-AFK
coroutine.wrap(function()
    while true do
        antiAFK()
        task.wait(60)
    end
end)()

showNotification("Xefi Hub загружен для Grow a Garden", colors.success)
print("Xefi Hub полностью загружен") -- Отладка
