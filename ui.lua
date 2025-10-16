-- ui.lua
local module = {}

function module.createWindow()
    return Library:CreateWindow({ Title = '                     $ Mad.lol | Beta $ .GG/TRACED                    ', AutoShow = true, TabPadding = 15, MenuFadeTime = 0.2 })
end

function module.createTabs(Window)
    return { Main = Window:AddTab('Main'), Character = Window:AddTab('Character'), Visuals = Window:AddTab('Visuals'), Misc = Window:AddTab('Misc'), Players = Window:AddTab('Players'), ['UI Settings'] = Window:AddTab('UI Settings') }
end

function module.addGroups(Tabs)
    return {
        GunMods = Tabs.Main:AddRightGroupbox('Gun Mods'),
        KillAura = Tabs.Main:AddRightGroupbox('Combat'),
        MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')
    }
end

return module
