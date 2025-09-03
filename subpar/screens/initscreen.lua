--- @class subpar.screens.InitScreen : comet.core.Screen
local InitScreen, super = Screen:subclass("InitScreen")

function InitScreen:enter()
    Assets = require("subpar.assets") --- @type subpar.Assets
    Chart = require("subpar.chart") --- @type subpar.Chart
    Global = require("subpar.global") --- @type subpar.Global
    Settings = require("subpar.settings") --- @type subpar.Settings
    SLog = require("subpar.utilities.log") --- @type subpar.utilities.Log
    Conductor = require("subpar.plugins.conductor") --- @type subpar.plugins.Conductor
    Scoring = require("subpar.game.scoring") --- @type subpar.game.Scoring
    
    local c = Conductor:new() --- @type subpar.plugins.Conductor
    c.dispatchToScreens = true
    Conductor.instance = c
    comet.plugins:add(c)
    
    Global.updateCurrentProfile()
    Settings.load()

    self:forceSwitchTo(require("subpar.screens.songselect"):new())
end

return InitScreen