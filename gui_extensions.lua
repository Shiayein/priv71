-- gui_extensions.lua
local Tabs = getfenv(0).Tabs -- Accède aux onglets définis dans main.lua

-- Utiliser le groupbox Player Actions existant dans l'onglet Players
if Tabs.Players and getgenv().PlayerActions then
    -- Ajouter un bouton pour le ragebot
    getgenv().PlayerActions:AddButton('Toggle Ragebot', function()
        print("[GUI] Toggle Ragebot clicked!")
        -- Logique à activer/désactiver le ragebot (à implémenter dans ragebot.lua)
    end)

    -- Ajouter un toggle pour activer/désactiver le ragebot
    getgenv().PlayerActions:AddToggle('Ragebot Enabled', {
        Text = "Ragebot Enabled",
        Default = false,
        Callback = function(Value)
            print("[GUI] Ragebot Enabled set to: " .. tostring(Value))
            -- Logique à implémenter dans ragebot.lua
        end
    })
else
    warn("[GUI] PlayerActions groupbox not found in Tabs.Players!")
end
