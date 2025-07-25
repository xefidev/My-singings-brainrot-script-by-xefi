local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local player = Players.LocalPlayer

-- Проверка PlayerGui
print("🔍 Проверка интерфейса игрока...")
local playerGui = player:WaitForChild("PlayerGui", 30)
if not playerGui then
    warn("🚫 Ошибка: PlayerGui недоступен")
    return
end
print("✅ PlayerGui найден")

-- Создание ScreenGui
print("🛠️ Создание интерфейса...")
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BrainrotHubUltra"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui
print("✅ Интерфейс создан")

-- Кнопка открытия меню (перемещаемая)
print("🔧 Настройка кнопки меню...")
local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.new(0, 70, 0, 70)
toggleButton.Position = UDim2.new(0.95, -70, 0.05, 0)
toggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40) -- Темно-серый фон
toggleButton.Text = "🧠 Меню"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255) -- Белый текст
toggleButton.Font = Enum.Font.Legacy -- Дефолтный шрифт Roblox
toggleButton.TextSize = 20
toggleButton.TextStrokeTransparency = 1 -- Без обводки
toggleButton.Active = true
toggleButton.Draggable = true
toggleButton.Parent = screenGui
local uiCornerToggle = Instance.new("UICorner")
uiCornerToggle.CornerRadius = UDim.new(0.3, 0)
uiCornerToggle.Parent = toggleButton

-- Кнопка для принудительного ESP (перемещаемая)
local forceEspButton = Instance.new("TextButton")
forceEspButton.Name = "ForceEspButton"
forceEspButton.Size = UDim2.new(0, 70, 0, 70)
forceEspButton.Position = UDim2.new(0.95, -70, 0.15, 0)
forceEspButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
forceEspButton.Text = "👁️ ESP"
forceEspButton.TextColor3 = Color3.fromRGB(255, 255, 255)
forceEspButton.Font = Enum.Font.Legacy
forceEspButton.TextSize = 20
forceEspButton.TextStrokeTransparency = 1
forceEspButton.Active = true
forceEspButton.Draggable = true
forceEspButton.Parent = screenGui
local uiCornerForceEsp = Instance.new("UICorner")
uiCornerForceEsp.CornerRadius = UDim.new(0.3, 0)
uiCornerForceEsp.Parent = forceEspButton

-- Основное окно меню
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 160, 0, 160) -- Увеличено для двух спидхаков
mainFrame.Position = UDim2.new(0.5, -80, 0.5, -80)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30) -- Темный фон
mainFrame.BackgroundTransparency = 0.2 -- Легкая прозрачность
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Visible = false
mainFrame.Parent = screenGui
local uiCornerMain = Instance.new("UICorner")
uiCornerMain.CornerRadius = UDim.new(0.15, 0)
uiCornerMain.Parent = mainFrame
print("✅ Меню создано")

-- Анимация открытия меню (сохранена)
local function animateMenu(show)
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local goal = show and {
        Size = UDim2.new(0, 320, 0, 320)
    } or {
        Size = UDim2.new(0, 160, 0, 160)
    }
    local tween = TweenService:Create(mainFrame, tweenInfo, goal)
    tween:Play()
end

-- Панель вкладок
local tabButtons = Instance.new("Frame")
tabButtons.Name = "TabButtons"
tabButtons.Size = UDim2.new(1, 0, 0, 30)
tabButtons.BackgroundTransparency = 1
tabButtons.Parent = mainFrame
local uiListLayout = Instance.new("UIListLayout")
uiListLayout.FillDirection = Enum.FillDirection.Horizontal
uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
uiListLayout.Parent = tabButtons

-- Создание вкладок
local tabs = {"Функции", "Серверы"}
local tabFrames = {}
local currentTab = "Функции"
for i, tabName in ipairs(tabs) do
    local button = Instance.new("TextButton")
    button.Name = tabName .. "Button"
    button.Size = UDim2.new(0, 90, 0, 25)
    button.Text = tabName
    button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.Legacy
    button.TextSize = 20
    button.TextStrokeTransparency = 1
    button.Parent = tabButtons
    local uiCornerBtn = Instance.new("UICorner")
    uiCornerBtn.CornerRadius = UDim.new(0.2, 0)
    uiCornerBtn.Parent = button
    button.MouseButton1Click:Connect(function()
        currentTab = tabName
        for _, frame in pairs(tabFrames) do
            frame.Visible = false
        end
        tabFrames[tabName].Visible = true
        print("🔄 Вкладка: " .. tabName)
    end)

    local frame = Instance.new("Frame")
    frame.Name = tabName .. "Frame"
    frame.Size = UDim2.new(1, 0, 1, -30)
    frame.Position = UDim2.new(0, 0, 0, 30)
    frame.BackgroundTransparency = 1
    frame.Visible = (tabName == "Функции")
    frame.Parent = mainFrame
    tabFrames[tabName] = frame
end

-- Вспомогательные функции
local function createToggle(name, yPos, parent, callback)
    print("🛠️ Создание переключателя: " .. name)
    local toggle = Instance.new("TextButton")
    toggle.Name = name .. "Toggle"
    toggle.Size = UDim2.new(0, 140, 0, 35)
    toggle.Position = UDim2.new(0, 10, 0, yPos)
    toggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    toggle.Text = name
    toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggle.Font = Enum.Font.Legacy
    toggle.TextSize = 20
    toggle.TextStrokeTransparency = 1
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0.2, 0)
    uiCorner.Parent = toggle
    toggle.Parent = parent
    local state = false
    toggle.MouseEnter:Connect(function()
        local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(toggle, tweenInfo, {BackgroundColor3 = Color3.fromRGB(100, 100, 100), Size = UDim2.new(0, 145, 0, 37)})
        tween:Play()
    end)
    toggle.MouseLeave:Connect(function()
        local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(toggle, tweenInfo, {BackgroundColor3 = state and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(60, 60, 60), Size = UDim2.new(0, 140, 0, 35)})
        tween:Play()
    end)
    toggle.MouseButton1Click:Connect(function()
        state = not state
        toggle.Text = name .. (state and " ✅" or " ❌")
        toggle.BackgroundColor3 = state and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(60, 60, 60)
        callback(state)
        print(name .. ": " .. (state and "ВКЛ" or "ВЫКЛ"))
    end)
    return toggle
end

local function createButton(name, yPos, parent, callback)
    print("🛠️ Создание кнопки: " .. name)
    local button = Instance.new("TextButton")
    button.Name = name .. "Button"
    button.Size = UDim2.new(0, 140, 0, 35)
    button.Position = UDim2.new(0, 10, 0, yPos)
    button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    button.Text = name
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.Legacy
    button.TextSize = 20
    button.TextStrokeTransparency = 1
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0.2, 0)
    uiCorner.Parent = button
    button.Parent = parent
    button.MouseEnter:Connect(function()
        local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(button, tweenInfo, {BackgroundColor3 = Color3.fromRGB(100, 100, 100), Size = UDim2.new(0, 145, 0, 37)})
        tween:Play()
    end)
    button.MouseLeave:Connect(function()
        local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(button, tweenInfo, {BackgroundColor3 = Color3.fromRGB(60, 60, 60), Size = UDim2.new(0, 140, 0, 35)})
        tween:Play()
    end)
    button.MouseButton1Click:Connect(function()
        callback()
        print("🚀 " .. name .. " активировано")
    end)
    return button
end

-- Легальный спидхак через покупку и активацию предмета
local speedSpringId = 123456 -- Замените на реальный ID предмета
local speedSpringActive = false
local function buySpeedSpring()
    pcall(function()
        ReplicatedStorage.BuyItem:FireServer(speedSpringId)
    end)
end

local function useSpeedSpring()
    local backpack = player.Backpack
    local speedSpring = backpack:FindFirstChild("SpeedSpring") -- Замените на реальное название
    if speedSpring then
        speedSpring:Activate()
        print("🏃 SpeedSpring активирован")
    else
        warn("🚫 SpeedSpring не найден в рюкзаке")
    end
end

local function toggleSpeedSpring(state)
    speedSpringActive = state
    if state then
        spawn(function()
            while speedSpringActive do
                buySpeedSpring()
                wait(1)
                useSpeedSpring()
                wait(5) -- Периодическая активация
            end
        end)
        print("🏃 Спидхак (Spring) ВКЛ")
    else
        print("🏃 Спидхак (Spring) ВЫКЛ")
    end
end

-- Обычный спидхак через WalkSpeed
local walkSpeedActive = false
local originalWalkSpeed = 16 -- Стандартная скорость Roblox
local customWalkSpeed = 50 -- Настраиваемая скорость
local function toggleWalkSpeed(state)
    walkSpeedActive = state
    if state then
        spawn(function()
            while walkSpeedActive do
                if player.Character and player.Character:FindFirstChild("Humanoid") then
                    player.Character.Humanoid.WalkSpeed = customWalkSpeed
                end
                wait(0.1) -- Периодическая проверка
            end
        end)
        print("🏃 Спидхак (WalkSpeed) ВКЛ")
    else
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.WalkSpeed = originalWalkSpeed
        end
        print("🏃 Спидхак (WalkSpeed) ВЫКЛ")
    end
end

-- ESP
local playerHighlights = {}
local brainrotHighlights = {}
local function enablePlayerESP(state)
    if state then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character then
                local highlight = Instance.new("Highlight")
                highlight.Name = "ESP"
                highlight.Adornee = p.Character
                highlight.FillColor = Color3.fromRGB(255, 0, 0)
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                highlight.Parent = p.Character
                playerHighlights[p] = highlight
            end
        end
        Players.PlayerAdded:Connect(function(p)
            if p ~= player then
                p.CharacterAdded:Connect(function(char)
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "ESP"
                    highlight.Adornee = char
                    highlight.FillColor = Color3.fromRGB(255, 0, 0)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.Parent = char
                    playerHighlights[p] = highlight
                end)
            end
        end)
    else
        for _, highlight in pairs(playerHighlights) do
            if highlight then highlight:Destroy() end
        end
        playerHighlights = {}
    end
end

local function enableBrainrotESP(state)
    if state then
        for _, plot in pairs(workspace.Plots:GetChildren()) do
            if plot ~= player.Plot then
                local animalPodiums = plot:FindFirstChild("AnimalPodiums")
                if animalPodiums then
                    for _, podium in pairs(animalPodiums:GetChildren()) do
                        local brainrot = podium:FindFirstChild("Brainrot")
                        if brainrot and (string.find(brainrot.Name, "Rare") or string.find(brainrot.Name, "Epic")) then
                            local highlight = Instance.new("Highlight")
                            highlight.Name = "ESP"
                            highlight.Adornee = brainrot
                            highlight.FillColor = Color3.fromRGB(0, 255, 0)
                            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                            highlight.Parent = brainrot
                            table.insert(brainrotHighlights, highlight)
                        end
                    end
                end
            end
        end
        workspace.Plots.ChildAdded:Connect(function(plot)
            if plot ~= player.Plot then
                local animalPodiums = plot:WaitForChild("AnimalPodiums", 5)
                if animalPodiums then
                    animalPodiums.ChildAdded:Connect(function(podium)
                        local brainrot = podium:WaitForChild("Brainrot", 5)
                        if brainrot and (string.find(brainrot.Name, "Rare") or string.find(brainrot.Name, "Epic")) then
                            local highlight = Instance.new("Highlight")
                            highlight.Name = "ESP"
                            highlight.Adornee = brainrot
                            highlight.FillColor = Color3.fromRGB(0, 255, 0)
                            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                            highlight.Parent = brainrot
                            table.insert(brainrotHighlights, highlight)
                        end
                    end)
                end
            end
        end)
    else
        for _, highlight in pairs(brainrotHighlights) do
            if highlight then highlight:Destroy() end
        end
        brainrotHighlights = {}
    end
end

-- Принудительное ESP
local forceEspEnabled = false
forceEspButton.MouseButton1Click:Connect(function()
    forceEspEnabled = not forceEspEnabled
    forceEspButton.Text = "👁️ ESP" .. (forceEspEnabled and " ✅" or " ❌")
    forceEspButton.BackgroundColor3 = forceEspEnabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(40, 40, 40)
    if forceEspEnabled then
        enablePlayerESP(true)
        print("👁️ ESP ВКЛ")
    else
        enablePlayerESP(false)
        print("👁️ ESP ВЫКЛ")
    end)
end

-- Серверные функции
local function rejoinServer()
    pcall(function()
        print("🔄 Перезаход на сервер...")
        TeleportService:Teleport(game.PlaceId, player)
        wait(5)
    end)
end

local function serverHop()
    pcall(function()
        print("🔄 Переход на другой сервер...")
        local success, servers = pcall(function()
            return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
        end)
        if success and servers and servers.data and #servers.data > 0 then
            local randomServer = servers.data[math.random(1, #servers.data)]
            TeleportService:TeleportToPlaceInstance(game.PlaceId, randomServer.id, player)
        else
            print("🚫 Серверы не найдены")
        end
    end)
end

local function smallServerHop()
    pcall(function()
        print("🔄 Поиск сервера с малым количеством игроков...")
        local success, servers = pcall(function()
            return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
        end)
        if success and servers and servers.data then
            local smallServer = nil
            for _, server in pairs(servers.data) do
                if server.playing < 5 then
                    smallServer = server
                    break
                end
            end
            if smallServer then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, smallServer.id, player)
            else
                serverHop()
                print("⚠️ Малый сервер не найден, переход на случайный")
            end
        else
            print("🚫 Серверы не найдены")
        end
    end)
end

-- Добавление элементов в меню
local functionsFrame = tabFrames["Функции"]
local speedSpringToggle = createToggle("🏃 Спидхак (Spring)", 10, functionsFrame, toggleSpeedSpring)
local walkSpeedToggle = createToggle("🏃 Спидхак (WalkSpeed)", 50, functionsFrame, toggleWalkSpeed)
local playerESPToggle = createToggle("👁️ Игроки ESP", 90, functionsFrame, enablePlayerESP)
local brainrotESPToggle = createToggle("🌟 Brainrot ESP", 130, functionsFrame, enableBrainrotESP)

local serverFrame = tabFrames["Серверы"]
local rejoinButton = createButton("🔄 Переподключение", 10, serverFrame, rejoinServer)
local serverHopButton = createButton("🔄 Смена сервера", 50, serverFrame, serverHop)
local smallServerHopButton = createButton("🔄 Малый сервер", 90, serverFrame, smallServerHop)

-- Подключение кнопки открытия меню
toggleButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
    animateMenu(mainFrame.Visible)
    print("🧠 Меню: " .. (mainFrame.Visible and "Открыто" or "Закрыто"))
end)
