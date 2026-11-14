--// Main.lua - FROGGY HUB BLOX FRUITS PVP (V1.0)
local GITHUB_USER = "cristhiandalmauquintana-ctrl"
local GITHUB_REPO = "FroggyBloxPvP" -- 👈 CAMBIA ESTO SI USAS OTRO NOMBRE DE REPO
local BRANCH = "main"
local ROOT = "https://raw.githubusercontent.com/"..GITHUB_USER.."/"..GITHUB_REPO.."/"..BRANCH.."/"

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local env = (getgenv and getgenv()) or _G

-- 🛑 CANDADO ANTI-DOBLE EJECUCIÓN
if env.BF_PVP_CURRENT_UI then
    pcall(function() env.BF_PVP_CURRENT_UI:Destroy() end)
    env.BF_PVP_CURRENT_UI = nil
end

-- ==========================================
-- 1. SISTEMA DE PERSISTENCIA
-- ==========================================
local SavedState = {}
if isfile and readfile then
    local ok, data = pcall(function() return readfile("FroggyPvPConfig.json") end)
    if ok and data then
        local ok2, decoded = pcall(function() return HttpService:JSONDecode(data) end)
        if ok2 and decoded then SavedState = decoded end
    end
end

-- ==========================================
-- 2. CARGAMOS DISEÑO Y ASSETS DESDE LA CARPETA RESOURCES
-- ==========================================
print("[Froggy PvP] Cargando interfaz...")
local UI_Library = loadstring(game:HttpGet(ROOT .. "resources/design.lua?v=" .. os.time()))()
local Assets = loadstring(game:HttpGet(ROOT .. "resources/assets.lua?v=" .. os.time()))()

env.BF_PVP_UI_LIBRARY = UI_Library 
env.BF_PVP_ASSETS_LIBRARY = Assets

-- Cargar tema guardado o usar "auto" (detecta la fecha)
local savedTheme = SavedState.Theme or "auto"

local Window = UI_Library.CreateWindow({ 
    Title = "FROGGY HUB", 
    Subtitle = "BLOX FRUITS PVP",
    Theme = savedTheme
})
env.BF_PVP_CURRENT_UI = Window

-- Extendemos la ventana con los componentes de assets.lua
Assets.Extend(Window)

-- ==========================================
-- 3. CREACIÓN DE PESTAÑAS (TABS)
-- ==========================================
local TabCombat = Window:CreateTab("COMBAT")
local TabVisual = Window:CreateTab("VISUAL")
local TabMovement = Window:CreateTab("MOVEMENT")
local TabConfig = Window:CreateTab("CONFIG")

-- ==========================================
-- 4. DESCARGA DE MÓDULOS (DESDE LA CARPETA MAINCODE)
-- ==========================================
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

-- (Estos módulos los programaremos en los próximos pasos)
-- local EspC = download("Esp.lua", "BF_PVP_ESP")
-- local AimC = download("SilentAim.lua", "BF_PVP_AIM")
-- local MoveC = download("Movement.lua", "BF_PVP_MOVE")

-- ==========================================
-- 5. CONEXIÓN UI (ESQUELETO)
-- ==========================================

-- === COMBAT ===
TabCombat:AddSection("COMBAT (PvP)")
TabCombat:AddInfo("Aviso", "Los módulos de combate se están programando...")
-- Aquí irán: Silent Aim, Hitbox Expander, Auto-Dodge

-- === VISUAL ===
TabVisual:AddSection("VISUAL (ESP)")
TabVisual:AddInfo("Aviso", "Los módulos de ESP se están programando...")
-- Aquí irán: Player ESP, Fruit ESP, Chest ESP

-- === MOVEMENT ===
TabMovement:AddSection("MOVEMENT")
TabMovement:AddInfo("Aviso", "Los módulos de movimiento se están programando...")
-- Aquí irán: Speed Hack, Jump Power

-- === CONFIG ===
TabConfig:AddSection("AJUSTES DE INTERFAZ")

-- Selector de Tema (Aprovechando la nueva UI)
local themes = {"auto", "pastel", "xmas", "fall"}
TabConfig:AddDropdown("TEMA DE LA UI", themes, savedTheme, function(val)
    SavedState.Theme = val
    if writefile then 
        pcall(function() writefile("FroggyPvPConfig.json", HttpService:JSONEncode(SavedState)) end) 
    end
    Window:Notify({Title = "Theme", Content = "Tema cambiado a: "..val..". (Reinicia el script para aplicar)", Type = "info"})
end)

TabConfig:AddButton("DESTRUIR UI", function()
    Window:Destroy()
    if env.BF_PVP_CURRENT_UI == Window then env.BF_PVP_CURRENT_UI = nil end
end)

print("[Froggy PvP] Interfaz base cargada exitosamente.")
