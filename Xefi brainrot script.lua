-- Простой скрипт для My Singing Brainrot (автосбор ресурсов и базовая автоматизация)
-- Тестировать только в Roblox Studio или на частном сервере!
-- Используйте Krnl для инжекта

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- Настройки скрипта
local AUTO_COLLECT = true -- Включить автосбор ресурсов
local AUTO_INTERACT = false -- Включить автоматическое взаимодействие с объектами
local SPEED_BOOST = false -- Включить ускорение персонажа

-- Функция для автосбора ресурсов
local function autoCollectResources()
    while AUTO_COLLECT and wait(0.5) do
        -- Ищем объекты с ресурсами (замените "ResourcePart" на актуальное имя объектов в игре)
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Name == "ResourcePart" then
                -- Телепортируем игрока к ресурсу
                local humanoidRootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if humanoidRootPart then
                    humanoidRootPart.CFrame = obj.CFrame
                    -- Симулируем взаимодействие
                    fireclickdetector(obj:FindFirstChildOfClass("ClickDetector"))
                    wait(0.1)
                end
            end
        end
    end
end

-- Функция для ускорения персонажа
local function enableSpeedBoost()
    if SPEED_BOOST and player.Character then
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = 50 -- Устанавливаем скорость (стандарт 16)
        end
    end
end

-- Функция для автоматического взаимодействия с объектами
local function autoInteract()
    while AUTO_INTERACT and wait(0.5) do
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Name == "InteractablePart" then
                local clickDetector = obj:FindFirstChildOfClass("ClickDetector")
                if clickDetector then
                    fireclickdetector(clickDetector)
                    wait(0.1)
                end
            end
        end
    end
end

-- Создание простого GUI для управления
local function createGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "BrainrotGUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = player:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 200, 0, 150)
    frame.Position = UDim2.new(0.5, -100, 0.5, -75)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Draggable = true
    frame.Parent = screenGui

    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 10)
    uiCorner.Parent = frame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0.2, 0)
    title.BackgroundTransparency = 1
    title.Text = "My Singing Brainrot"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextScaled = true
    title.Parent = frame

    local toggleCollect = Instance.new("TextButton")
    toggleCollect.Size = UDim2.new(0.8, 0, 0.2, 0)
    toggleCollect.Position = UDim2.new(0.1, 0, 0.3, 0)
    toggleCollect.Text = "Toggle Auto-Collect: ON"
    toggleCollect.TextColor3 = Color3.new(1, 1, 1)
    toggleCollect.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    toggleCollect.Parent = frame

    local toggleInteract = Instance.new("TextButton")
    toggleInteract.Size = UDim2.new(0.8, 0, 0.2, 0)
    toggleInteract.Position = UDim2.new(0.1, 0, 0.6, 0)
    toggleInteract.Text = "Toggle Auto-Interact: OFF"
    toggleInteract.TextColor3 = Color3.new(1, 1, 1)
    toggleInteract.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    toggleInteract.Parent = frame

    toggleCollect.MouseButton1Click:Connect(function()
        AUTO_COLLECT = not AUTO_COLLECT
        toggleCollect.Text = "Toggle Auto-Collect: " .. (AUTO_COLLECT and "ON" or "OFF")
        if AUTO_COLLECT then
            spawn(autoCollectResources)
        end
    end)

    toggleInteract.MouseButton1Click:Connect(function()
        AUTO_INTERACT = not AUTO_INTERACT
        toggleInteract.Text = "Toggle Auto-Interact: " .. (AUTO_INTERACT and "ON" or "OFF")
        if AUTO_INTERACT then
            spawn(autoInteract)
        end
    end)
end

-- Инициализация скрипта
local function init()
    if SPEED_BOOST then
        enableSpeedBoost()
    end
    createGUI()
    if AUTO_COLLECT then
        spawn(autoCollectResources)
    end
    if AUTO_INTERACT then
        spawn(autoInteract)
    end
end

-- Запуск скрипта
init()

print("My Singing Brainrot Script Loaded!")
