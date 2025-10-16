-- ragebot.lua
-- Remote module factory for ragebot controls (UI + state machine only)
return function(env)
    -- Extract dependencies from the provided environment
    local Services = env.Services
    local Players = Services:GetService("Players")
    local Tabs = env.Tabs
    local Options = env.Options or {}
    local Library = env.Library
    local UserInputService = env.UserInputService

    -- State management
    local ragebotEnabled = false
    local ragebotViewEnabled = false
    local selectedRageTarget = nil

    -- Single persistent updater loop
    local cameraLoop
    local function startCameraLoop()
        if not cameraLoop then
            cameraLoop = task.spawn(function()
                while true do
                    if ragebotEnabled and ragebotViewEnabled and selectedRageTarget then
                        local target = Players:FindFirstChild(selectedRageTarget)
                        if target and target.Character and target.Character:FindFirstChild("Humanoid") then
                            workspace.CurrentCamera.CameraSubject = target.Character.Humanoid
                        end
                    else
                        local lp = Players.LocalPlayer
                        if lp and lp.Character and lp.Character:FindFirstChildOfClass("Humanoid") then
                            workspace.CurrentCamera.CameraSubject = lp.Character.Humanoid
                        end
                    end
                    task.wait(0.15)
                end
            end)
        end
    end

    local function stopCameraLoop()
        if cameraLoop then
            task.cancel(cameraLoop)
            cameraLoop = nil
        end
    end

    -- API to expose
    local api = {}

    api.Init = function()
        print("[RAGEBOT] Initializing ragebot module...")

        -- Add controls to the Ragebot groupbox
        if Tabs and Tabs.Players and getgenv().RagebotBox then
            getgenv().RagebotBox = Tabs.Players:AddRightGroupbox('Ragebot') -- Ensure groupbox exists
            getgenv().RagebotBox:AddToggle('RagebotToggle', {
                Text = 'Enable Ragebot',
                Default = false,
                Callback = function(state)
                    ragebotEnabled = state
                    print("[RAGEBOT] Ragebot toggled to: " .. tostring(state))
                    if state then
                        startCameraLoop()
                    else
                        stopCameraLoop()
                    end
                end
            }):AddKeyPicker('RagebotKey', {
                Default = 'R',
                Text = 'Ragebot Key',
                Mode = 'Toggle',
                Callback = function(state)
                    if UserInputService:GetFocusedTextBox() then return end
                    ragebotEnabled = state
                    print("[RAGEBOT] Ragebot toggled by key to: " .. tostring(state))
                    if state then
                        startCameraLoop()
                    else
                        stopCameraLoop()
                    end
                end
            })

            getgenv().RagebotBox:AddDropdown('RageTarget', {
                SpecialType = 'Player',
                Text = 'Select Ragebot Target',
                Tooltip = 'Select a player to lock the view on when Ragebot is active.',
                Callback = function(value)
                    selectedRageTarget = value
                    print("[RAGEBOT] Ragebot target set to: " .. tostring(value))
                end,
            })

            getgenv().RagebotBox:AddToggle('RagebotView', {
                Text = 'View Target',
                Default = false,
                Callback = function(state)
                    ragebotViewEnabled = state
                    print("[RAGEBOT] Ragebot View toggled to: " .. tostring(state))
                    if state and ragebotEnabled then
                        startCameraLoop()
                    elseif not state then
                        stopCameraLoop()
                    end
                end,
            })
        else
            warn("[RAGEBOT] Failed to initialize GUI controls, Tabs or RagebotBox not available!")
        end

        -- Auto-refresh player list
        Players.PlayerAdded:Connect(function()
            local names = {}
            for _, plr in pairs(Players:GetPlayers()) do
                table.insert(names, plr.Name)
            end
            if Options.RageTarget and Options.RageTarget.Values then
                Options.RageTarget.Values = names
            end
        end)

        Players.PlayerRemoving:Connect(function()
            local names = {}
            for _, plr in pairs(Players:GetPlayers()) do
                table.insert(names, plr.Name)
            end
            if Options.RageTarget and Options.RageTarget.Values then
                Options.RageTarget.Values = names
            end
        end)
    end

    api.Shutdown = function()
        stopCameraLoop()
        print("[RAGEBOT] Ragebot module shut down.")
    end

    return api
end
