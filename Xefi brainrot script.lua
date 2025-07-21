

-- Сервисы
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")
local VirtualUser = game:GetService("VirtualUser")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local playerGui = player:WaitForChild("PlayerGui", 50)

if not character or not playerGui then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Ошибка",
        Text = "Персонаж или PlayerGui не найдены",
        Duration = 5
    })
    return
end

-- Цвета
local colors = {
    background = Color3.fromRGB(35, 35, 40),
    button = Color3.fromRGB(60, 60, 70),
    buttonOn = Color3.fromRGB(100, 255, 100),
    text = Color3.fromRGB(255, 255, 255),
    error = Color3.fromRGB(255, 100, 100),
    success = Color3.fromRGB(100, 255, 100)
}

-- Уведомления
local function showNotification(text, color)
    local notification = Instance.new("Frame")
    notification.Size = UDim2.new(0, 250, 0, 50)
    notification.Position = UDim2.new(0.5, 0, 0.9, 0)
    notification.AnchorPoint = Vector2.new(0.5, 0.5)
    notification.BackgroundColor3 = colors.background
    notification.BackgroundTransparency = 0.3
    notification.Parent = game:GetService("CoreGui")
    notification.ZIndex = 1000

    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 8)
    uiCorner.Parent = notification

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(0.9, 0, 0.8, 0)
    textLabel.Position = UDim2.new(0.05, 0, 0.1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = text
    textLabel.TextColor3 = color or colors.text
    textLabel.TextSize = 14
    textLabel.Font = Enum.Font.Gotham
    textLabel.TextWrapped = true
    textLabel.Parent = notification
    textLabel.ZIndex = 1001

    TweenService:Create(notification, TweenInfo.new(0.3), {BackgroundTransparency = 0.3}):Play()
    task.wait(3)
    TweenService:Create(notification, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
    TweenService:Create(textLabel, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
    task.wait(0.3)
    notification:Destroy()
end

-- Эффект кнопок
local function createButtonEffect(button)
    local originalColor = button.BackgroundColor3
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(80, 80, 90)}):Play()
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
gui.Name = "XefiHubV3"
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.ResetOnSpawn = false
gui.Parent = game:GetService("CoreGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 200, 0, 300)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = colors.background
mainFrame.BackgroundTransparency = 0.2
mainFrame.Visible = false
mainFrame.Parent = gui
mainFrame.ZIndex = 1000

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = colors.button
title.Text = "Xefi Hub V3"
title.TextColor3 = colors.text
title.TextSize = 16
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame
title.ZIndex = 1001

local seedInput = Instance.new("TextBox")
seedInput.Size = UDim2.new(0.9, 0, 0, 30)
seedInput.Position = UDim2.new(0.05, 0, 0, 40)
seedInput.BackgroundColor3 = colors.button
seedInput.Text = "Candy Blossom"
seedInput.PlaceholderText = "Введите семя (Strawberry, Cranberry...)"
seedInput.TextColor3 = colors.text
seedInput.TextSize = 14
seedInput.Font = Enum.Font.Gotham
seedInput.Parent = mainFrame
seedInput.ZIndex = 1001

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 40, 0, 40)
toggleButton.Position = UDim2.new(0.05, 0, 0.05, 0)
toggleButton.BackgroundColor3 = colors.buttonOn
toggleButton.Text = "☰"
toggleButton.TextColor3 = colors.text
toggleButton.TextSize = 20
toggleButton.Font = Enum.Font.GothamBold
toggleButton.Parent = gui
toggleButton.ZIndex = 1002
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
local autoGearEnabled = false
local autoCandyEnabled = false
local infiniteSeedsEnabled = false
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
    local farms = Workspace:WaitForChild("Farm", 10)
    if not farms then return end
    for _, farm in ipairs(farms:GetChildren()) do
        if farm:FindFirstChild("Important") and farm.Important.Data.Owner.Value == player.Name then
            return farm
        end
    end
    showNotification("Ошибка: Ферма не найдена", colors.error)
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

local function getRemotes()
    return {
        Purchase = findRemote({"Purchase", "Buy", "BuySeed"}),
        Plant = findRemote({"Plant", "PlantSeed", "Grow"}),
        Harvest = findRemote({"Harvest", "SummerHarvestRemoteEvent", "Collect"}),
        Sell = findRemote({"Sell", "SellCrops", "Sell_Inventory"}),
        PurchaseGear = findRemote({"PurchaseGear", "BuyGear", "Equip"}),
        PurchaseEventItem = findRemote({"PurchaseEventItem", "BuyEventItem", "EventBuy"})
    }
end

local function spamEUntilFruitGone(fruit)
    if not fruit or not fruit.PrimaryPart then return end
    local fruitExists = true
    local conn = fruit.AncestryChanged:Connect(function(_, parent)
        if not parent then fruitExists = false end
    end)
    for i = 1, 10 do
        if not fruitExists then break end
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        task.wait(0.05)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
        task.wait(0.2)
    end
    conn:Disconnect()
end

local function autoBuy()
    local remotes = getRemotes()
    local purchaseRemote = remotes.Purchase
    if not purchaseRemote then
        showNotification("Ошибка: Purchase RemoteEvent не найден", colors.error)
        return
    end
    while autoBuyEnabled do
        local seed = seedInput.Text
        local success, err = pcall(function()
            if infiniteSeedsEnabled then
                purchaseRemote:FireServer(seed, 0)
            else
                purchaseRemote:FireServer(seed)
            end
        end)
        if not success then
            showNotification("Auto Buy ошибка: " .. tostring(err), colors.error)
            autoBuyEnabled = false
            buttons.AutoBuy.Text = "Auto Buy: OFF"
            buttons.AutoBuy.BackgroundColor3 = colors.button
            return
        end
        task.wait(2)
    end
end

local function autoPlant()
    local remotes = getRemotes()
    local plantRemote = remotes.Plant
    if not plantRemote then
        showNotification("Ошибка: Plant RemoteEvent не найден", colors.error)
        return
    end
    while autoPlantEnabled do
        local success, err = pcall(function()
            local farm = getOwnedFarm()
            if not farm then error("Ферма не найдена") end
            for _, plot in ipairs(farm:GetChildren()) do
                if plot:IsA("Model") and plot:FindFirstChild("Plant") and not plot.Plant:FindFirstChild("Growth") then
                    plantRemote:FireServer(plot, seedInput.Text)
                    task.wait(0.1)
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
        task.wait(1)
    end
end

local function autoHarvest()
    local remotes = getRemotes()
    local harvestRemote = remotes.Harvest
    if not harvestRemote then
        showNotification("Harvest RemoteEvent не найден, использую E", colors.error)
        while autoHarvestEnabled do
            local success, err = pcall(function()
                local farm = getOwnedFarm()
                if not farm then error("Ферма не найдена") end
                for _, plot in ipairs(farm:GetChildren()) do
                    if plot:IsA("Model") and plot:FindFirstChild("Plant") and plot.Plant:FindFirstChild("Growth") and plot.Plant.Growth.Value >= 100 then
                        teleportTo(plot.Plant.Position + Vector3.new(0, 5, 0))
                        spamEUntilFruitGone(plot.Plant)
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
            task.wait(0.5)
        end
        return
    end
    while autoHarvestEnabled do
        local success, err = pcall(function()
            local farm = getOwnedFarm()
            if not farm then error("Ферма не найдена") end
            for _, plot in ipairs(farm:GetChildren()) do
                if plot:IsA("Model") and plot:FindFirstChild("Plant") and plot.Plant:FindFirstChild("Growth") and plot.Plant.Growth.Value >= 100 then
                    harvestRemote:FireServer(plot)
                    task.wait(0.1)
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
        task.wait(0.5)
    end
end

local function autoSell()
    local remotes = getRemotes()
    local sellRemote = remotes.Sell
    if not sellRemote then
        showNotification("Ошибка: Sell RemoteEvent не найден", colors.error)
        return
    end
    while autoSellEnabled do
        local success, err = pcall(function()
            teleportTo(sellPos)
            task.wait(0.1)
            sellRemote:FireServer()
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

local function autoBuyGear()
    local remotes = getRemotes()
    local gearRemote = remotes.PurchaseGear
    if not gearRemote then
        showNotification("Ошибка: Gear RemoteEvent не найден", colors.error)
        return
    end
    while autoGearEnabled do
        local success, err = pcall(function()
            gearRemote:FireServer("WateringCan")
        end)
        if not success then
            showNotification("Auto Gear ошибка: " .. tostring(err), colors.error)
            autoGearEnabled = false
            buttons.AutoGear.Text = "Auto Gear: OFF"
            buttons.AutoGear.BackgroundColor3 = colors.button
            return
        end
        task.wait(2)
    end
end

local function autoBuyCandyBlossom()
    local remotes = getRemotes()
    local eventItemRemote = remotes.PurchaseEventItem
    if not eventItemRemote then
        showNotification("Ошибка: Event RemoteEvent не найден", colors.error)
        return
    end
    while autoCandyEnabled do
        local success, err = pcall(function()
            eventItemRemote:FireServer("CandyBlossom")
        end)
        if not success then
            showNotification("Auto Candy ошибка: " .. tostring(err), colors.error)
            autoCandyEnabled = false
            buttons.AutoCandy.Text = "Auto Candy: OFF"
            buttons.AutoCandy.BackgroundColor3 = colors.button
            return
        end
        task.wait(2)
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
            showNotification("Infinite Seeds ошибка: " .. tostring(err), colors.error)
            infiniteSeedsEnabled = false
            buttons.InfiniteSeeds.Text = "Infinite Seeds: OFF"
            buttons.InfiniteSeeds.BackgroundColor3 = colors.button
            return
        end
        task.wait(1)
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

-- Оптимизация
local lastOptimization = 0
RunService:BindToRenderStep("Optimize", Enum.RenderPriority.Camera.Value + 1, function()
    if tick() - lastOptimization < 2 then return end
    lastOptimization = tick()
    local farm = getOwnedFarm()
    if farm then
        for _, part in ipairs(farm:GetDescendants()) do
            if part:IsA("BasePart") and part.Transparency < 1 and (part.Position - getHumanoidRootPart().Position).Magnitude > 50 then
                part.Transparency = 1
            end
        end
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
    button.TextSize = 14
    button.Font = Enum.Font.Gotham
    button.Parent = mainFrame
    button.ZIndex = 1001
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

createButton("AutoBuy", "Auto Buy", 80, autoBuy)
createButton("AutoPlant", "Auto Plant", 120, autoPlant)
createButton("AutoHarvest", "Auto Harvest", 160, autoHarvest)
createButton("AutoSell", "Auto Sell", 200, autoSell)
createButton("AutoGear", "Auto Gear", 240, autoBuyGear)
createButton("AutoCandy", "Auto Candy", 280, autoBuyCandyBlossom)
createButton("InfiniteSeeds", "Infinite Seeds", 320, infiniteSeeds)

showNotification("Xefi Hub V3 загружен", colors.success)
