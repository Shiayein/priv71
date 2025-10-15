-- ui_priv71_example.lua
-- priv71 — UI only (square, mobile-friendly). No logic here.
-- Uses source_gui_priv71.lua and calls the logic via getgenv().PRIV71

local PRIV71 = getgenv().PRIV71 or {}
getgenv().PRIV71 = PRIV71

local LIB_URL = "https://raw.githubusercontent.com/Shiayein/priv71/main/source_gui_priv71.lua"
local ok, libOrErr = pcall(function() return loadstring(game:HttpGet(LIB_URL))() end)
if not ok then
    warn("[priv71 UI] Failed to load source_gui_priv71.lua: ", tostring(libOrErr))
    return
end
local library = libOrErr
library:init()

local Window = library.NewWindow({ title = "priv71", subtitle = "Da Hood" })
local Tab = Window:AddTab("main")
local Section = Tab:AddSection("HvH Controls", 1)

-- Left indicator (tap to reopen the GUI; no duplicates)
local statusIndicator = library.NewIndicator({
    title = "priv71",
    enabled = true,
    position = UDim2.new(0, 12, 0, 240),
    clickToOpen = true
})
local statusValue = statusIndicator:AddValue({ key = "Status", value = "Idle" })

-- Allow the logic to push status to the UI
PRIV71.SetStatus = function(text)
    statusValue:SetValue(tostring(text or "Idle"))
end

-- UI -> Logic
Section:AddToggle({
    text = "Silent Aim",
    state = false,
    callback = function(on)
        if PRIV71.StartSilentAim then PRIV71.StartSilentAim(on) end
    end
})

Section:AddToggle({
    text = "Auto Strafe",
    state = false,
    callback = function(on)
        if PRIV71.StartAutoStrafe then PRIV71.StartAutoStrafe(on) end
    end
})

Section:AddKeybind({
    text = "Toggle UI Key",
    default = Enum.KeyCode.RightShift,
    onChanged = function(key)
        library:SetToggleKey(key)
        library:SendNotification("UI key set to: " .. key.Name, 2)
    end
})
