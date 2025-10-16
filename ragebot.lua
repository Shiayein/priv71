-- ==============================
-- OPTIMIZED RAGEBOT SECTION
-- ==============================

-- == Helper functions ==
-- === SAFETY INIT ===
local Services = Services or setmetatable({}, {
    __index = function(_, service)
        return game:GetService(service)
    end
})

local Players = Services.Players
local LocalPlayer = Players.LocalPlayer
local UserInputService = Services.UserInputService
local Workspace = Services.Workspace

local function ResetCamera()
    local lp = Services.LocalPlayer
    if lp and lp.Character then
        local humanoid = lp.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            workspace.CurrentCamera.CameraSubject = humanoid
        end
    end
end

local function SetCameraToTarget()
    local targetName = getgenv().SelectedRageTarget
    if not targetName then return end
    local target = Services.Players:FindFirstChild(targetName)
    if target and target.Character then
        local humanoid = target.Character:FindFirstChild("Humanoid")
        if humanoid then
            workspace.CurrentCamera.CameraSubject = humanoid
        end
    end
end

local function UpdatePlayerList()
    local names = {}
    for _, plr in pairs(Services.Players:GetPlayers()) do
        table.insert(names, plr.Name)
    end
    if Options and Options.RageTarget then
        Options.RageTarget.Values = names
    end
end

-- == GUI ==
getgenv().RagebotBox = Tabs.Players:AddRightGroupbox('Ragebot')

getgenv().RagebotBox:AddToggle('RagebotToggle', {
    Text = 'Enable Ragebot',
    Default = false,
    Callback = function(state)
        getgenv().RagebotEnabled = state
        if state and getgenv().RagebotViewEnabled then
            SetCameraToTarget()
        else
            ResetCamera()
        end
    end
}):AddKeyPicker('RagebotKey', {
    Default = 'R',
    Text = 'Ragebot Key',
    Mode = 'Toggle',
    Callback = function(state)
        if UserInputService:GetFocusedTextBox() then return end
        getgenv().RagebotEnabled = state
        if state and getgenv().RagebotViewEnabled then
            SetCameraToTarget()
        else
            ResetCamera()
        end
    end
})

getgenv().RagebotDropdown = getgenv().RagebotBox:AddDropdown('RageTarget', {
    SpecialType = 'Player',
    Text = 'Select Ragebot Target',
    Tooltip = 'Select a player to lock the view on when Ragebot is active.',
    Callback = function(value)
        getgenv().SelectedRageTarget = value
        if getgenv().RagebotEnabled and getgenv().RagebotViewEnabled then
            SetCameraToTarget()
        end
    end,
})

getgenv().RagebotBox:AddToggle('RagebotView', {
    Text = 'View Target',
    Default = false,
    Callback = function(state)
        getgenv().RagebotViewEnabled = state
        if not state then
            ResetCamera()
            if getgenv().RagebotThread then
                task.cancel(getgenv().RagebotThread)
                getgenv().RagebotThread = nil
            end
            return
        end

        -- cancel previous thread safely
        if getgenv().RagebotThread then
            task.cancel(getgenv().RagebotThread)
        end

        -- start one single persistent thread
        getgenv().RagebotThread = task.spawn(function()
            while getgenv().RagebotViewEnabled do
                if getgenv().RagebotEnabled then
                    SetCameraToTarget()
                end
                task.wait(0.2)
            end
            ResetCamera()
        end)
    end,
})

-- == Auto refresh player list ==
Services.Players.PlayerAdded:Connect(UpdatePlayerList)
Services.Players.PlayerRemoving:Connect(UpdatePlayerList)
UpdatePlayerList()
