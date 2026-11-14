--// Froggy Blox - MainCode/Esp.lua
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local env = (getgenv and getgenv()) or _G
if env.__BF_PVP_ESP_CLEANUP then pcall(env.__BF_PVP_ESP_CLEANUP) end

local Config = {
    Enabled = false,
    ShowBounty = true,
    ShowWeapons = true,
    MaxDistance = 1000
}
env.BF_PVP_ESP_CONFIG = Config

local ESPObjects = {}

-- Función para obtener el arma equipada del enemigo
local function getEquippedWeapons(character)
    local weapons = {}
    for _, child in ipairs(character:GetChildren()) do
        if child:IsA("Tool") then
            table.insert(weapons, child.Name)
        end
    end
    if #weapons > 0 then
        return table.concat(weapons, ", ")
    end
    return "Ninguna"
end

-- Función para obtener el Bounty de Blox Fruits
local function getBounty(player)
    local stats = player:FindFirstChild("leaderstats")
    if stats then
        local bounty = stats:FindFirstChild("Bounty") or stats:FindFirstChild("Beli") or stats:FindFirstChild("Money")
        if bounty then return tostring(bounty.Value) end
    end
    return "0"
end

local function createESP(player)
    if player == LocalPlayer or ESPObjects[player] then return end

    -- 1. El resplandor (Highlight) - Cero lag
    local highlight = Instance.new("Highlight")
    highlight.Name = "FroggyESP"
    highlight.FillColor = Color3.fromRGB(255, 128, 176) -- Rosa Froggy
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.6
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Enabled = false
    highlight.Parent = player.Character

    -- 2. Los textos (BillboardGui)
    local bg = Instance.new("BillboardGui")
    bg.Name = "FroggyBG"
    bg.Size = UDim2.new(0, 220, 0, 60)
    bg.StudsOffset = Vector3.new(0, 4, 0) -- Un poco más arriba de la cabeza
    bg.AlwaysOnTop = true
    bg.Enabled = false
    bg.Parent = player.Character

    -- Diseño de la caja de texto
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    frame.BackgroundTransparency = 0.3
    frame.BorderSizePixel = 0
    frame.Parent = bg
    
    local corner = Instance.new("UICorner", frame)
    corner.CornerRadius = UDim.new(0, 8)
    
    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = Color3.fromRGB(255, 128, 176)
    stroke.Thickness = 1.5

    -- Texto: Nombre, Distancia, Bounty
    local infoText = Instance.new("TextLabel")
    infoText.Size = UDim2.new(1, -10, 0, 20)
    infoText.Position = UDim2.new(0, 5, 0, 5)
    infoText.BackgroundTransparency = 1
    infoText.Font = Enum.Font.GothamBold
    infoText.TextSize = 13
    infoText.TextColor3 = Color3.fromRGB(255, 255, 255)
    infoText.TextXAlignment = Enum.TextXAlignment.Left
    infoText.Parent = frame
    infoText.Text = "Cargando..."

    -- Texto: Armas
    local weaponText = Instance.new("TextLabel")
    weaponText.Size = UDim2.new(1, -10, 0, 15)
    weaponText.Position = UDim2.new(0, 5, 0, 25)
    weaponText.BackgroundTransparency = 1
    weaponText.Font = Enum.Font.GothamMedium
    weaponText.TextSize = 11
    weaponText.TextColor3 = Color3.fromRGB(200, 200, 200)
    weaponText.TextXAlignment = Enum.TextXAlignment.Left
    weaponText.Parent = frame
    weaponText.Text = ""

    -- Barra de vida
    local healthBarBg = Instance.new("Frame")
    healthBarBg.Size = UDim2.new(1, -10, 0, 4)
    healthBarBg.Position = UDim2.new(0, 5, 1, -9)
    healthBarBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    healthBarBg.BorderSizePixel = 0
    healthBarBg.Parent = frame
    Instance.new("UICorner", healthBarBg).CornerRadius = UDim.new(1, 0)

    local healthBarFill = Instance.new("Frame")
    healthBarFill.Size = UDim2.new(1, 0, 1, 0)
    healthBarFill.BackgroundColor3 = Color3.fromRGB(120, 226, 184) -- Verde
    healthBarFill.BorderSizePixel = 0
    healthBarFill.Parent = healthBarBg
    Instance.new("UICorner", healthBarFill).CornerRadius = UDim.new(1, 0)

    ESPObjects[player] = {
        Highlight = highlight,
        Billboard = bg,
        InfoText = infoText,
        WeaponText = weaponText,
        HealthFill = healthBarFill,
        Character = player.Character
    }
end

local function removeESP(player)
    if ESPObjects[player] then
        if ESPObjects[player].Highlight then ESPObjects[player].Highlight:Destroy() end
        if ESPObjects[player].Billboard then ESPObjects[player].Billboard:Destroy() end
        ESPObjects[player] = nil
    end
end

local function clearAll()
    for player, _ in pairs(ESPObjects) do
        removeESP(player)
    end
end

-- Conexiones para jugadores
Players.PlayerAdded:Connect(createESP)
Players.PlayerRemoving:Connect(removeESP)

-- Bucle de actualización (Optimizado a 5 FPS para no lagear)
task.spawn(function()
    while task.wait(0.2) do
        if Config.Enabled then
            local myChar = LocalPlayer.Character
            local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
            
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    if not ESPObjects[player] or ESPObjects[player].Character ~= player.Character then
                        removeESP(player)
                        createESP(player)
                    end

                    local data = ESPObjects[player]
                    local root = player.Character:FindFirstChild("HumanoidRootPart")
                    local hum = player.Character:FindFirstChildOfClass("Humanoid")

                    if root and hum and hum.Health > 0 and myRoot then
                        local dist = math.floor((root.Position - myRoot.Position).Magnitude)
                        if dist <= Config.MaxDistance then
                            data.Highlight.Enabled = true
                            data.Billboard.Enabled = true
                            
                            -- Actualizar textos
                            local bounty = Config.ShowBounty and getBounty(player) or "Oculto"
                            data.InfoText.Text = string.format("%s | %dm | 💰 %s", player.Name, dist, bounty)
                            
                            if Config.ShowWeapons then
                                data.WeaponText.Text = "🗡️ " .. getEquippedWeapons(player.Character)
                            else
                                data.WeaponText.Text = ""
                            end

                            -- Actualizar barra de vida
                            local ratio = hum.Health / hum.MaxHealth
                            data.HealthFill.Size = UDim2.new(ratio, 0, 1, 0)
                            data.HealthFill.BackgroundColor3 = Color3.fromRGB(255 * (1 - ratio), 255 * ratio, 0)
                        else
                            data.Highlight.Enabled = false
                            data.Billboard.Enabled = false
                        end
                    else
                        data.Highlight.Enabled = false
                        data.Billboard.Enabled = false
                    end
                end
            end
        else
            -- Si se apaga, ocultar todo
            for _, data in pairs(ESPObjects) do
                data.Highlight.Enabled = false
                data.Billboard.Enabled = false
            end
        end
    end
end)

-- Inicializar para jugadores ya en partida
for _, p in ipairs(Players:GetPlayers()) do
    createESP(p)
end

env.__BF_PVP_ESP_CLEANUP = function()
    Config.Enabled = false
    clearAll()
    env.BF_PVP_ESP_CONFIG = nil
    env.__BF_PVP_ESP_CLEANUP = nil
end
