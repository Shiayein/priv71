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
print("[LOADER] Initiating HTTP request for key_system.lua from: " .. REPO .. "key_system.lua")
local success, result = pcall(function()
    return game:HttpGet(REPO .. "key_system.lua")
end)
if not success then
    warn("[LOADER] HTTP request failed for key_system.lua: " .. tostring(result))
    LocalPlayer:Kick("Sorry " .. username .. ", failed to load key store: HTTP error - " .. tostring(result))
    return
end
local src = result
local httpErr = nil
print("[LOADER] Key system raw data: " .. tostring(src) .. ", Error: " .. tostring(httpErr or "None"))
if not src then
    warn("[LOADER] No data received from key_system.lua")
    LocalPlayer:Kick("Sorry " .. username .. ", failed to load key store: No data received")
    return
elseif #src == 0 then
    warn("[LOADER] Key system file is empty!")
    LocalPlayer:Kick("Sorry " .. username .. ", key store file is empty!")
    return
end
local chunk, compileErr = loadstring(src)
if not chunk then
    warn("[LOADER] Key system compile error: " .. tostring(compileErr))
    LocalPlayer:Kick("Sorry " .. username .. ", key system compile error: " .. tostring(compileErr))
    return
end
local KeyStore = chunk()
print("[LOADER] Loaded KeyStore: " .. tostring(KeyStore))

-- Key verification
local script_key = _G.SCRIPT_KEY or "NO_KEY"
print("[LOADER] Global SCRIPT_KEY value: " .. tostring(_G.SCRIPT_KEY))
print("[LOADER] Checking key: " .. script_key)
local isValid = false
for _, devKey in pairs(KeyStore.DEV_KEYS) do
    if devKey == script_key then
        isValid = true
        print("[LOADER] Valid developer key found: " .. devKey)
        break
    end
end
for key, data in pairs(KeyStore.KEYS) do
    print("[LOADER] Checking key pair: " .. key .. ", data: " .. tostring(data))
    if key == script_key then
        if not data.users then data.users = {} end
        if #data.users == 0 or table.find(data.users, userId) then
            isValid = true
            print("[LOADER] Valid key found for user or universal use: " .. key)
            if data.hwid and data.hwid ~= "" and data.hwid ~= hwid then
                LocalPlayer:Kick("Sorry " .. username .. ", your HWID does not match the key!")
                return
            end
            break
        end
    end
end
if not isValid then
    warn("[LOADER] Invalid key detected: " .. script_key)
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
