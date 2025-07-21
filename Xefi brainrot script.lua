local success, result = pcall(function()
    return game:HttpGet("https://raw.githubusercontent.com/xefidev/My-singings-brainrot-script-by-xefi/refs/heads/main/Xefi%20brainrot%20script.lua")
end)
if not success then
    warn("Ошибка загрузки Xefi Hub: " .. tostring(result))
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Xefi Hub Error",
        Text = "Не удалось загрузить Xefi Hub: " .. tostring(result),
        Duration = 5
    })
    success, result = pcall(function()
        return game:HttpGet("https://raw.githubusercontent.com/nootmaus/GrowAAGarden/refs/heads/main/mauscripts")
    end)
    if not success then
        warn("Ошибка загрузки альтернативного скрипта: " .. tostring(result))
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Xefi Hub Error",
            Text = "Не удалось загрузить альтернативный скрипт: " .. tostring(result),
            Duration = 5
        })
        return
    end
end

-- Проверка совместимости executor'а
local function checkExecutorCompatibility()
    local success, _ = pcall(function()
        return game:GetService("HttpService")
    end)
    if not success or not game:IsLoaded() then
        warn("Executor не поддерживает базовые функции или игра не загружена")
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Xefi Hub Error",
            Text = "Executor не поддерживает базовые функции или игра не загружена",
            Duration = 5
        })
        return false
    end
    print("Executor совместим, начинаем запуск Xefi Hub Brainrot V2") -- Отладка
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

-- Сервисы
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui", 50)
if not playerGui then
    warn("PlayerGui не найден")
    return
end
local character = player.Character or player.CharacterAdded:Wait()
if not character then
    warn("Персонаж не найден")
    return
end

-- Очистка сторонних UI
local systemGuis = {"RobloxGui", "HeadsetDisconnectedDialog", "CoreGuiPrompt", "TeleportGui"}
for _, existingGui in pairs(game:GetService("CoreGui"):GetChildren()) do
    if existingGui:IsA("ScreenGui") and not table.find(systemGuis, existingGui.Name) and existingGui.Name ~= "XefiHubUI" then
        pcall(function() existingGui:Destroy() end)
        print("Удалён ScreenGui: " .. existingGui.Name) -- Отладка
    end
end

-- UI
local gui = Instance.new("ScreenGui")
gui.Name = "XefiHubUI"
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.ResetOnSpawn = false
gui.DisplayOrder = 500000
gui.Parent = game:GetService("CoreGui")

local colors = {
    background = Color3.fromRGB(30, 30, 35),
    header = Color3.fromRGB(20, 20, 25),
    primary = Color3.fromRGB(50, 50, 60),
    accent = Color3.fromRGB(85, 255, 85),
    text = Color3.fromRGB(240, 240, 240),
    error = Color3.fromRGB(255, 85, 85),
    success = Color3.fromRGB(85, 255, 85),
    hover = Color3.fromRGB(70, 70, 80)
}

-- Уведомления
local function showNotification(text, color)
    color = color or colors.text
    print("Уведомление: " .. text) -- Отладка
    local notification = Instance.new("Frame")
    notification.Name = "Notification"
    notification.BackgroundColor3 = colors.background
    notification.BackgroundTransparency = 0.2
    notification.Size = UDim2.new(0.3, 0, 0.08, 0)
    notification.Position = UDim2.new(0.85, 0, 0.9, 0)
    notification.AnchorPoint = Vector2.new(0.5, 0.5)
    notification.Parent = gui
    notification.ZIndex = 500002

    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 10)
    uiCorner.Parent = notification

    local textLabel = Instance.new("TextLabel")
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
    textLabel.ZIndex = 500003

    local appearTween = TweenService:Create(notification, TweenInfo.new(0.4), {BackgroundTransparency = 0.2})
    local textAppearTween = TweenService:Create(textLabel, TweenInfo.new(0.4), {TextTransparency = 0})
    appearTween:Play()
    textAppearTween:Play()

    task.spawn(function()
        task.wait(3)
        local disappearTween = TweenService:Create(notification, TweenInfo.new(0.4), {BackgroundTransparency = 1})
        local textDisappearTween = TweenService:Create(textLabel, TweenInfo.new(0.4), {TextTransparency = 1})
        disappearTween:Play()
        textDisappearTween:Play()
        disappearTween.Completed:Wait()
        notification:Destroy()
    end)
end

-- Эффект кнопок
local function createButtonEffect(button)
    local originalSize = button.Size
    local originalPos = button.Position
    local originalColor = button.BackgroundColor3
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = colors.hover,
            Size = originalSize + UDim2.new(0, 5, 0, 5)
        }):Play()
    end)
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = originalColor,
            Size = originalSize
        }):Play()
    end)
    button.MouseButton1Down:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.1), {
            Size = originalSize - UDim2.new(0, 5, 0, 5),
            Position = originalPos + UDim2.new(0, 2.5, 0, 2.5)
        }):Play()
    end)
    button.MouseButton1Up:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.1), {
            Size = originalSize,
            Position = originalPos
        }):Play()
    end)
end

-- Перетаскивание
local function makeDraggable(frame)
    local dragging, dragStartPos, frameStartPos
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

-- Главное окно
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 320, 0, 700)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = colors.background
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = gui
mainFrame.ZIndex = 500000

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = mainFrame

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = colors.header
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame
titleBar.ZIndex = 500001

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -40, 1, 0)
titleLabel.Position = UDim2.new(0, 20, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Xefi Hub Brainrot V2 - Grow a Garden"
titleLabel.TextColor3 = colors.accent
titleLabel.TextSize = 18
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar
titleLabel.ZIndex = 500002

local closeButton = Instance.new("ImageButton")
closeButton.Size = UDim2.new(0, 24, 0, 24)
closeButton.Position = UDim2.new(1, -32, 0.5, -12)
closeButton.BackgroundTransparency = 1
closeButton.Image = "rbxassetid://3926305904"
closeButton.ImageColor3 = colors.text
closeButton.ImageRectOffset = Vector2.new(284, 4)
closeButton.ImageRectSize = Vector2.new(24, 24)
closeButton.Parent = titleBar
closeButton.ZIndex = 500003

-- Выпадающий список семян
local seedList = {
    "Apple", "Avocado", "Bamboo", "Carrot", "Potato", "Strawberry", "Pumpkin", "Tomato", "Corn",
    "Coconut", "Cactus", "Pitaya", "Mango", "Grape", "Pepper", "Cocoa",
    "Cherry Blossom", "Durian", "Cranberry", "Lotus", "Eggplant", "Venus Flytrap",
    "Candy Blossom", "Lunar Mango", "Lunar Melon", "Hive Fruit", "Lumira"
}
local selectedSeed = "Candy Blossom" -- По умолчанию

local dropdownFrame = Instance.new("Frame")
dropdownFrame.Size = UDim2.new(0.8, 0, 0, 40)
dropdownFrame.Position = UDim2.new(0.1, 0, 0, 60)
dropdownFrame.BackgroundColor3 = colors.primary
dropdownFrame.BorderSizePixel = 0
dropdownFrame.Parent = mainFrame
dropdownFrame.ZIndex = 500005

local dropdownButton = Instance.new("TextButton")
dropdownButton.Size = UDim2.new(1, 0, 1, 0)
dropdownButton.BackgroundTransparency = 1
dropdownButton.Text = "Seed: " .. selectedSeed
dropdownButton.TextColor3 = colors.text
dropdownButton.TextSize = 16
dropdownButton.Font = Enum.Font.GothamMedium
dropdownButton.Parent = dropdownFrame
dropdownButton.ZIndex = 500006

local dropdownList = Instance.new("Frame")
dropdownList.Size = UDim2.new(1, 0, 0, 150)
dropdownList.Position = UDim2.new(0, 0, 1, 5)
dropdownList.BackgroundColor3 = colors.background
dropdownList.BackgroundTransparency = 0.2
dropdownList.BorderSizePixel = 0
dropdownList.Visible = false
dropdownList.Parent = dropdownFrame
dropdownList.ZIndex = 500010

local dropdownListLayout = Instance.new("UIListLayout")
dropdownListLayout.SortOrder = Enum.SortOrder.LayoutOrder
dropdownListLayout.Padding = UDim.new(0, 5)
dropdownListLayout.Parent = dropdownList

for i, seed in ipairs(seedList) do
    local seedButton = Instance.new("TextButton")
    seedButton.Size = UDim2.new(1, -10, 0, 30)
    seedButton.Position = UDim2.new(0, 5, 0, 5)
    seedButton.BackgroundColor3 = colors.primary
    seedButton.Text = seed
    seedButton.TextColor3 = colors.text
    seedButton.TextSize = 14
    seedButton.Font = Enum.Font.GothamMedium
    seedButton.Parent = dropdownList
    seedButton.ZIndex = 500011

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
end)

-- Поля для задержек
local delays = {
    autoBuy = {min = 22, max = 27},
    autoPlant = {min = 14, max = 18},
    autoHarvest = {min = 2.5, max = 4.5},
    autoSell = {min = 14, max = 18},
    autoGear = {min = 22, max = 27},
    autoCandy = {min = 22, max = 27}
}

local function createDelayInput(name, positionY, defaultMin, defaultMax)
    local delayFrame = Instance.new("Frame")
    delayFrame.Size = UDim2.new(0.8, 0, 0, 40)
    delayFrame.Position = UDim2.new(0.1, 0, 0, positionY)
    delayFrame.BackgroundColor3 = colors.primary
    delayFrame.Parent = mainFrame
    delayFrame.ZIndex = 500005

    local minTextBox = Instance.new("TextBox")
    minTextBox.Size = UDim2.new(0.35, 0, 1, 0)
    minTextBox.Position = UDim2.new(0, 5, 0, 0)
    minTextBox.BackgroundTransparency = 1
    minTextBox.Text = tostring(defaultMin)
    minTextBox.PlaceholderText = "Min (0.1-60)"
    minTextBox.TextColor3 = colors.text
    minTextBox.TextSize = 14
    minTextBox.Font = Enum.Font.GothamMedium
    minTextBox.Parent = delayFrame
    minTextBox.ZIndex = 500006

    local maxTextBox = Instance.new("TextBox")
    maxTextBox.Size = UDim2.new(0.35, 0, 1, 0)
    maxTextBox.Position = UDim2.new(0.4, 0, 0, 0)
    maxTextBox.BackgroundTransparency = 1
    maxTextBox.Text = tostring(defaultMax)
    maxTextBox.PlaceholderText = "Max (0.1-60)"
    maxTextBox.TextColor3 = colors.text
    maxTextBox.TextSize = 14
    maxTextBox.Font = Enum.Font.GothamMedium
    maxTextBox.Parent = delayFrame
    maxTextBox.ZIndex = 500006

    local applyButton = Instance.new("TextButton")
    applyButton.Size = UDim2.new(0.2, 0, 1, 0)
    applyButton.Position = UDim2.new(0.8, 0, 0, 0)
    applyButton.BackgroundColor3 = colors.primary
    applyButton.Text = "Apply"
    applyButton.TextColor3 = colors.text
    applyButton.TextSize = 14
    applyButton.Font = Enum.Font.GothamMedium
    applyButton.Parent = delayFrame
    applyButton.ZIndex = 500006

    createButtonEffect(applyButton)
    applyButton.MouseButton1Click:Connect(function()
        local minDelay = tonumber(minTextBox.Text)
        local maxDelay = tonumber(maxTextBox.Text)
        if not minDelay or not maxDelay or minDelay < 0.1 or minDelay > 60 or maxDelay < 0.1 or maxDelay > 60 or minDelay > maxDelay then
            showNotification("Ошибка: Задержки 0.1-60 сек, min <= max", colors.error)
            return
        end
        delays[name].min = minDelay
        delays[name].max = maxDelay
        showNotification("Задержки для " .. name .. ": " .. minDelay .. "-" .. maxDelay .. " сек", colors.success)
    end)
end

-- Кнопки и поля
local buttons = {}
local function createButton(name, text, positionY, toggleFunc)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.new(0.8, 0, 0, 40)
    button.Position = UDim2.new(0.1, 0, 0, positionY)
    button.BackgroundColor3 = colors.primary
    button.Text = text .. ": OFF"
    button.TextColor3 = colors.text
    button.TextSize = 16
    button.Font = Enum.Font.GothamMedium
    button.Parent = mainFrame
    button.ZIndex = 500002
    buttons[name] = button
    createButtonEffect(button)
    button.MouseButton1Click:Connect(toggleFunc)
end

createDelayInput("autoBuy", 150, delays.autoBuy.min, delays.autoBuy.max)
createDelayInput("autoPlant", 240, delays.autoPlant.min, delays.autoPlant.max)
createDelayInput("autoHarvest", 330, delays.autoHarvest.min, delays.autoHarvest.max)
createDelayInput("autoSell", 420, delays.autoSell.min, delays.autoSell.max)
createDelayInput("autoGear", 510, delays.autoGear.min, delays.autoGear.max)
createDelayInput("autoCandy", 600, delays.autoCandy.min, delays.autoCandy.max)

-- Скорость
local speedFrame = Instance.new("Frame")
speedFrame.Size = UDim2.new(0.8, 0, 0, 40)
speedFrame.Position = UDim2.new(0.1, 0, 0, 560)
speedFrame.BackgroundColor3 = colors.primary
speedFrame.Parent = mainFrame
speedFrame.ZIndex = 500005

local speedTextBox = Instance.new("TextBox")
speedTextBox.Size = UDim2.new(0.7, 0, 1, 0)
speedTextBox.Position = UDim2.new(0, 5, 0, 0)
speedTextBox.BackgroundTransparency = 1
speedTextBox.Text = "32"
speedTextBox.PlaceholderText = "Скорость (16-100)"
speedTextBox.TextColor3 = colors.text
speedTextBox.TextSize = 16
speedTextBox.Font = Enum.Font.GothamMedium
speedTextBox.Parent = speedFrame
speedTextBox.ZIndex = 500006

local speedApplyButton = Instance.new("TextButton")
speedApplyButton.Size = UDim2.new(0.25, 0, 1, 0)
speedApplyButton.Position = UDim2.new(0.75, 0, 0, 0)
speedApplyButton.BackgroundColor3 = colors.primary
speedApplyButton.Text = "OK"
speedApplyButton.TextColor3 = colors.text
speedApplyButton.TextSize = 16
speedApplyButton.Font = Enum.Font.GothamMedium
speedApplyButton.Parent = speedFrame
speedApplyButton.ZIndex = 500006
createButtonEffect(speedApplyButton)

-- Иконка
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 50, 0, 50)
toggleButton.Position = UDim2.new(0.05, 0, 0.05, 0)
toggleButton.BackgroundColor3 = colors.accent
toggleButton.Text = "☰"
toggleButton.TextColor3 = colors.text
toggleButton.TextSize = 24
toggleButton.Font = Enum.Font.GothamBold
toggleButton.Parent = gui
toggleButton.ZIndex = 500020
createButtonEffect(toggleButton)
makeDraggable(toggleButton)

-- Логика игры
local autoBuyEnabled = false
local autoPlantEnabled = false
local autoHarvestEnabled = false
local autoSellEnabled = false
local autoGearEnabled = false
local autoCandyEnabled = false
local infiniteSeedsEnabled = false
local sellPos = CFrame.new(90.08035, 0.98381, 3.02662, 6e-05, 1e-06, 1, -0.0349, 0.999, 1e-06, -0.999, -0.0349, 6e-05)

local function getHumanoidRootPart()
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        return char.HumanoidRootPart
    end
    return nil
end

local function teleportTo(position)
    local hrp = getHumanoidRootPart()
    if hrp then
        hrp.CFrame = position
    else
        showNotification("Ошибка: Персонаж не найден", colors.error)
    end
end

local function getOwnedFarm()
    local farms = Workspace:WaitForChild("Farm", 20)
    if not farms then
        showNotification("Ошибка: Workspace.Farm не найден", colors.error)
        return nil
    end
    for _, farm in ipairs(farms:GetChildren()) do
        if farm:FindFirstChild("Important") and farm.Important.Data.Owner.Value == player.Name then
            return farm
        end
    end
    showNotification("Ошибка: Ферма игрока не найдена", colors.error)
    return nil
end

local function findAllRemotes()
    local remotes = {}
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            table.insert(remotes, {name = obj.Name, remote = obj, path = obj:GetFullName()})
        end
    end
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            table.insert(remotes, {name = obj.Name, remote = obj, path = obj:GetFullName()})
        end
    end
    for _, obj in pairs(Players:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            table.insert(remotes, {name = obj.Name, remote = obj, path = obj:GetFullName()})
        end
    end
    return remotes
end

local function checkRemotes()
    local gameEvents = ReplicatedStorage:FindFirstChild("GameEvents")
    local remotes = {
        Purchase = nil,
        Plant = nil,
        SummerHarvestRemoteEvent = nil,
        Sell = nil,
        PurchaseGear = nil,
        PurchaseEventItem = nil
    }

    if gameEvents then
        remotes.Purchase = gameEvents:FindFirstChild("Purchase") or gameEvents:FindFirstChild("BuySeed") or gameEvents:FindFirstChild("Buy")
        remotes.Plant = gameEvents:FindFirstChild("Plant") or gameEvents:FindFirstChild("PlantSeed") or gameEvents:FindFirstChild("Grow")
        remotes.SummerHarvestRemoteEvent = gameEvents:FindFirstChild("SummerHarvestRemoteEvent") or gameEvents:FindFirstChild("Harvest") or gameEvents:FindFirstChild("Collect")
        remotes.Sell = gameEvents:FindFirstChild("Sell") or gameEvents:FindFirstChild("SellCrops") or gameEvents:FindFirstChild("Sell_Inventory")
        remotes.PurchaseGear = gameEvents:FindFirstChild("PurchaseGear") or gameEvents:FindFirstChild("BuyGear") or gameEvents:FindFirstChild("Equip")
        remotes.PurchaseEventItem = gameEvents:FindFirstChild("PurchaseEventItem") or gameEvents:FindFirstChild("BuyEventItem") or gameEvents:FindFirstChild("EventBuy")
    end

    if not remotes.Purchase or not remotes.Plant or not remotes.SummerHarvestRemoteEvent or not remotes.Sell or not remotes.PurchaseGear or not remotes.PurchaseEventItem then
        local allRemotes = findAllRemotes()
        for _, remoteInfo in ipairs(allRemotes) do
            local remote = remoteInfo.remote
            if not remotes.Purchase and remoteInfo.name:lower():find("buy") then
                remotes.Purchase = remote
            elseif not remotes.Plant and remoteInfo.name:lower():find("plant") then
                remotes.Plant = remote
            elseif not remotes.SummerHarvestRemoteEvent and remoteInfo.name:lower():find("harvest") then
                remotes.SummerHarvestRemoteEvent = remote
            elseif not remotes.Sell and remoteInfo.name:lower():find("sell") then
                remotes.Sell = remote
            elseif not remotes.PurchaseGear and remoteInfo.name:lower():find("gear") then
                remotes.PurchaseGear = remote
            elseif not remotes.PurchaseEventItem and remoteInfo.name:lower():find("event") then
                remotes.PurchaseEventItem = remote
            end
        end
    end

    for name, remote in pairs(remotes) do
        if not remote then
            showNotification("Ошибка: " .. name .. " не найден", colors.error)
        else
            print(name .. " найден: " .. remote:GetFullName()) -- Отладка
        end
    end
    return remotes
end

local function spamEUntilFruitGone(fruit)
    if not fruit or not fruit.PrimaryPart then
        return
    end
    local fruitExists = true
    local conn = fruit.AncestryChanged:Connect(function(_, parent)
        if not parent then
            fruitExists = false
        end
    end)
    while fruitExists and autoHarvestEnabled do
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        task.wait(0.05)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
        task.wait(0.1)
    end
    conn:Disconnect()
end

local function autoBuy()
    local remotes = checkRemotes()
    local purchaseRemote = remotes.Purchase
    if not purchaseRemote then
        return
    end
    while autoBuyEnabled do
        local success, err = pcall(function()
            if infiniteSeedsEnabled then
                -- Пропускаем проверку денег
                purchaseRemote:FireServer(selectedSeed, 0)
            else
                purchaseRemote:FireServer(selectedSeed)
            end
        end)
        if not success then
            showNotification("AutoBuy ошибка: " .. tostring(err), colors.error)
            autoBuyEnabled = false
            buttons.AutoBuyButton.Text = "Auto Buy Seeds: OFF"
            buttons.AutoBuyButton.BackgroundColor3 = colors.primary
            return
        end
        task.wait(delays.autoBuy.min + math.random(0, (delays.autoBuy.max - delays.autoBuy.min) * 1000) / 1000)
    end
end

local function autoPlant()
    local remotes = checkRemotes()
    local plantRemote = remotes.Plant
    if not plantRemote then
        return
    end
    while autoPlantEnabled do
        local success, err = pcall(function()
            local farm = getOwnedFarm()
            if not farm then
                error("Ферма не найдена")
            end
            for _, plot in ipairs(farm:GetChildren()) do
                if plot:IsA("Model") and plot:FindFirstChild("Plant") and not plot.Plant:FindFirstChild("Growth") then
                    plantRemote:FireServer(plot, selectedSeed)
                    task.wait(0.1)
                end
            end
        end)
        if not success then
            showNotification("AutoPlant ошибка: " .. tostring(err), colors.error)
            autoPlantEnabled = false
            buttons.AutoPlantButton.Text = "Auto Plant: OFF"
            buttons.AutoPlantButton.BackgroundColor3 = colors.primary
            return
        end
        task.wait(delays.autoPlant.min + math.random(0, (delays.autoPlant.max - delays.autoPlant.min) * 1000) / 1000)
    end
end

local function autoHarvest()
    local remotes = checkRemotes()
    local harvestRemote = remotes.SummerHarvestRemoteEvent
    if not harvestRemote then
        showNotification("Harvest RemoteEvent не найден, использую эмуляцию E", colors.error)
        while autoHarvestEnabled do
            local success, err = pcall(function()
                local farm = getOwnedFarm()
                if not farm then
                    error("Ферма не найдена")
                end
                for _, plot in ipairs(farm:GetChildren()) do
                    if plot:IsA("Model") and plot:FindFirstChild("Plant") and plot.Plant:FindFirstChild("Growth") and plot.Plant.Growth.Value >= 100 then
                        teleportTo(plot.Plant.Position + Vector3.new(0, 5, 0))
                        spamEUntilFruitGone(plot.Plant)
                        task.wait(0.1)
                    end
                end
            end)
            if not success then
                showNotification("AutoHarvest ошибка: " .. tostring(err), colors.error)
                autoHarvestEnabled = false
                buttons.AutoHarvestButton.Text = "Auto Harvest: OFF"
                buttons.AutoHarvestButton.BackgroundColor3 = colors.primary
                return
            end
            task.wait(delays.autoHarvest.min + math.random(0, (delays.autoHarvest.max - delays.autoHarvest.min) * 1000) / 1000)
        end
        return
    end
    while autoHarvestEnabled do
        local success, err = pcall(function()
            local farm = getOwnedFarm()
            if not farm then
                error("Ферма не найдена")
            end
            for _, plot in ipairs(farm:GetChildren()) do
                if plot:IsA("Model") and plot:FindFirstChild("Plant") and plot.Plant:FindFirstChild("Growth") and plot.Plant.Growth.Value >= 100 then
                    harvestRemote:FireServer(plot)
                    task.wait(0.1)
                end
            end
        end)
        if not success then
            showNotification("AutoHarvest ошибка: " .. tostring(err), colors.error)
            autoHarvestEnabled = false
            buttons.AutoHarvestButton.Text = "Auto Harvest: OFF"
            buttons.AutoHarvestButton.BackgroundColor3 = colors.primary
            return
        end
        task.wait(delays.autoHarvest.min + math.random(0, (delays.autoHarvest.max - delays.autoHarvest.min) * 1000) / 1000)
    end
end

local function autoSell()
    local remotes = checkRemotes()
    local sellRemote = remotes.Sell
    if not sellRemote then
        return
    end
    while autoSellEnabled do
        local success, err = pcall(function()
            local origCFrame = getHumanoidRootPart().CFrame
            teleportTo(sellPos)
            task.wait(0.1)
            sellRemote:FireServer()
            task.wait(0.1)
            teleportTo(origCFrame)
        end)
        if not success then
            showNotification("AutoSell ошибка: " .. tostring(err), colors.error)
            autoSellEnabled = false
            buttons.AutoSellButton.Text = "Auto Sell: OFF"
            buttons.AutoSellButton.BackgroundColor3 = colors.primary
            return
        end
        task.wait(delays.autoSell.min + math.random(0, (delays.autoSell.max - delays.autoSell.min) * 1000) / 1000)
    end
end

local function autoBuyGear()
    local remotes = checkRemotes()
    local gearRemote = remotes.PurchaseGear
    if not gearRemote then
        return
    end
    while autoGearEnabled do
        local success, err = pcall(function()
            gearRemote:FireServer("WateringCan")
        end)
        if not success then
            showNotification("AutoBuyGear ошибка: " .. tostring(err), colors.error)
            autoGearEnabled = false
            buttons.AutoGearButton.Text = "Auto Buy Gears: OFF"
            buttons.AutoGearButton.BackgroundColor3 = colors.primary
            return
        end
        task.wait(delays.autoGear.min + math.random(0, (delays.autoGear.max - delays.autoGear.min) * 1000) / 1000)
    end
end

local function autoBuyCandyBlossom()
    local remotes = checkRemotes()
    local eventItemRemote = remotes.PurchaseEventItem
    if not eventItemRemote then
        return
    end
    while autoCandyEnabled do
        local success, err = pcall(function()
            eventItemRemote:FireServer("CandyBlossom")
        end)
        if not success then
            showNotification("AutoBuyCandy ошибка: " .. tostring(err), colors.error)
            autoCandyEnabled = false
            buttons.AutoCandyButton.Text = "Auto Buy Candy Blossom: OFF"
            buttons.AutoCandyButton.BackgroundColor3 = colors.primary
            return
        end
        task.wait(delays.autoCandy.min + math.random(0, (delays.autoCandy.max - delays.autoCandy.min) * 1000) / 1000)
    end
end

local function infiniteSeeds()
    while infiniteSeedsEnabled do
        local success, err = pcall(function()
            local leaderstats = player:FindFirstChild("leaderstats")
            if leaderstats and leaderstats:FindFirstChild("Money") then
                leaderstats.Money.Value = 999999999
            end
        end)
        if not success then
            showNotification("InfiniteSeeds ошибка: " .. tostring(err), colors.error)
            infiniteSeedsEnabled = false
            buttons.InfiniteSeedsButton.Text = "Infinite Seeds: OFF"
            buttons.InfiniteSeedsButton.BackgroundColor3 = colors.primary
            return
        end
        task.wait(1)
    end
end

local function setSpeed()
    local speed = tonumber(speedTextBox.Text)
    if not speed or speed < 16 or speed > 100 then
        showNotification("Ошибка: Скорость 16-100", colors.error)
        return
    end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = speed
        showNotification("Скорость: " .. speed, colors.success)
    end
end

-- Anti-AFK
coroutine.wrap(function()
    while true do
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
        task.wait(60)
    end
end)()

-- Оптимизация
local lastOptimization = 0
local function optimizePerformance()
    if tick() - lastOptimization < 1.5 then return end
    lastOptimization = tick()
    local farm = getOwnedFarm()
    if farm then
        for _, part in ipairs(farm:GetDescendants()) do
            if part:IsA("BasePart") and part.Transparency < 1 and (part.Position - character.HumanoidRootPart.Position).Magnitude > 100 then
                part.Transparency = 1
            end
        end
    end
end
RunService:BindToRenderStep("PerformanceOptimization", Enum.RenderPriority.Camera.Value + 1, optimizePerformance)

-- Кнопки
createButton("AutoBuyButton", "Auto Buy Seeds", 110, function()
    autoBuyEnabled = not autoBuyEnabled
    buttons.AutoBuyButton.Text = "Auto Buy Seeds: " .. (autoBuyEnabled and "ON" or "OFF")
    buttons.AutoBuyButton.BackgroundColor3 = autoBuyEnabled and colors.success or colors.primary
    showNotification("Auto Buy Seeds: " .. (autoBuyEnabled and "Включено" or "Выключено"), colors.success)
    if autoBuyEnabled then
        task.spawn(autoBuy)
    end
end)

createButton("AutoPlantButton", "Auto Plant", 200, function()
    autoPlantEnabled = not autoPlantEnabled
    buttons.AutoPlantButton.Text = "Auto Plant: " .. (autoPlantEnabled and "ON" or "OFF")
    buttons.AutoPlantButton.BackgroundColor3 = autoPlantEnabled and colors.success or colors.primary
    showNotification("Auto Plant: " .. (autoPlantEnabled and "Включено" or "Выключено"), colors.success)
    if autoPlantEnabled then
        task.spawn(autoPlant)
    end
end)

createButton("AutoHarvestButton", "Auto Harvest", 290, function()
    autoHarvestEnabled = not autoHarvestEnabled
    buttons.AutoHarvestButton.Text = "Auto Harvest: " .. (autoHarvestEnabled and "ON" or "OFF")
    buttons.AutoHarvestButton.BackgroundColor3 = autoHarvestEnabled and colors.success or colors.primary
    showNotification("Auto Harvest: " .. (autoHarvestEnabled and "Включено" or "Выключено"), colors.success)
    if autoHarvestEnabled then
        task.spawn(autoHarvest)
    end
end)

createButton("AutoSellButton", "Auto Sell", 380, function()
    autoSellEnabled = not autoSellEnabled
    buttons.AutoSellButton.Text = "Auto Sell: " .. (autoSellEnabled and "ON" or "OFF")
    buttons.AutoSellButton.BackgroundColor3 = autoSellEnabled and colors.success or colors.primary
    showNotification("Auto Sell: " .. (autoSellEnabled and "Включено" or "Выключено"), colors.success)
    if autoSellEnabled then
        task.spawn(autoSell)
    end
end)

createButton("AutoGearButton", "Auto Buy Gears", 470, function()
    autoGearEnabled = not autoGearEnabled
    buttons.AutoGearButton.Text = "Auto Buy Gears: " .. (autoGearEnabled and "ON" or "OFF")
    buttons.AutoGearButton.BackgroundColor3 = autoGearEnabled and colors.success or colors.primary
    showNotification("Auto Buy Gears: " .. (autoGearEnabled and "Включено" or "Выключено"), colors.success)
    if autoGearEnabled then
        task.spawn(autoBuyGear)
    end
end)

createButton("AutoCandyButton", "Auto Buy Candy Blossom", 560, function()
    autoCandyEnabled = not autoCandyEnabled
    buttons.AutoCandyButton.Text = "Auto Buy Candy Blossom: " .. (autoCandyEnabled and "ON" or "OFF")
    buttons.AutoCandyButton.BackgroundColor3 = autoCandyEnabled and colors.success or colors.primary
    showNotification("Auto Buy Candy Blossom: " .. (autoCandyEnabled and "Включено" or "Выключено"), colors.success)
    if autoCandyEnabled then
        task.spawn(autoBuyCandyBlossom)
    end
end)

createButton("InfiniteSeedsButton", "Infinite Seeds", 650, function()
    infiniteSeedsEnabled = not infiniteSeedsEnabled
    buttons.InfiniteSeedsButton.Text = "Infinite Seeds: " .. (infiniteSeedsEnabled and "ON" or "OFF")
    buttons.InfiniteSeedsButton.BackgroundColor3 = infiniteSeedsEnabled and colors.success or colors.primary
    showNotification("Infinite Seeds: " .. (infiniteSeedsEnabled and "Включено" or "Выключено"), colors.success)
    if infiniteSeedsEnabled then
        task.spawn(infiniteSeeds)
    end
end)

speedApplyButton.MouseButton1Click:Connect(setSpeed)
closeButton.MouseButton1Click:Connect(function()
    gui:Destroy()
    RunService:UnbindFromRenderStep("PerformanceOptimization")
    showNotification("Xefi Hub закрыт", colors.text)
end)
toggleButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
    showNotification("Xefi Hub: " .. (mainFrame.Visible and "Открыт" or "Скрыт"), colors.text)
end)

showNotification("Xefi Hub Brainrot V2 загружен", colors.success)
