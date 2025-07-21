-- XefiHubBrainrotV5 для Grow a Garden (PlaceId: 126884695634066)
-- Функции: Auto Buy, Auto Plant, Auto Harvest, Auto Sell, Speed
-- Красивое меню с анимацией и выпадающим списком растений
-- Безопасный код, без фризов, огород не пропадает
-- Discord: sahadowgame0.0

-- Сервисы
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")
local VirtualUser = game:GetService("VirtualUser")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local playerGui = player:WaitForChild("PlayerGui", 10)

if not character or not playerGui then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Ошибка",
        Text = "Персонаж или интерфейс не найдены",
        Duration = 5
    })
    return
end

-- Цвета
local colors = {
    background = Color3.fromRGB(30, 30, 35),
    button = Color3.fromRGB(50, 50, 60),
    buttonOn = Color3.fromRGB(0, 200, 0),
    text = Color3.fromRGB(255, 255, 255),
    error = Color3.fromRGB(200, 0, 0),
    success = Color3.fromRGB(0, 200, 0)
}

-- Уведомления
local function showNotification(text, color)
    local notification = Instance.new("Frame")
    notification.Size = UDim2.new(0, 200, 0, 40)
    notification.Position = UDim2.new(0.5, 0, 0.95, 0)
    notification.AnchorPoint = Vector2.new(0.5, 0.5)
    notification.BackgroundColor3 = colors.background
    notification.BackgroundTransparency = 0.3
    notification.Parent = game:GetService("CoreGui")
    notification.ZIndex = 3000

    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 6)
    uiCorner.Parent = notification

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(0.9, 0, 0.8, 0)
    textLabel.Position = UDim2.new(0.05, 0, 0.1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = text
    textLabel.TextColor3 = color or colors.text
    textLabel.TextSize = 12
    textLabel.Font = Enum.Font.Gotham
    textLabel.TextWrapped = true
    textLabel.Parent = notification
    textLabel.ZIndex = 3001

    TweenService:Create(notification, TweenInfo.new(0.3), {BackgroundTransparency = 0.3}):Play()
    task.wait(2)
    TweenService:Create(notification, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
    TweenService:Create(textLabel, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
    task.wait(0.3)
    notification:Destroy()
end

-- Эффект кнопок
local function createButtonEffect(button)
    local originalColor = button.BackgroundColor3
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(70, 70, 80)}):Play()
    end)
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = originalColor}):Play()
    end)
end

-- Перетаскивание
local function makeDraggable(frame)
    local dragging, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- UI
local gui = Instance.new("ScreenGui")
gui.Name = "XefiHubV5"
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.ResetOnSpawn = false
gui.Parent = game:GetService("CoreGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 200, 0, 250)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = colors.background
mainFrame.BackgroundTransparency = 0.2
mainFrame.Visible = false
mainFrame.Parent = gui
mainFrame.ZIndex = 3000

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = colors.button
title.Text = "Xefi Hub V5"
title.TextColor3 = colors.text
title.TextSize = 16
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame
title.ZIndex = 3001

-- Выпадающий список растений
local plants = {
    "Apple", "Avocado", "Bamboo", "Carrot", "Potato", "Strawberry", "Pumpkin", "Tomato", "Corn",
    "Coconut", "Cactus", "Pitaya", "Mango", "Grape", "Pepper", "Cocoa", "Cherry Blossom",
    "Durian", "Cranberry", "Lotus", "Eggplant", "Venus Flytrap", "Candy Blossom",
    "Lunar Mango", "Lunar Melon", "Hive Fruit", "Lumira"
}
local selectedPlant = "Candy Blossom"

local dropdownFrame = Instance.new("Frame")
dropdownFrame.Size = UDim2.new(0.9, 0, 0, 30)
dropdownFrame.Position = UDim2.new(0.05, 0, 0, 40)
dropdownFrame.BackgroundColor3 = colors.button
dropdownFrame.Parent = mainFrame
dropdownFrame.ZIndex = 3001

local dropdownButton = Instance.new("TextButton")
dropdownButton.Size = UDim2.new(1, 0, 1, 0)
dropdownButton.BackgroundTransparency = 1
dropdownButton.Text = "Растение: " .. selectedPlant
dropdownButton.TextColor3 = colors.text
dropdownButton.TextSize = 12
dropdownButton.Font = Enum.Font.Gotham
dropdownButton.Parent = dropdownFrame
dropdownButton.ZIndex = 3002
createButtonEffect(dropdownButton)

local dropdownList = Instance.new("Frame")
dropdownList.Size = UDim2.new(1, 0, 0, 100)
dropdownList.Position = UDim2.new(0, 0, 1, 5)
dropdownList.BackgroundColor3 = colors.background
dropdownList.BackgroundTransparency = 0.2
dropdownList.Visible = false
dropdownList.Parent = dropdownFrame
dropdownList.ZIndex = 3003

local dropdownListLayout = Instance.new("UIListLayout")
dropdownListLayout.SortOrder = Enum.SortOrder.LayoutOrder
dropdownListLayout.Padding = UDim.new(0, 5)
dropdownListLayout.Parent = dropdownList

local dropdownListScroll = Instance.new("ScrollingFrame")
dropdownListScroll.Size = UDim2.new(1, 0, 1, 0)
dropdownListScroll.BackgroundTransparency = 1
dropdownListScroll.ScrollBarThickness = 4
dropdownListScroll.Parent = dropdownList
dropdownListScroll.ZIndex = 3004
dropdownListScroll.CanvasSize = UDim2.new(0, 0, 0, #plants * 30)

for _, plant in ipairs(plants) do
    local plantButton = Instance.new("TextButton")
    plantButton.Size = UDim2.new(0.95, 0, 0, 25)
    plantButton.BackgroundColor3 = colors.button
    plantButton.Text = plant
    plantButton.TextColor3 = colors.text
    plantButton.TextSize = 12
    plantButton.Font = Enum.Font.Gotham
    plantButton.Parent = dropdownListScroll
    plantButton.ZIndex = 3005
    createButtonEffect(plantButton)
    plantButton.MouseButton1Click:Connect(function()
        selectedPlant = plant
        dropdownButton.Text = "Растение: " .. plant
        dropdownList.Visible = false
        showNotification("Выбрано: " .. plant, colors.success)
    end)
end

dropdownButton.MouseButton1Click:Connect(function()
    dropdownList.Visible = not dropdownList.Visible
    TweenService:Create(dropdownList, TweenInfo.new(0.2), {BackgroundTransparency = dropdownList.Visible and 0.2 or 1}):Play()
end)

local speedInput = Instance.new("TextBox")
speedInput.Size = UDim2.new(0.9, 0, 0, 30)
speedInput.Position = UDim2.new(0.05, 0, 0, 80)
speedInput.BackgroundColor3 = colors.button
speedInput.Text = "32"
speedInput.PlaceholderText = "Скорость (16-100)"
speedInput.TextColor3 = colors.text
speedInput.TextSize = 12
speedInput.Font = Enum.Font.Gotham
speedInput.Parent = mainFrame
speedInput.ZIndex = 3001

local speedButton = Instance.new("TextButton")
speedButton.Size = UDim2.new(0.9, 0, 0, 30)
speedButton.Position = UDim2.new(0.05, 0, 0, 120)
speedButton.BackgroundColor3 = colors.button
speedButton.Text = "Установить скорость"
speedButton.TextColor3 = colors.text
speedButton.TextSize = 12
speedButton.Font = Enum.Font.Gotham
speedButton.Parent = mainFrame
speedButton.ZIndex = 3001
createButtonEffect(speedButton)

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 40, 0, 40)
toggleButton.Position = UDim2.new(0.05, 0, 0.05, 0)
toggleButton.BackgroundColor3 = colors.buttonOn
toggleButton.Text = "☰"
toggleButton.TextColor3 = colors.text
toggleButton.TextSize = 20
toggleButton.Font = Enum.Font.GothamBold
toggleButton.Parent = gui
toggleButton.ZIndex = 3002
createButtonEffect(toggleButton)
makeDraggable(toggleButton)

toggleButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
    TweenService:Create(mainFrame, tweenInfo, {
        Size = mainFrame.Visible and UDim2.new(0, 200, 0, 250) or UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = mainFrame.Visible and 0.2 or 1
    }):Play()
    showNotification("Меню " .. (mainFrame.Visible and "открыто" or "закрыто"), colors.success)
end)

-- Логика игры
local autoBuyEnabled = false
local autoPlantEnabled = false
local autoHarvestEnabled = false
local autoSellEnabled = false
local sellPos = CFrame.new(90.08035, 0.98381, 3.02662)

local function getHumanoidRootPart()
    local char = player.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function teleportTo(position)
    local hrp = getHumanoidRootPart()
    if hrp then
        hrp.CFrame = position
        task.wait(0.1)
    else
        showNotification("Ошибка: Персонаж не найден", colors.error)
    end
end

local function getOwnedFarm()
    local farms = Workspace:WaitForChild("Farm", 5)
    if not farms then
        showNotification("Ошибка: Ферма не найдена", colors.error)
        return
    end
    for _, farm in ipairs(farms:GetChildren()) do
        if farm:FindFirstChild("Important") and farm.Important.Data.Owner.Value == player.Name then
            return farm
        end
    end
    showNotification("Ошибка: Ферма игрока не найдена", colors.error)
end

local function findRemote(namePatterns)
    for _, obj in pairs({ReplicatedStorage, Workspace, Players}) do
        for _, remote in ipairs(obj:GetDescendants()) do
            if remote:IsA("RemoteEvent") then
                for _, pattern in ipairs(namePatterns) do
                    if remote.Name:lower():find(pattern:lower()) then
                        return remote
                    end
                end
            end
        end
    end
    return nil
end

local function autoBuy()
    local purchaseRemote = findRemote({"Purchase", "Buy", "BuySeed"})
    while autoBuyEnabled do
        local success, err = pcall(function()
            if purchaseRemote then
                purchaseRemote:FireServer(selectedPlant)
            else
                local shopGui = playerGui:FindFirstChild("Shop") or playerGui:WaitForChild("Shop", 5)
                if shopGui then
                    local seedButton = shopGui:FindFirstChild(selectedPlant, true)
                    if seedButton then
                        fireclickdetector(seedButton:FindFirstChildOfClass("ClickDetector") or seedButton)
                    else
                        showNotification("Ошибка: Кнопка для " .. selectedPlant .. " не найдена", colors.error)
                    end
                end
            end
        end)
        if not success then
            showNotification("Auto Buy ошибка: " .. tostring(err), colors.error)
            autoBuyEnabled = false
            buttons.AutoBuy.Text = "Auto Buy: OFF"
            buttons.AutoBuy.BackgroundColor3 = colors.button
            return
        end
        task.wait(1)
    end
end

local function autoPlant()
    local plantRemote = findRemote({"Plant", "PlantSeed", "Grow"})
    while autoPlantEnabled do
        local success, err = pcall(function()
            local farm = getOwnedFarm()
            if not farm then error("Ферма не найдена") end
            for _, plot in ipairs(farm:GetChildren()) do
                if plot:IsA("Model") and plot:FindFirstChild("Plant") and not plot.Plant:FindFirstChild("Growth") then
                    teleportTo(plot.Plant.Position + Vector3.new(0, 5, 0))
                    if plantRemote then
                        plantRemote:FireServer(plot, selectedPlant)
                    else
                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                        task.wait(0.05)
                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                    end
                    task.wait(0.2)
                end
            end
        end)
        if not success then
            showNotification("Auto Plant ошибка: " .. tostring(err), colors.error)
            autoPlantEnabled = false
            buttons.AutoPlant.Text = "Auto Plant: OFF"
            buttons.AutoPlant.BackgroundColor3 = colors.button
            return
        end
        task.wait(0.5)
    end
end

local function autoHarvest()
    while autoHarvestEnabled do
        local success, err = pcall(function()
            local farm = getOwnedFarm()
            if not farm then error("Ферма не найдена") end
            for _, plot in ipairs(farm:GetChildren()) do
                if plot:IsA("Model") and plot:FindFirstChild("Plant") and plot.Plant:FindFirstChild("Growth") and plot.Plant.Growth.Value >= 100 then
                    teleportTo(plot.Plant.Position + Vector3.new(0, 5, 0))
                    for i = 1, 5 do
                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                        task.wait(0.05)
                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                        task.wait(0.2)
                        if not autoHarvestEnabled or not plot.Parent then break end
                    end
                end
            end
        end)
        if not success then
            showNotification("Auto Harvest ошибка: " .. tostring(err), colors.error)
            autoHarvestEnabled = false
            buttons.AutoHarvest.Text = "Auto Harvest: OFF"
            buttons.AutoHarvest.BackgroundColor3 = colors.button
            return
        end
        task.wait(0.3)
    end
end

local function autoSell()
    local sellRemote = findRemote({"Sell", "SellCrops", "Sell_Inventory"})
    while autoSellEnabled do
        local success, err = pcall(function()
            teleportTo(sellPos)
            task.wait(0.1)
            if sellRemote then
                sellRemote:FireServer()
            else
                for i = 1, 5 do
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                    task.wait(0.05)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                    task.wait(0.2)
                end
            end
        end)
        if not success then
            showNotification("Auto Sell ошибка: " .. tostring(err), colors.error)
            autoSellEnabled = false
            buttons.AutoSell.Text = "Auto Sell: OFF"
            buttons.AutoSell.BackgroundColor3 = colors.button
            return
        end
        task.wait(1)
    end
end

local function setSpeed()
    local speed = tonumber(speedInput.Text)
    if not speed or speed < 16 or speed > 100 then
        showNotification("Скорость должна быть 16-100", colors.error)
        return
    end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = speed
        showNotification("Скорость установлена: " .. speed, colors.success)
    else
        showNotification("Ошибка: Персонаж не найден", colors.error)
    end
end

-- Anti-AFK
task.spawn(function()
    while true do
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
        task.wait(60)
    end
end)

-- Кнопки
local buttons = {}
local function createButton(name, text, posY, func)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.new(0.9, 0, 0, 30)
    button.Position = UDim2.new(0.05, 0, 0, posY)
    button.BackgroundColor3 = colors.button
    button.Text = text .. ": OFF"
    button.TextColor3 = colors.text
    button.TextSize = 12
    button.Font = Enum.Font.Gotham
    button.Parent = mainFrame
    button.ZIndex = 3001
    createButtonEffect(button)
    button.MouseButton1Click:Connect(function()
        _G[name .. "Enabled"] = not _G[name .. "Enabled"]
        button.Text = text .. ": " .. (_G[name .. "Enabled"] and "ON" or "OFF")
        button.BackgroundColor3 = _G[name .. "Enabled"] and colors.buttonOn or colors.button
        showNotification(text .. ": " .. (_G[name .. "Enabled"] and "Включено" or "Выключено"), colors.success)
        if _G[name .. "Enabled"] then
            task.spawn(func)
        end
    end)
    buttons[name] = button
end

createButton("AutoBuy", "Auto Buy", 160, autoBuy)
createButton("AutoPlant", "Auto Plant", 195, autoPlant)
createButton("AutoHarvest", "Auto Harvest", 230, autoHarvest)
createButton("AutoSell", "Auto Sell", 265, autoSell)

speedButton.MouseButton1Click:Connect(setSpeed)

showNotification("Xefi Hub V5 загружен", colors.success)
