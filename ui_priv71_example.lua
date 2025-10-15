-- ui_priv71_example.lua
-- priv71 — UI with tabs (square, mobile-friendly). Loads lib and creates 3 test tabs.
-- Calls logic via getgenv().PRIV71

local PRIV71 = getgenv().PRIV71 or {}
getgenv().PRIV71 = PRIV71

local LIB_URL = "https://raw.githubusercontent.com/Shiayein/priv71/refs/heads/main/source_gui_priv71.lua"
local ok, libOrErr = pcall(function() return loadstring(game:HttpGet(LIB_URL))() end)
if not ok then
    warn("[priv71 UI] Failed to load source_gui_priv71.lua: ", tostring(libOrErr))
    return
end
local library = libOrErr
library:init()

local Window = library.NewWindow({ title = "priv71", subtitle = "Da Hood" })

-- Tab 1: Main
local MainTab = Window:AddTab("Main")
local MainSection = MainTab:AddSection("General Controls", 1)
MainSection:AddToggle({ text = "Notifications", state = false, callback = function(on) PRIV71.ToggleNotifications(on) end })

-- Tab 2: HvH
local HvHTab = Window:AddTab("HvH")
local HvHSection = HvHTab:AddSection("Combat Controls", 1)
HvHSection:AddToggle({ text = "Silent Aim", state = false, callback = function(on) PRIV71.StartSilentAim(on) end })
HvHSection:AddToggle({ text = "Auto Strafe", state = false, callback = function(on) PRIV71.StartAutoStrafe(on) end })

-- Tab 3: Character
local CharTab = Window:AddTab("Character")
local CharSection = CharTab:AddSection("Player Mods", 1)
CharSection:AddToggle({ text = "Speed Hack", state = false, callback = function(on) PRIV71.SetSpeed(on) end })

-- Settings keybind (added to first tab for simplicity)
MainSection:AddKeybind({
    text = "Toggle UI Key", default = Enum.KeyCode.RightShift,
    onChanged = function(key) library:SetToggleKey(key); library:SendNotification("UI key set to: " .. key.Name, 2) end
})

-- Test logic hooks
PRIV71.ToggleNotifications = function(on) print("Notifications:", on) end
PRIV71.StartSilentAim = function(on) print("Silent Aim:", on) end
PRIV71.StartAutoStrafe = function(on) print("Auto Strafe:", on) end
PRIV71.SetSpeed = function(on) print("Speed:", on) end
