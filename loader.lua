-- loader.lua
local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

-- Charger les modules
local ui = require(script.ui)
local variables = require(script.variables)
local functions = require(script.functions)
local targeting = require(script.targeting)
local menu = require(script.menu)
local theme = require(script.theme)
local watermark = require(script.watermark)

-- Initialiser la fenêtre
local Window = ui.createWindow()
local Tabs = ui.createTabs(Window)

-- Exécuter les fonctionnalités
targeting.init(Tabs.Main)
menu.init(Tabs['UI Settings'])
theme.init(Library, Tabs['UI Settings'])
watermark.init()

-- Unload
Library:OnUnload(function()
    watermark.unload()
    print('Unloaded!')
    Library.Unloaded = true
end)
