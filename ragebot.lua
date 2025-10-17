-- Ragebot script using LinoriaLib
local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local Window = Library:CreateWindow({ Title = 'Ragebot | priv71', AutoShow = true, TabPadding = 15, MenuFadeTime = 0.2 })
local Tabs = { Main = Window:AddTab('Main') }
local RagebotBox = Tabs.Main:AddRightGroupbox('Ragebot')

-- Services
getgenv().Services = {
    Players = game:GetService("Players"),
    LocalPlayer = game:GetService("Players").LocalPlayer,
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    RunService = game:GetService("RunService")
}

-- Initialize globals
getgenv().RagebotEnabled = false
getgenv().ViewEnabled = false
getgenv().SelectedTarget = nil
getgenv().LastFireTime = 0
getgenv().LastReloadTime = 0
getgenv().EquippedAug = nil
getgenv().DesyncPaused = false
getgenv().RagebotSetback = Instance.new("Part")
getgenv().RagebotSetback.Name = "Ragebot Setback"
getgenv().RagebotSetback.Parent = workspace
getgenv().RagebotSetback.Size = Vector3.new(2, 2, 1)
getgenv().RagebotSetback.CanCollide = false
getgenv().RagebotSetback.Anchored = true
getgenv().RagebotSetback.Transparency = 1
print("[Ragebot] Setback created")

-- Disable Desync from main.lua if present
if getgenv().desync then
    getgenv().desync.enabled = false
    print("[Ragebot] Disabled main.lua Desync to avoid conflicts")
end

-- Function to buy Aug or ammo
local function buyItem(itemName)
    local player = getgenv().Services.LocalPlayer
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        print("[Ragebot] Failed to buy item: Character or HumanoidRootPart missing")
        return false
    end
    local success, shopFolder = pcall(function()
        return workspace:WaitForChild("Ignored"):WaitForChild("Shop")
    end)
    if not success or not shopFolder then
        print("[Ragebot] Failed to find shop folder:", tostring(shopFolder))
        return false
    end
    for _, item in pairs(shopFolder:GetChildren()) do
        if item.Name == itemName then
            local itemHead = item:FindFirstChild("Head")
            if itemHead then
                getgenv().DesyncPaused = true -- Pause desync
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
                    print("[Ragebot] Purchased " .. itemName)
                end
                player.Character.HumanoidRootPart.CFrame = originalPosition
                task.wait(0.5)
                getgenv().DesyncPaused = false -- Resume desync
                return true
            end
            break
        end
    end
    print("[Ragebot] Failed to find " .. itemName .. " in shop")
    getgenv().DesyncPaused = false -- Resume desync in case of failure
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
        print("[Ragebot] Failed to equip Aug: Character or Backpack missing")
        return nil
    end
    for _, tool in pairs(player.Backpack:GetChildren()) do
        if tool.Name == "[AUG]" then
            tool.Parent = player.Character
            print("[Ragebot] Equipped [AUG]")
            task.wait(0.5)
            getgenv().EquippedAug = tool
            return tool
        end
    end
    for _, tool in pairs(player.Character:GetChildren()) do
        if tool.Name == "[AUG]" then
            print("[Ragebot] [AUG] already equipped")
            getgenv().EquippedAug = tool
            return tool
        end
    end
    if buyItem("[AUG] - $2131") then
        for _, tool in pairs(player.Backpack:GetChildren()) do
            if tool.Name == "[AUG]" then
                tool.Parent = player.Character
                print("[Ragebot] Equipped [AUG] after purchase")
                task.wait(0.5)
                getgenv().EquippedAug = tool
                return tool
            end
        end
    end
    print("[Ragebot] No [AUG] found")
    return nil
end

-- Function to check and reload ammo
local function reloadAug()
    local player = getgenv().Services.LocalPlayer
    if not player.Character or not getgenv().EquippedAug or not getgenv().EquippedAug:FindFirstChild("Ammo") then
        print("[Ragebot] Failed to reload Aug: Character or Ammo missing")
        return false
    end
    local ammo = getgenv().EquippedAug.Ammo.Value
    if ammo <= 0 then
        local ammoCount = getAmmoCount()
        if ammoCount <= 0 then
            if not buyItem("90 [AUG Ammo] - $87") then
                print("[Ragebot] Failed to purchase [AUG] ammo")
                return false
            end
            print("[Ragebot] Purchased [AUG] ammo")
        end
        pcall(function()
            getgenv().Services.ReplicatedStorage.MainEvent:FireServer("Reload", getgenv().EquippedAug)
            print("[Ragebot] Reloading [AUG]")
        end)
        getgenv().LastReloadTime = tick()
        task.wait(3.7)
        return true
    end
    return true
end

-- Checkbox for enabling/disabling Ragebot
RagebotBox:AddToggle('RagebotToggle', {
    Text = 'Enable Ragebot',
    Default = false,
    Tooltip = 'Enable or disable the Ragebot functionality.',
    Callback = function(state)
        getgenv().RagebotEnabled = state
        if getgenv().RagebotEnabled then
            if getgenv().SelectedTarget then
                local tool = equipAug()
                if not tool then
                    getgenv().RagebotEnabled = false
                    pcall(function() RagebotBox.Toggles.RagebotToggle:SetValue(false) end)
                    print("[Ragebot] Failed to equip [AUG]")
                    return
                end
                print("[Ragebot] Enabled for target: " .. tostring(getgenv().SelectedTarget))
                task.wait(2) -- Wait 2 seconds to stabilize
            else
                getgenv().RagebotEnabled = false
                pcall(function() RagebotBox.Toggles.RagebotToggle:SetValue(false) end)
                print("[Ragebot] No target selected")
            end
        else
            getgenv().EquippedAug = nil
            getgenv().DesyncPaused = false
            getgenv().ViewEnabled = false
            pcall(function() RagebotBox.Toggles.ViewToggle:SetValue(false) end)
            if getgenv().Services.LocalPlayer.Character then
                workspace.CurrentCamera.CameraSubject = getgenv().Services.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            end
            print("[Ragebot] Disabled")
        end
    end
})

-- Toggle for viewing the target
RagebotBox:AddToggle('ViewToggle', {
    Text = 'View Target',
    Default = false,
    Tooltip = 'Lock camera on the selected Ragebot target.',
    Callback = function(state)
        getgenv().ViewEnabled = state
        if not getgenv().RagebotEnabled or not getgenv().SelectedTarget then
            getgenv().ViewEnabled = false
            pcall(function() RagebotBox.Toggles.ViewToggle:SetValue(false) end)
            if getgenv().Services.LocalPlayer.Character then
                workspace.CurrentCamera.CameraSubject = getgenv().Services.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            end
            print("[Ragebot] View disabled: Ragebot or target not set")
            return
        end
        if state then
            local targetPlayer = getgenv().Services.Players:FindFirstChild(getgenv().SelectedTarget)
            if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Humanoid") then
                workspace.CurrentCamera.CameraSubject = targetPlayer.Character.Humanoid
                print("[Ragebot] Viewing target: " .. tostring(getgenv().SelectedTarget))
            else
                getgenv().ViewEnabled = false
                pcall(function() RagebotBox.Toggles.ViewToggle:SetValue(false) end)
                if getgenv().Services.LocalPlayer.Character then
                    workspace.CurrentCamera.CameraSubject = getgenv().Services.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                end
                print("[Ragebot] No valid target for view")
            end
        else
            if getgenv().Services.LocalPlayer.Character then
                workspace.CurrentCamera.CameraSubject = getgenv().Services.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            end
            print("[Ragebot] View disabled")
        end
    end
})

-- Dropdown: list of all players
getgenv().RagebotDropdown = RagebotBox:AddDropdown('RagebotTarget', {
    SpecialType = 'Player',
    Text = 'Select Target',
    Tooltip = 'Select a player to teleport above and apply Kill Aura.',
    Callback = function(value)
        getgenv().SelectedTarget = value
        print("[Ragebot] Selected target:", tostring(value))
        if getgenv().RagebotEnabled and getgenv().SelectedTarget then
            local tool = equipAug()
            if not tool then
                getgenv().RagebotEnabled = false
                pcall(function() RagebotBox.Toggles.RagebotToggle:SetValue(false) end)
                print("[Ragebot] Failed to equip [AUG]")
                return
            end
            print("[Ragebot] Target set to: " .. tostring(value))
            task.wait(2) -- Wait 2 seconds to stabilize
        elseif getgenv().RagebotEnabled then
            getgenv().RagebotEnabled = false
            getgenv().EquippedAug = nil
            getgenv().DesyncPaused = false
            getgenv().ViewEnabled = false
            pcall(function() RagebotBox.Toggles.ViewToggle:SetValue(false) end)
            pcall(function() RagebotBox.Toggles.RagebotToggle:SetValue(false) end)
            if getgenv().Services.LocalPlayer.Character then
                workspace.CurrentCamera.CameraSubject = getgenv().Services.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            end
            print("[Ragebot] Disabled: No target selected")
        end
    end
})

-- Handle character respawn
getgenv().Services.Players.LocalPlayer.CharacterAdded:Connect(function(character)
    if getgenv().RagebotEnabled and getgenv().SelectedTarget then
        print("[Ragebot] Character respawned, re-equipping Aug")
        task.wait(2) -- Wait for character to stabilize
        local tool = equipAug()
        if not tool then
            getgenv().RagebotEnabled = false
            getgenv().ViewEnabled = false
            pcall(function() RagebotBox.Toggles.RagebotToggle:SetValue(false) end)
            pcall(function() RagebotBox.Toggles.ViewToggle:SetValue(false) end)
            print("[Ragebot] Failed to equip [AUG] after respawn")
            return
        end
        print("[Ragebot] Re-equipped [AUG] after respawn")
    end
end)

-- Auto-refresh player list
getgenv().Services.Players.PlayerAdded:Connect(function()
    local names = {}
    for _, plr in pairs(getgenv().Services.Players:GetPlayers()) do
        table.insert(names, plr.Name)
    end
    pcall(function()
        getgenv().RagebotDropdown:SetValues(names)
        print("[Ragebot] Player list updated on join:", table.concat(names, ", "))
    end)
end)

getgenv().Services.Players.PlayerRemoving:Connect(function()
    local names = {}
    for _, plr in pairs(getgenv().Services.Players:GetPlayers()) do
        table.insert(names, plr.Name)
    end
    pcall(function()
        getgenv().RagebotDropdown:SetValues(names)
        if getgenv().SelectedTarget and not getgenv().Services.Players:FindFirstChild(getgenv().SelectedTarget) then
            getgenv().SelectedTarget = nil
            getgenv().RagebotEnabled = false
            getgenv().EquippedAug = nil
            getgenv().DesyncPaused = false
            getgenv().ViewEnabled = false
            pcall(function() RagebotBox.Toggles.RagebotToggle:SetValue(false) end)
            pcall(function() RagebotBox.Toggles.ViewToggle:SetValue(false) end)
            if getgenv().Services.LocalPlayer.Character then
                workspace.CurrentCamera.CameraSubject = getgenv().Services.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            end
            print("[Ragebot] Selected player left the game")
        end
        print("[Ragebot] Player list updated on leave:", table.concat(names, ", "))
    end)
end)

-- Desync logic (copied from Void mode, adapted for 100 studs above target)
local DesyncConnection
DesyncConnection = getgenv().Services.RunService.Heartbeat:Connect(function()
    if getgenv().RagebotEnabled and getgenv().SelectedTarget and not getgenv().DesyncPaused and getgenv().EquippedAug then
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
                        if not getgenv().ViewEnabled then
                            workspace.CurrentCamera.CameraSubject = getgenv().RagebotSetback
                        end
                        getgenv().Services.RunService.RenderStepped:Wait()
                        getgenv().RagebotSetback.CFrame = oldPosition * CFrame.new(0, rootPart.Size.Y / 2 + 0.5, 0)
                        rootPart.CFrame = oldPosition
                    end)
                end
            end
        end
    end
end)

-- Kill Aura and autoreload logic (shoot from 100 studs with dynamic direction)
local KillAuraConnection
KillAuraConnection = getgenv().Services.RunService.RenderStepped:Connect(function()
    if getgenv().RagebotEnabled and getgenv().SelectedTarget and not getgenv().DesyncPaused then
        local targetPlayer = getgenv().Services.Players:FindFirstChild(getgenv().SelectedTarget)
        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Head") then
            local targetHead = targetPlayer.Character.Head
            local targetRootPart = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            if tick() - getgenv().LastFireTime >= 0.1 and tick() - getgenv().LastReloadTime >= 3.7 and targetRootPart then
                if not getgenv().EquippedAug or not getgenv().EquippedAug.Parent or not getgenv().EquippedAug:FindFirstChild("Handle") or not getgenv().EquippedAug:FindFirstChild("Ammo") then
                    getgenv().EquippedAug = equipAug()
                end
                if getgenv().EquippedAug and getgenv().EquippedAug:FindFirstChild("Handle") and getgenv().EquippedAug:FindFirstChild("Ammo") then
                    if not reloadAug() then
                        print("[Ragebot] Failed to reload [AUG] ammo, retrying...")
                        getgenv().EquippedAug = equipAug()
                    end
                    if getgenv().EquippedAug and getgenv().EquippedAug:FindFirstChild("Handle") and getgenv().EquippedAug:FindFirstChild("Ammo") and getgenv().EquippedAug.Ammo.Value > 0 then
                        pcall(function()
                            local teleportPosition = Vector3.new(
                                targetRootPart.Position.X,
                                targetRootPart.Position.Y + 100,
                                targetRootPart.Position.Z
                            )
                            local shootDirection = (targetHead.Position - teleportPosition).Unit
                            getgenv().Services.ReplicatedStorage.MainEvent:FireServer(
                                "ShootGun",
                                getgenv().EquippedAug:FindFirstChild("Handle"),
                                teleportPosition,
                                targetHead.Position,
                                targetHead,
                                shootDirection
                            )
                            print("[Ragebot] Fired at target:", getgenv().SelectedTarget)
                        end)
                        getgenv().LastFireTime = tick()
                    end
                end
            end
        end
    end
end)

-- Unload handler
Library:OnUnload(function()
    if DesyncConnection then DesyncConnection:Disconnect() end
    if KillAuraConnection then KillAuraConnection:Disconnect() end
    print("[Ragebot] Unloaded!")
    Library.Unloaded = true
end)

print("[Ragebot] Initialized successfully")
