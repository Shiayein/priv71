-- gui_extensions.lua
-- Add ragebot controls to the Players tab
local Tabs = getfenv(0).Tabs -- Access tabs from main.lua environment

-- Check and use the PlayerActions groupbox in the Players tab
if Tabs.Players and getgenv().PlayerActions then
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
else
    warn("[GUI] PlayerActions groupbox not found in Tabs.Players! Waiting for main.lua initialization...")
    -- Optional delay to wait for main.lua to initialize Tabs
    wait(0.1) -- Small delay to allow Tabs to be set
    if Tabs.Players and getgenv().PlayerActions then
        getgenv().PlayerActions:AddButton('Activate Ragebot', function()
            print("[GUI] Activate Ragebot clicked!")
        end)
        getgenv().PlayerActions:AddToggle('Ragebot Active', {
            Text = 'Ragebot Active',
            Default = false,
            Callback = function(state)
                print("[GUI] Ragebot Active set to: " .. tostring(state))
            end,
        })
    else
        warn("[GUI] Failed to initialize ragebot controls after delay!")
    end
end
