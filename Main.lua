--// Main.lua - FROGGY HUB BLOX FRUITS PVP (V1.1 ESP Update)
local GITHUB_USER = "cristhiandalmauquintana-ctrl"
local GITHUB_REPO = "FroggyBlox"
local BRANCH = "main"
local ROOT = "https://raw.githubusercontent.com/"..GITHUB_USER.."/"..GITHUB_REPO.."/"..BRANCH.."/"

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local env = (getgenv and getgenv()) or _G

if env.BF_PVP_CURRENT_UI then
    pcall(function() env.BF_PVP_CURRENT_UI:Destroy() end)
    env.BF_PVP_CURRENT_UI = nil
end

local SavedState = {}
if isfile and readfile then
    local ok, data = pcall(function() return readfile("FroggyBloxConfig.json") end)
    if ok and data then
        local ok2, decoded = pcall(function() return HttpService:JSONDecode(data) end)
        if ok2 and decoded then SavedState = decoded end
    end
end

print("[Froggy Blox] Cargando interfaz...")
local UI_Library = loadstring(game:HttpGet(ROOT .. "resources/design.lua?v=" .. os.time()))()
local Assets = loadstring(game:HttpGet(ROOT .. "resources/assets.lua?v=" .. os.time()))()

env.BF_PVP_UI_LIBRARY = UI_Library 
env.BF_PVP_ASSETS_LIBRARY = Assets

local savedTheme = SavedState.Theme or "auto"

local Window = UI_Library.CreateWindow({ 
    Title = "FROGGY HUB", 
    Subtitle = "BLOX FRUITS PVP",
    Theme = savedTheme
})
env.BF_PVP_CURRENT_UI = Window

Assets.Extend(Window)

local TabCombat = Window:CreateTab("COMBAT")
local TabVisual = Window:CreateTab("VISUAL")
local TabMovement = Window:CreateTab("MOVEMENT")
local TabConfig = Window:CreateTab("CONFIG")

local folder = "MainCode/"
local function download(name, key)
    local url = ROOT .. folder .. name .. "?v=" .. os.time()
    local ok, res = pcall(game.HttpGet, game, url)
    if ok and type(res) == "string" and #res > 0 and res:sub(1,3) ~= "404" then
        local fnOk, fn = pcall(loadstring, res)
        if fnOk and type(fn) == "function" then pcall(fn) end
    else
        warn("❌ Could not download " .. name)
    end
    task.wait(0.1)
    return env[key] or _G[key]
end

-- Descargar el módulo ESP
local EspC = download("Esp.lua", "BF_PVP_ESP_CONFIG")

-- === COMBAT ===
TabCombat:AddSection("COMBAT (PvP)")
TabCombat:AddInfo("Aviso", "Los módulos de combate se están programando...")

-- === VISUAL ===
TabVisual:AddSection("ESP PROFESIONAL")
if EspC then
    local t = TabVisual:AddToggle("ACTIVAR ESP", false, function(state)
        EspC.Enabled = state
        if state then Window:Notify({Title = "ESP", Content = "ESP Activado", Type = "success"}) end
    end)
    
    TabVisual:AddToggle("MOSTRAR BOUNTY", true, function(state) EspC.ShowBounty = state end)
    TabVisual:AddToggle("MOSTRAR ARMAS/FRUTAS", true, function(state) EspC.ShowWeapons = state end)
    
    TabVisual:AddSlider("DISTANCIA MÁXIMA", 100, 3000, 1000, function(val) EspC.MaxDistance = val end, 100)
    
    TabVisual:AddInfo("Info", "El ESP usa 'Highlights' nativos. Cero lag. Muestra el nombre, la distancia, el Bounty y las armas equipadas.")
end

-- === MOVEMENT ===
TabMovement:AddSection("MOVEMENT")
TabMovement:AddInfo("Aviso", "Los módulos de movimiento se están programando...")

-- === CONFIG ===
TabConfig:AddSection("AJUSTES DE INTERFAZ")
local themes = {"auto", "pastel", "xmas", "fall"}
TabConfig:AddDropdown("TEMA DE LA UI", themes, savedTheme, function(val)
    SavedState.Theme = val
    if writefile then pcall(function() writefile("FroggyBloxConfig.json", HttpService:JSONEncode(SavedState)) end) end
    Window:Notify({Title = "Theme", Content = "Tema: "..val..". (Reinicia para aplicar)", Type = "info"})
end)

TabConfig:AddButton("DESTRUIR UI", function()
    Window:Destroy()
    if env.BF_PVP_CURRENT_UI == Window then env.BF_PVP_CURRENT_UI = nil end
end)
