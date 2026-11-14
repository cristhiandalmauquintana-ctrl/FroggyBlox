--// Froggy Blox - MainCode/Esp.lua (V4 - Bounty Deep Search + Debug)
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

-- 🔍 BÚSQUEDA PROFUNDA DEL BOUNTY
local function getBountyDeep(player)
    -- 1. Buscar en leaderstats (Bounty o Honor)
    local stats = player:FindFirstChild("leaderstats")
    if stats then
        local b = stats:FindFirstChild("Bounty") 
            or stats:FindFirstChild("Honor") 
            or stats:FindFirstChild("Bounty/Honor")
        if b then return tostring(b.Value) end
    end

    -- 2. Buscar en la carpeta "Data" del jugador
    local data = player:FindFirstChild("Data")
    if data then
        local b = data:FindFirstChild("Bounty") 
            or data:FindFirstChild("Honor")
        if b then return tostring(b.Value) end
    end

    -- 3. Buscar en atributos del jugador
    local attrBounty = player:GetAttribute("Bounty") or player:GetAttribute("Honor")
    if attrBounty then return tostring(attrBounty) end

    -- 4. Buscar en los atributos de la hoja de stats (algunos scripts lo guardan ahí)
    local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        local attrHumBounty = hum:GetAttribute("Bounty") or hum:GetAttribute("Honor")
        if attrHumBounty then return tostring(attrHumBounty) end
    end

    return nil -- Si no lo encuentra, devolvemos nil para saber que falló
end

-- 🔍 Obtener Armas (igual que antes)
local function getEquippedWeapon(player)
    local char = player.Character
    if not char then return "Ninguna" end
    local tool = char:FindFirstChildOfClass("Tool")
    if tool then
        if string.find(tool.Name, "Fruit") then return "🍎 " .. tool.Name
        elseif string.find(string.lower(tool.Name), "sword") or string.find(string.lower(tool.Name), "blade") then return "⚔️ " .. tool.Name
        elseif string.find(string.lower(tool.Name), "gun") or string.find(string.lower(tool.Name), "rifle") then return "🔫 " .. tool.Name
        else return "🥊 " .. tool.Name end
    end
    return "Ninguna"
end

-- 🛠️ Crear ESP
local function createESP(player)
    if player == LocalPlayer or ESPObjects[player] then return end
    local char = player.Character
    if not char then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "FroggyESP"
    highlight.FillColor = Color3.fromRGB(255, 128, 176)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.6
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Enabled = false
    highlight.Parent = char

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

    local infoText = Instance.new("TextLabel")
    infoText.Size = UDim2.new(1, -10, 0, 20)
    infoText.Position = UDim2.new(0, 5, 0, 5)
    infoText.BackgroundTransparency = 1
    infoText.Font = Enum.Font.GothamBold
    infoText.TextSize = 13
    infoText.TextColor3 = Color3.fromRGB(255, 255, 255)
    infoText.TextXAlignment = Enum.TextXAlignment.Left
    infoText.Parent = frame

    local bountyText = Instance.new("TextLabel")
    bountyText.Size = UDim2.new(1, -10, 0, 15)
    bountyText.Position = UDim2.new(0, 5, 0, 25)
    bountyText.BackgroundTransparency = 1
    bountyText.Font = Enum.Font.GothamSemibold
    bountyText.TextSize = 12
    bountyText.TextColor3 = Color3.fromRGB(255, 215, 0)
    bountyText.TextXAlignment = Enum.TextXAlignment.Left
    bountyText.Parent = frame

    local weaponText = Instance.new("TextLabel")
    weaponText.Size = UDim2.new(1, -10, 0, 15)
    weaponText.Position = UDim2.new(0, 5, 0, 40)
    weaponText.BackgroundTransparency = 1
    weaponText.Font = Enum.Font.GothamMedium
    weaponText.TextSize = 11
    weaponText.TextColor3 = Color3.fromRGB(180, 180, 180)
    weaponText.TextXAlignment = Enum.TextXAlignment.Left
    weaponText.Parent = frame

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

    char.ChildAdded:Connect(function(child)
        if child:IsA("Tool") and Config.Enabled and ESPObjects[player] then
            ESPObjects[player].WeaponText.Text = getEquippedWeapon(player)
        end
    end)
end

-- 📊 BOTÓN DE DEBUG: Te dice exactamente dónde está el Bounty
local function debugPlayerStats(player)
    print("===== DEBUG DE " .. player.Name .. " =====")
    local found = false

    local stats = player:FindFirstChild("leaderstats")
    if stats then
        print("[leaderstats] encontrados:")
        for _, v in ipairs(stats:GetChildren()) do
            print("  -> " .. v.Name .. " = " .. tostring(v.Value))
            found = true
        end
    end

    local data = player:FindFirstChild("Data")
    if data then
        print("[Data] encontrados:")
        for _, v in ipairs(data:GetChildren()) do
            if v:IsA("ValueBase") then
                print("  -> " .. v.Name .. " = " .. tostring(v.Value))
                found = true
            end
        end
    end

    local attrs = player:GetAttributes()
    if next(attrs) then
        print("[Atributos del Player]:")
        for k, v in pairs(attrs) do
            print("  -> " .. k .. " = " .. tostring(v))
            found = true
        end
    end

    if not found then
        print("No se encontraron valores. El Bounty puede estar oculto en el servidor o en un RemoteEvent.")
    end
    print("=========================================")
end

-- Bucle principal
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
                            
                            local bounty = getBountyDeep(player)
                            
                            -- Si no encuentra el Bounty, lo indica en el HUD
                            local bountyStr = bounty and ("💰 " .. bounty) or "💰 Bounty: Oculto"
                            
                            data.InfoText.Text = string.format("%s | %dm", player.Name, dist)
                            
                            if Config.ShowBounty then
                                data.BountyText.Text = bountyStr
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

for _, p in ipairs(Players:GetPlayers()) do
    if p.Character then createESP(p) end
    p.CharacterAdded:Connect(function() task.wait(1) createESP(p) end)
end

-- Exponemos la función de debug para usarla desde el Main.lua
env.BF_PVP_DEBUG_BOUNTY = function()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            debugPlayerStats(p)
        end
    end
end

env.__BF_PVP_ESP_CLEANUP = function()
    Config.Enabled = false
    for _, data in pairs(ESPObjects) do
        if data.Highlight then data.Highlight:Destroy() end
        if data.Billboard then data.Billboard:Destroy() end
    end
    ESPObjects = {}
    env.BF_PVP_ESP_CONFIG = nil
    env.__BF_PVP_ESP_CLEANUP = nil
end
