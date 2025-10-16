-- gui_extensions.lua
-- Add ragebot controls to the Players tab
local Tabs = getfenv(0).Tabs -- Access tabs from main.lua environment
local maxAttempts = 10 -- Number of retry attempts
local attempt = 0
local timeout = 2.0 -- Maximum wait time in seconds

-- Function to add ragebot controls with timeout and Library check
local function addRagebotControls()
    attempt = attempt + 1
    local startTime = tick()

    while (not Tabs or not Tabs.Players or not getgenv().PlayerActions or not getfenv(0).Library) and (tick() - startTime) < timeout do
        warn("[GUI] Waiting for PlayerActions or Library to be initialized... (Attempt " .. attempt .. " of " .. maxAttempts .. ")")
        wait(0.2) -- Delay before next check
    end

    if not Tabs or not Tabs.Players or not getgenv().PlayerActions or not getfenv(0).Library then
        warn("[GUI] Failed to initialize ragebot controls after " .. timeout .. " seconds and " .. attempt .. " attempts!")
        return
    }

    -- Use Library from the main.lua environment
    local PlayerActions = getgenv().PlayerActions
    PlayerActions:AddButton('Activate Ragebot', function()
        print("[GUI] Activate Ragebot clicked!")
        -- Logic to enable/disable ragebot (to be implemented in ragebot.lua)
    end)

    PlayerActions:AddToggle('Ragebot Active', {
        Text = 'Ragebot Active',
        Default = false,
        Callback = function(state)
            print("[GUI] Ragebot Active set to: " .. tostring(state))
            -- Logic to be implemented in ragebot.lua
        end,
    })
end

-- Call the function to add controls
addRagebotControls()
