-- loader.lua
local REPO = "https://raw.githubusercontent.com/Shiayein/priv71/refs/heads/main/"
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local userId = LocalPlayer and LocalPlayer.UserId or 0
local username = LocalPlayer and LocalPlayer.Name or "Unknown"

-- Get HWID
local hwid = game:GetService("RbxAnalyticsService"):GetClientId()
print("[LOADER] Detected HWID: " .. hwid)
if setclipboard then
    setclipboard(hwid)
    print("[LOADER] HWID copied to clipboard!")
else
    warn("[LOADER] Clipboard not supported!")
end

-- Load key system
local src, httpErr = game:HttpGet(REPO .. "key_system.lua")
if not src then
    LocalPlayer:Kick("Sorry " .. username .. ", failed to load key store: " .. tostring(httpErr or "Unknown error"))
    return
elseif #src == 0 then
    LocalPlayer:Kick("Sorry " .. username .. ", key store file is empty!")
    return
end
local chunk, compileErr = loadstring(src)
if not chunk then
    LocalPlayer:Kick("Sorry " .. username .. ", key system compile error: " .. tostring(compileErr))
    return
end
local KeyStore = chunk()

-- Key verification
local script_key = _G.SCRIPT_KEY or "NO_KEY"
print("[LOADER] Checking key: " .. script_key)
local isValid = false
for _, devKey in pairs(KeyStore.DEV_KEYS) do
    if devKey == script_key then
        isValid = true
        break
    end
end
for key, data in pairs(KeyStore.KEYS) do
    if key == script_key then
        if not data.users then data.users = {} end
        if #data.users == 0 or table.find(data.users, userId) then
            isValid = true
            if data.hwid and data.hwid ~= "" and data.hwid ~= hwid then
                LocalPlayer:Kick("Sorry " .. username .. ", your HWID does not match the key!")
                return
            end
            break
        end
    end
end
if not isValid then
    LocalPlayer:Kick("Sorry " .. username .. ", invalid key detected!")
    return
end

-- Mark as loaded with loader
_G.LOADED_WITH_LOADER = true
print("[LOADER] Loader verification passed, loading scripts...")

-- Load the main script
local success, err = pcall(function()
    loadstring(game:HttpGet(REPO .. "main.lua"))()
end)
if not success then
    print("[LOADER] Error loading main.lua: " .. tostring(err))
end

-- Load GUI extensions for Players tab
local success, err = pcall(function()
    loadstring(game:HttpGet(REPO .. "gui_extensions.lua"))()
end)
if not success then
    warn("[LOADER] Failed to load GUI extensions: " .. tostring(err))
end

-- Load ragebot script for Players tab
local success, err = pcall(function()
    loadstring(game:HttpGet(REPO .. "ragebot.lua"))()
end)
if not success then
    warn("[LOADER] Failed to load ragebot.lua: " .. tostring(err))
end
