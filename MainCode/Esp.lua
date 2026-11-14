--// Froggy Blox - MainCode/Esp.lua (V3 - Professional Real-Time HUD)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local env = (getgenv and getgenv()) or _G
if env.__BF_PVP_ESP_CLEANUP then pcall(env.__BF_PVP_ESP_CLEANUP) end

local Config = {
    Enabled = false,
    ShowBounty = true,
    ShowWeapons = true,
    MaxDistance = 2000
}
env.BF_PVP_ESP_CONFIG = Config

local ESPObjects = {}

-- 1. Obtener Stats Reales (Bounty y Nivel)
local function getPlayerStats(player)
    local bounty, level = "0", "0"
    local stats = player:FindFirstChild("leaderstats")
    if stats then
        local b = stats:FindFirstChild("Bounty") or stats:FindFirstChild("Beli") or stats:FindFirstChild("Money")
        if b then bounty = tostring(b.Value) end
        local l = stats:FindFirstChild("Level")
        if l then level = tostring(l.Value) end
    end
    return bounty, level
end

-- 2. Obtener Armas Equipadas (Búsqueda en tiempo real)
local function getEquippedWeapon(player)
    local char = player.Character
    if not char then return "Ninguna" end
    local tool = char:FindFirstChildOfClass("Tool")
    if tool then
        -- Si el nombre contiene "Fruit", lo marcamos como Fruta
        if string.find(tool.Name, "Fruit") then
            return "🍎 " .. tool.Name
        elseif string.find(string.lower(tool.Name), "sword") or string.find(string.lower(tool.Name), "blade") then
            return "⚔️ " .. tool.Name
        elseif string.find(string.lower(tool.Name), "gun") or string.find(string.lower(tool.Name), "rifle") then
            return "🔫 " .. tool.Name
        else
            return "🥊 " .. tool.Name
        end
    end
    return "Ninguna"
end

-- 3. Crear la interfaz del ESP
local function createESP(player)
    if player == LocalPlayer or ESPObjects[player] then return end
    local char = player.Character
    if not char then return end

    -- Highlight (Resplandor)
    local highlight = Instance.new("Highlight")
    highlight.Name = "FroggyESP"
    highlight.FillColor = Color3.fromRGB(255, 128, 176)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.6
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Enabled = false
    highlight.Parent = char

    -- Billboard HUD
    local bg = Instance.new("BillboardGui")
    bg.Name = "FroggyBG"
    bg.Size = UDim2.new(0, 250, 0, 65)
    bg.StudsOffset = Vector3.new(0, 6, 0)
    bg.AlwaysOnTop = true
    bg.Enabled = false
    bg.Parent = char

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    frame.BackgroundTransparency = 0.2
    frame.BorderSizePixel = 0
    frame.Parent = bg
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = Color3.fromRGB(255, 128, 176)
    stroke.Thickness = 1.5

    -- Texto de Info (Nivel, Nombre, Distancia)
    local infoText = Instance.new("TextLabel")
    infoText.Size = UDim2.new(1, -10, 0, 20)
    infoText.Position = UDim2.new(0, 5, 0, 5)
    infoText.BackgroundTransparency = 1
    infoText.Font = Enum.Font.GothamBold
    infoText.TextSize = 13
    infoText.TextColor3 = Color3.fromRGB(255, 255, 255)
    infoText.TextXAlignment = Enum.TextXAlignment.Left
    infoText.Parent = frame

    -- Texto de Bounty
    local bountyText = Instance.new("TextLabel")
    bountyText.Size = UDim2.new(1, -10, 0, 15)
    bountyText.Position = UDim2.new(0, 5, 0, 25)
    bountyText.BackgroundTransparency = 1
    bountyText.Font = Enum.Font.GothamSemibold
    bountyText.TextSize = 12
    bountyText.TextColor3 = Color3.fromRGB(255, 215, 0)
    bountyText.TextXAlignment = Enum.TextXAlignment.Left
    bountyText.Parent = frame

    -- Texto de Arma
    local weaponText = Instance.new("TextLabel")
    weaponText.Size = UDim2.new(1, -10, 0, 15)
    weaponText.Position = UDim2.new(0, 5, 0, 40)
    weaponText.BackgroundTransparency = 1
    weaponText.Font = Enum.Font.GothamMedium
    weaponText.TextSize = 11
    weaponText.TextColor3 = Color3.fromRGB(180, 180, 180)
    weaponText.TextXAlignment = Enum.TextXAlignment.Left
    weaponText.Parent = frame

    -- Barra de Vida
    local healthBarBg = Instance.new("Frame")
    healthBarBg.Size = UDim2.new(1, -10, 0, 4)
    healthBarBg.Position = UDim2.new(0, 5, 1, -8)
    healthBarBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    healthBarBg.BorderSizePixel = 0
    healthBarBg.Parent = frame
    Instance.new("UICorner", healthBarBg).CornerRadius = UDim.new(1, 0)

    local healthBarFill = Instance.new("Frame")
    healthBarFill.Size = UDim2.new(1, 0, 1, 0)
    healthBarFill.BackgroundColor3 = Color3.fromRGB(120, 226, 184)
    healthBarFill.BorderSizePixel = 0
    healthBarFill.Parent = healthBarBg
    Instance.new("UICorner", healthBarFill).CornerRadius = UDim.new(1, 0)

    ESPObjects[player] = {
        Highlight = highlight,
        Billboard = bg,
        InfoText = infoText,
        BountyText = bountyText,
        WeaponText = weaponText,
        HealthFill = healthBarFill,
        Character = char
    }

    -- 🔥 ACTUALIZACIÓN EN TIEMPO REAL: Escuchar cuando el jugador equipa un arma
    char.ChildAdded:Connect(function(child)
        if child:IsA("Tool") and Config.Enabled and ESPObjects[player] then
            ESPObjects[player].WeaponText.Text = getEquippedWeapon(player)
        end
    end)
end

-- 4. Bucle de Actualización (Optimizado)
task.spawn(function()
    while task.wait(0.2) do
        if Config.Enabled then
            local myChar = LocalPlayer.Character
            local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
            
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    if not ESPObjects[player] or ESPObjects[player].Character ~= player.Character then
                        if ESPObjects[player] then
                            if ESPObjects[player].Highlight then ESPObjects[player].Highlight:Destroy() end
                            if ESPObjects[player].Billboard then ESPObjects[player].Billboard:Destroy() end
                            ESPObjects[player] = nil
                        end
                        createESP(player)
                    end

                    local data = ESPObjects[player]
                    local root = player.Character:FindFirstChild("HumanoidRootPart")
                    local hum = player.Character:FindFirstChildOfClass("Humanoid")

                    if root and hum and hum.Health > 0 and myRoot and data then
                        local dist = math.floor((root.Position - myRoot.Position).Magnitude)
                        if dist <= Config.MaxDistance then
                            data.Highlight.Enabled = true
                            data.Billboard.Enabled = true
                            
                            local bounty, level = getPlayerStats(player)
                            data.InfoText.Text = string.format("[Lv.%s] %s | %dm", level, player.Name, dist)
                            
                            if Config.ShowBounty then
                                data.BountyText.Text = "💰 " .. bounty
                            else
                                data.BountyText.Text = ""
                            end

                            if Config.ShowWeapons then
                                data.WeaponText.Text = getEquippedWeapon(player)
                            else
                                data.WeaponText.Text = ""
                            end

                            local ratio = hum.Health / hum.MaxHealth
                            data.HealthFill.Size = UDim2.new(ratio, 0, 1, 0)
                            data.HealthFill.BackgroundColor3 = Color3.fromRGB(255 * (1 - ratio), 255 * ratio, 0)
                        else
                            data.Highlight.Enabled = false
                            data.Billboard.Enabled = false
                        end
                    else
                        if data then
                            data.Highlight.Enabled = false
                            data.Billboard.Enabled = false
                        end
                    end
                end
            end
        else
            for _, data in pairs(ESPObjects) do
                data.Highlight.Enabled = false
                data.Billboard.Enabled = false
            end
        end
    end
end)

-- Inicializar
for _, p in ipairs(Players:GetPlayers()) do
    if p.Character then createESP(p) end
    p.CharacterAdded:Connect(function() task.wait(1) createESP(p) end)
end

env.__BF_PVP_ESP_CLEANUP = function()
    Config.Enabled = false
    for player, data in pairs(ESPObjects) do
        if data.Highlight then data.Highlight:Destroy() end
        if data.Billboard then data.Billboard:Destroy() end
    end
    ESPObjects = {}
    env.BF_PVP_ESP_CONFIG = nil
    env.__BF_PVP_ESP_CLEANUP = nil
end
