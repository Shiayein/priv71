-- gui_extensions.lua
-- Add ragebot controls to the Players tab
local Tabs = getfenv(0).Tabs -- Access tabs from main.lua environment
local maxAttempts = 5 -- Limit the number of retry attempts
local attempt = 0

-- Function to add ragebot controls with retry logic
local function addRagebotControls()
    attempt = attempt + 1
    if attempt > maxAttempts then
        warn("[GUI] Failed to initialize ragebot controls after " .. maxAttempts .. " attempts!")
        return
    end

    if not Tabs or not Tabs.Players or not getgenv().PlayerActions then
        warn("[GUI] Waiting for PlayerActions to be initialized... (Attempt " .. attempt .. " of " .. maxAttempts .. ")")
        wait(0.2) -- Delay before retry
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
