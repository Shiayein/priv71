-- ragebot.lua
-- Remote module factory for ragebot controls (no combat logic, UI + state machine only)
return function(env)
    -- Extract dependencies from the provided environment
    local Services = env.Services
    local Players = Services:GetService("Players")
    local Tabs = env.Tabs
    local Options = env.Options or {}
    local Library = env.Library

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

        -- Add controls to the Players tab
        if Tabs and Tabs.Players and getgenv().PlayerActions then
            getgenv().PlayerActions:AddToggle('Ragebot Enabled', {
                Text = 'Ragebot Enabled',
                Default = false,
                Callback = function(state)
                    ragebotEnabled = state
                    print("[RAGEBOT] Ragebot toggled to: " .. tostring(state))
                    if state then
                        startCameraLoop()
                    else
                        stopCameraLoop()
                    end
                end,
            })

            getgenv().PlayerActions:AddToggle('Ragebot View', {
                Text = 'Ragebot View',
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

            getgenv().PlayerActions:AddDropdown('Ragebot Target', {
                Values = Players:GetPlayers():GetMap(function(p) return p.Name end),
                Default = "",
                Callback = function(value)
                    selectedRageTarget = value
                    print("[RAGEBOT] Ragebot target set to: " .. tostring(value))
                end,
            })
        else
            warn("[RAGEBOT] Failed to initialize GUI controls, Tabs or PlayerActions not available!")
        end
    end

    api.Shutdown = function()
        stopCameraLoop()
        print("[RAGEBOT] Ragebot module shut down.")
    end

    return api
end
