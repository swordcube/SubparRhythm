--- @class subpar.screens.InitScreen : comet.core.Screen
local InitScreen, super = Screen:subclass("InitScreen")

function InitScreen:enter()
    Assets = srcreq("subpar.assets") --- @type subpar.Assets
    Chart = srcreq("subpar.chart") --- @type subpar.Chart
    Global = srcreq("subpar.global") --- @type subpar.Global
    Settings = srcreq("subpar.settings") --- @type subpar.Settings
    SLog = srcreq("subpar.utilities.log") --- @type subpar.utilities.Log
    Conductor = srcreq("subpar.plugins.conductor") --- @type subpar.plugins.Conductor
    Scoring = srcreq("subpar.game.scoring") --- @type subpar.game.Scoring
    
    local c = Conductor:new() --- @type subpar.plugins.Conductor
    c.dispatchToScreens = true
    Conductor.instance = c
    comet.plugins:add(c)
    
    Global.updateCurrentProfile()
    Settings.load()

    self:forceSwitchTo(srcreq("subpar.screens.songselect"):new())
end

return InitScreen