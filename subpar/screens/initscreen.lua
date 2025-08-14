--- @class subpar.screens.InitScreen : comet.core.Screen
local InitScreen, super = Screen:subclass("InitScreen")

function InitScreen:__init__()
    super.__init__(self)

    Assets = require("subpar.assets") --- @type subpar.Assets
    Chart = require("subpar.chart") --- @type subpar.Chart
    Global = require("subpar.global") --- @type subpar.Global
    Settings = require("subpar.settings") --- @type subpar.Settings

    Global.updateCurrentProfile()
    Settings.load()
end

function InitScreen:enter()
    ScreenManager.instance:_switchTo(require("subpar.screens.songselect"):new())
end

return InitScreen