-- gui_extensions.lua
-- Add ragebot controls to the Players tab
local Tabs = getfenv(0).Tabs -- Access tabs from main.lua environment

-- Wait for PlayerActions to be available
local function addRagebotControls()
    if not Tabs or not Tabs.Players or not getgenv().PlayerActions then
        warn("[GUI] Waiting for PlayerActions to be initialized...")
        wait(0.2) -- Increase delay to ensure initialization
        addRagebotControls() -- Retry
        return
    end

    -- Add a button to activate the ragebot
    getgenv().PlayerActions:AddButton('Activate Ragebot', function()
        print("[GUI] Activate Ragebot clicked!")
        -- Logic to enable/disable ragebot (to be implemented in ragebot.lua)
    end)

    -- Add a toggle to enable/disable the ragebot
    getgenv().PlayerActions:AddToggle('Ragebot Active', {
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
