-- gui_extensions.lua
local Tabs = getfenv(0).Tabs -- Accède aux onglets définis dans main.lua
local Services = game:GetService("Players") -- Utilisé pour trouver des joueurs

-- Vérifier et utiliser le groupbox Player Actions dans l'onglet Players
if Tabs.Players and getgenv().PlayerActions then
    -- Ajouter un bouton pour activer le ragebot
    getgenv().PlayerActions:AddButton('Activate Ragebot', function()
        print("[GUI] Activate Ragebot clicked!")
        -- Logique à activer/désactiver le ragebot (à implémenter dans ragebot.lua)
    end)

    -- Ajouter un toggle pour activer/désactiver le ragebot
    getgenv().PlayerActions:AddToggle('Ragebot Active', {
        Text = 'Ragebot Active',
        Default = false,
        Callback = function(state)
            print("[GUI] Ragebot Active set to: " .. tostring(state))
            -- Logique à implémenter dans ragebot.lua
        end,
    })
else
    warn("[GUI] PlayerActions groupbox not found in Tabs.Players!")
end
