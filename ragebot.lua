-- Anti Lock Void script using LinoriaLib
local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local Window = Library:CreateWindow({ Title = 'Anti Lock Void | priv71', AutoShow = true, TabPadding = 15, MenuFadeTime = 0.2 })
local Tabs = { Main = Window:AddTab('Main') }
local AntiLockBox = Tabs.Main:AddRightGroupbox('Anti Lock Void')

-- Services
getgenv().Services = {
    Players = game:GetService("Players"),
    LocalPlayer = game:GetService("Players").LocalPlayer,
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    RunService = game:GetService("RunService")
}

-- Initialize globals
getgenv().AntiLockEnabled = false
getgenv().SelectedTarget = nil
getgenv().LastFireTime = 0
getgenv().LastReloadTime = 0
getgenv().EquippedAug = nil
getgenv().AntiLockSetback = Instance.new("Part")
getgenv().AntiLockSetback.Name = "AntiLock Setback"
getgenv().AntiLockSetback.Parent = workspace
getgenv().AntiLockSetback.Size = Vector3.new(2, 2, 1)
getgenv().AntiLockSetback.CanCollide = false
getgenv().AntiLockSetback.Anchored = true
getgenv().AntiLockSetback.Transparency = 1
print("[AntiLock] Setback created")

-- Disable Desync from main.lua if present
if getgenv().desync then
    getgenv().desync.enabled = false
    print("[AntiLock] Disabled main.lua Desync to avoid conflicts")
end

-- Function to buy Aug or ammo
local function buyItem(itemName)
    local player = getgenv().Services.LocalPlayer
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        print("[AntiLock] Failed to buy item: Character or HumanoidRootPart missing")
        return false
    end
    local success, shopFolder = pcall(function()
        return workspace:WaitForChild("Ignored"):WaitForChild("Shop")
    end)
    if not success or not shopFolder then
        print("[AntiLock] Failed to find shop folder:", tostring(shopFolder))
        return false
    end
    for _, item in pairs(shopFolder:GetChildren()) do
        if item.Name == itemName then
            local itemHead = item:FindFirstChild("Head")
            if itemHead then
                local originalPosition = player.Character.HumanoidRootPart.CFrame
                for _, tool in pairs(player.Character:GetChildren()) do
                    if tool:IsA("Tool") then
                        tool.Parent = player.Backpack
                    end
                end
                player.Character.HumanoidRootPart.CFrame = itemHead.CFrame + Vector3.new(0, 3.2, 0)
                task.wait(0.1)
                local clickDetector = item:FindFirstChild("ClickDetector")
                if clickDetector then
                    for i = 1, 3 do
                        pcall(function()
                            fireclickdetector(clickDetector)
                        end)
                        task.wait(0.1)
                    end
                    print("[AntiLock] Purchased " .. itemName)
                end
                player.Character.HumanoidRootPart.CFrame = originalPosition
                task.wait(0.5)
                return true
            end
            break
        end
    end
    print("[AntiLock] Failed to find " .. itemName .. " in shop")
    return false
end

-- Function to get ammo count
local function getAmmoCount()
    local player = getgenv().Services.LocalPlayer
    local inventory = player:FindFirstChild("DataFolder") and player.DataFolder:FindFirstChild("Inventory")
    local ammo = inventory and inventory:FindFirstChild("[AUG]")
    if ammo then
        return tonumber(ammo.Value) or 0
    end
    return 0
end

-- Function to equip Aug
local function equipAug()
    local player = getgenv().Services.LocalPlayer
    if not player.Character or not player.Backpack then
        print("[AntiLock] Failed to equip Aug: Character or Backpack missing")
        return nil
    end
    for _, tool in pairs(player.Backpack:GetChildren()) do
        if tool.Name == "[AUG]" then
            tool.Parent = player.Character
            print("[AntiLock] Equipped [AUG]")
            task.wait(0.5)
            getgenv().EquippedAug = tool
            return tool
        end
    end
    for _, tool in pairs(player.Character:GetChildren()) do
        if tool.Name == "[AUG]" then
            print("[AntiLock] [AUG] already equipped")
            getgenv().EquippedAug = tool
            return tool
        end
    end
    if buyItem("[AUG] - $2131") then
        for _, tool in pairs(player.Backpack:GetChildren()) do
            if tool.Name == "[AUG]" then
                tool.Parent = player.Character
                print("[AntiLock] Equipped [AUG] after purchase")
                task.wait(0.5)
                getgenv().EquippedAug = tool
                return tool
            end
        end
    end
    print("[AntiLock] No [AUG] found")
    return nil
end

-- Function to check and reload ammo
local function reloadAug()
    local player = getgenv().Services.LocalPlayer
    if not player.Character or not getgenv().EquippedAug or not getgenv().EquippedAug:FindFirstChild("Ammo") then
        print("[AntiLock] Failed to reload Aug: Character or Ammo missing")
        return false
    end
    local ammo = getgenv().EquippedAug.Ammo.Value
    if ammo <= 0 then
        local ammoCount = getAmmoCount()
        if ammoCount <= 0 then
            if not buyItem("90 [AUG Ammo] - $87") then
                print("[AntiLock] Failed to purchase [AUG] ammo")
                return false
            end
            print("[AntiLock] Purchased [AUG] ammo")
        end
        pcall(function()
            getgenv().Services.ReplicatedStorage.MainEvent:FireServer("Reload", getgenv().EquippedAug)
            print("[AntiLock] Reloading [AUG]")
        end)
        getgenv().LastReloadTime = tick()
        task.wait(3.7)
        return true
    end
    return true
end

-- Checkbox for enabling/disabling Anti Lock Void
AntiLockBox:AddToggle('AntiLockToggle', {
    Text = 'Enable Anti Lock Void',
    Default = false,
    Tooltip = 'Enable or disable the Anti Lock Void functionality.',
    Callback = function(state)
        getgenv().AntiLockEnabled = state
        if getgenv().AntiLockEnabled then
            if getgenv().SelectedTarget then
                local tool = equipAug()
                if not tool then
                    getgenv().AntiLockEnabled = false
                    pcall(function() AntiLockBox.Toggles.AntiLockToggle:SetValue(false) end)
                    print("[AntiLock] Failed to equip [AUG]")
                    return
                end
                print("[AntiLock] Enabled for target: " .. tostring(getgenv().SelectedTarget))
                task.wait(2) -- Wait 2 seconds to stabilize
            else
                getgenv().AntiLockEnabled = false
                pcall(function() AntiLockBox.Toggles.AntiLockToggle:SetValue(false) end)
                print("[AntiLock] No target selected")
            end
        else
            getgenv().EquippedAug = nil
            if getgenv().Services.LocalPlayer.Character then
                workspace.CurrentCamera.CameraSubject = getgenv().Services.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            end
            print("[AntiLock] Disabled")
        end
    end
})

-- Dropdown: list of all players
getgenv().AntiLockDropdown = AntiLockBox:AddDropdown('AntiLockTarget', {
    SpecialType = 'Player',
    Text = 'Select Target',
    Tooltip = 'Select a player to teleport above and apply Kill Aura.',
    Callback = function(value)
        getgenv().SelectedTarget = value
        print("[AntiLock] Selected target:", tostring(value))
        if getgenv().AntiLockEnabled and getgenv().SelectedTarget then
            local tool = equipAug()
            if not tool then
                getgenv().AntiLockEnabled = false
                pcall(function() AntiLockBox.Toggles.AntiLockToggle:SetValue(false) end)
                print("[AntiLock] Failed to equip [AUG]")
                return
            end
            print("[AntiLock] Target set to: " .. tostring(value))
            task.wait(2) -- Wait 2 seconds to stabilize
        elseif getgenv().AntiLockEnabled then
            getgenv().AntiLockEnabled = false
            getgenv().EquippedAug = nil
            pcall(function() AntiLockBox.Toggles.AntiLockToggle:SetValue(false) end)
            if getgenv().Services.LocalPlayer.Character then
                workspace.CurrentCamera.CameraSubject = getgenv().Services.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            end
            print("[AntiLock] Disabled: No target selected")
        end
    end
})

-- Auto-refresh player list
getgenv().Services.Players.PlayerAdded:Connect(function()
    local names = {}
    for _, plr in pairs(getgenv().Services.Players:GetPlayers()) do
        table.insert(names, plr.Name)
    end
    pcall(function()
        getgenv().AntiLockDropdown:SetValues(names)
        print("[AntiLock] Player list updated on join:", table.concat(names, ", "))
    end)
end)

getgenv().Services.Players.PlayerRemoving:Connect(function()
    local names = {}
    for _, plr in pairs(getgenv().Services.Players:GetPlayers()) do
        table.insert(names, plr.Name)
    end
    pcall(function()
        getgenv().AntiLockDropdown:SetValues(names)
        if getgenv().SelectedTarget and not getgenv().Services.Players:FindFirstChild(getgenv().SelectedTarget) then
            getgenv().SelectedTarget = nil
            getgenv().AntiLockEnabled = false
            getgenv().EquippedAug = nil
            pcall(function() AntiLockBox.Toggles.AntiLockToggle:SetValue(false) end)
            if getgenv().Services.LocalPlayer.Character then
                workspace.CurrentCamera.CameraSubject = getgenv().Services.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            end
            print("[AntiLock] Selected player left the game")
        end
        print("[AntiLock] Player list updated on leave:", table.concat(names, ", "))
    end)
end)

-- Desync logic (copied from Void mode, adapted for 100 studs above target)
local DesyncConnection
DesyncConnection = getgenv().Services.RunService.Heartbeat:Connect(function()
    if getgenv().AntiLockEnabled and getgenv().SelectedTarget then
        local targetPlayer = getgenv().Services.Players:FindFirstChild(getgenv().SelectedTarget)
        local player = getgenv().Services.LocalPlayer
        if targetPlayer and targetPlayer.Character and player.Character then
            local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                local oldPosition = rootPart.CFrame
                local targetRootPart = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                if targetRootPart then
                    local teleportPosition = Vector3.new(
                        targetRootPart.Position.X,
                        targetRootPart.Position.Y + 100,
                        targetRootPart.Position.Z
                    )
                    pcall(function()
                        rootPart.CFrame = CFrame.new(teleportPosition)
                        workspace.CurrentCamera.CameraSubject = getgenv().AntiLockSetback
                        getgenv().Services.RunService.RenderStepped:Wait()
                        getgenv().AntiLockSetback.CFrame = oldPosition * CFrame.new(0, rootPart.Size.Y / 2 + 0.5, 0)
                        rootPart.CFrame = oldPosition
                        print("[AntiLock] Teleported to:", teleportPosition, "Returned to:", oldPosition.Position)
                    end)
                end
            end
        end
    end
end)

-- Kill Aura and autoreload logic (separate loop)
local KillAuraConnection
KillAuraConnection = getgenv().Services.RunService.Heartbeat:Connect(function()
    if getgenv().AntiLockEnabled and getgenv().SelectedTarget and getgenv().EquippedAug then
        local targetPlayer = getgenv().Services.Players:FindFirstChild(getgenv().SelectedTarget)
        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Head") then
            local targetHead = targetPlayer.Character.Head
            if tick() - getgenv().LastFireTime >= 0.1 and tick() - getgenv().LastReloadTime >= 3.7 then
                if not reloadAug() then
                    print("[AntiLock] Failed to reload [AUG] ammo, retrying...")
                    getgenv().EquippedAug = equipAug()
                end
                if getgenv().EquippedAug and getgenv().EquippedAug:FindFirstChild("Handle") and getgenv().EquippedAug:FindFirstChild("Ammo") and getgenv().EquippedAug.Ammo.Value > 0 then
                    pcall(function()
                        getgenv().Services.ReplicatedStorage.MainEvent:FireServer(
                            "ShootGun",
                            getgenv().EquippedAug:FindFirstChild("Handle"),
                            getgenv().EquippedAug:FindFirstChild("Handle").CFrame.Position,
                            targetHead.Position,
                            targetHead,
                            Vector3.new(0, 0, -1)
                        )
                        print("[AntiLock] Fired at target:", getgenv().SelectedTarget)
                    end)
                    getgenv().LastFireTime = tick()
                end
            end
        end
    end
end)

-- Unload handler
Library:OnUnload(function()
    if DesyncConnection then DesyncConnection:Disconnect() end
    if KillAuraConnection then KillAuraConnection:Disconnect() end
    print("[AntiLock] Unloaded!")
    Library.Unloaded = true
end)

print("[AntiLock] Initialized successfully")
