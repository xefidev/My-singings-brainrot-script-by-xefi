-- XefiHubBrainrotV4 для Grow a Garden (PlaceId: 126884695634066)
-- Функции: Auto Buy, Auto Plant, Auto Harvest, Auto Sell, Speed
-- Простое меню, без фризов, огород не пропадает
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
    background = Color3.fromRGB(40, 40, 45),
    button = Color3.fromRGB(70, 70, 80),
    buttonOn = Color3.fromRGB(0, 255, 0),
    text = Color3.fromRGB(255, 255, 255),
    error = Color3.fromRGB(255, 80, 80),
    success = Color3.fromRGB(0, 255, 0)
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
    notification.ZIndex = 2000

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
    textLabel.ZIndex = 2001

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
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(90, 90, 100)}):Play()
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
gui.Name = "XefiHubV4"
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.ResetOnSpawn = false
gui.Parent = game:GetService("CoreGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 180, 0, 200)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = colors.background
mainFrame.BackgroundTransparency = 0.2
mainFrame.Visible = false
mainFrame.Parent = gui
mainFrame.ZIndex = 2000

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 6)
uiCorner.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 25)
title.BackgroundColor3 = colors.button
title.Text = "Xefi Hub V4"
title.TextColor3 = colors.text
title.TextSize = 14
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame
title.ZIndex = 2001

local seedInput = Instance.new("TextBox")
seedInput.Size = UDim2.new(0.9, 0, 0, 25)
seedInput.Position = UDim2.new(0.05, 0, 0, 35)
seedInput.BackgroundColor3 = colors.button
seedInput.Text = "Candy Blossom"
seedInput.PlaceholderText = "Семя (Strawberry, Cranberry...)"
seedInput.TextColor3 = colors.text
seedInput.TextSize = 12
seedInput.Font = Enum.Font.Gotham
seedInput.Parent = mainFrame
seedInput.ZIndex = 2001

local speedInput = Instance.new("TextBox")
speedInput.Size = UDim2.new(0.9, 0, 0, 25)
speedInput.Position = UDim2.new(0.05, 0, 0, 65)
speedInput.BackgroundColor3 = colors.button
speedInput.Text = "32"
speedInput.PlaceholderText = "Скорость (16-100)"
speedInput.TextColor3 = colors.text
speedInput.TextSize = 12
speedInput.Font = Enum.Font.Gotham
speedInput.Parent = mainFrame
speedInput.ZIndex = 2001

local speedButton = Instance.new("TextButton")
speedButton.Size = UDim2.new(0.9, 0, 0, 25)
speedButton.Position = UDim2.new(0.05, 0, 0, 95)
speedButton.BackgroundColor3 = colors.button
speedButton.Text = "Установить скорость"
speedButton.TextColor3 = colors.text
speedButton.TextSize = 12
speedButton.Font = Enum.Font.Gotham
speedButton.Parent = mainFrame
speedButton.ZIndex = 2001
createButtonEffect(speedButton)

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 30, 0, 30)
toggleButton.Position = UDim2.new(0.05, 0, 0.05, 0)
toggleButton.BackgroundColor3 = colors.buttonOn
toggleButton.Text = "☰"
toggleButton.TextColor3 = colors.text
toggleButton.TextSize = 16
toggleButton.Font = Enum.Font.GothamBold
toggleButton.Parent = gui
toggleButton.ZIndex = 2002
createButtonEffect(toggleButton)
makeDraggable(toggleButton)

toggleButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
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
    if not purchaseRemote then
        showNotification("Ошибка: RemoteEvent для покупки не найден", colors.error)
        return
    end
    while autoBuyEnabled do
        local success, err = pcall(function()
            purchaseRemote:FireServer(seedInput.Text)
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
    if not plantRemote then
        showNotification("Ошибка: RemoteEvent для посадки не найден", colors.error)
        return
    end
    while autoPlantEnabled do
        local success, err = pcall(function()
            local farm = getOwnedFarm()
            if not farm then error("Ферма не найдена") end
            for _, plot in ipairs(farm:GetChildren()) do
                if plot:IsA("Model") and plot:FindFirstChild("Plant") and not plot.Plant:FindFirstChild("Growth") then
                    local hrp = getHumanoidRootPart()
                    if hrp and (hrp.Position - plot.Plant.Position).Magnitude < 10 then
                        plantRemote:FireServer(plot, seedInput.Text)
                        task.wait(0.1)
                    end
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
                        task.wait(0.15)
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
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                task.wait(0.05)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
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
    button.Size = UDim2.new(0.9, 0, 0, 25)
    button.Position = UDim2.new(0.05, 0, 0, posY)
    button.BackgroundColor3 = colors.button
    button.Text = text .. ": OFF"
    button.TextColor3 = colors.text
    button.TextSize = 12
    button.Font = Enum.Font.Gotham
    button.Parent = mainFrame
    button.ZIndex = 2001
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

createButton("AutoBuy", "Auto Buy", 125, autoBuy)
createButton("AutoPlant", "Auto Plant", 155, autoPlant)
createButton("AutoHarvest", "Auto Harvest", 185, autoHarvest)
createButton("AutoSell", "Auto Sell", 215, autoSell)

speedButton.MouseButton1Click:Connect(setSpeed)

showNotification("Xefi Hub V4 загружен", colors.success)
