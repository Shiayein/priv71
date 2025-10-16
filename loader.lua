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
print("[LOADER] Key system raw data: " .. tostring(src) .. ", Error: " .. tostring(httpErr or "None")) -- Debug log
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
print("[LOADER] Loaded KeyStore: " .. tostring(KeyStore)) -- Debug log

-- Key verification
local script_key = _G.SCRIPT_KEY or "NO_KEY"
print("[LOADER] Global SCRIPT_KEY value: " .. tostring(_G.SCRIPT_KEY)) -- Debug log
print("[LOADER] Checking key: " .. script_key) -- Debug log
local isValid = false
for _, devKey in pairs(KeyStore.DEV_KEYS) do
    if devKey == script_key then
        isValid = true
        print("[LOADER] Valid developer key found: " .. devKey)
        break
    end
end
for key, data in pairs(KeyStore.KEYS) do
    print("[LOADER] Checking key pair: " .. key .. ", data: " .. tostring(data)) -- Debug log
    if key == script_key then
        if not data.users then data.users = {} end -- Default to empty table if nil
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

-- Load additional future scripts (example folder or URLs)
local additionalScripts = {
    "https://raw.githubusercontent.com/Shiayein/priv71/refs/heads/main/scripts/future_script1.lua", -- Example URL
    "https://raw.githubusercontent.com/Shiayein/priv71/refs/heads/main/scripts/future_script2.lua"  -- Add more as needed
}

for _, scriptUrl in pairs(additionalScripts) do
    local success, err = pcall(function()
        loadstring(game:HttpGet(scriptUrl))()
    end)
    if not success then
        print("[LOADER] Failed to load additional script " .. scriptUrl .. ": " .. tostring(err))
    else
        print("[LOADER] Successfully loaded additional script: " .. scriptUrl)
    end
end
