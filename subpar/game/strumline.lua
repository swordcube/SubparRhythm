local Strum = require("subpar.game.strum") --- @type subpar.game.Strum

--- @class subpar.game.StrumLine : comet.gfx.Object2D
local StrumLine, super = Object2D:subclass("StrumLine")

function StrumLine:__init__(keyCount)
    super.__init__(self)

    local config = Assets.getSkinConfig(Settings.Game.Skin)["Notes" .. keyCount .. "K"]
    self.keyCount = keyCount

    for i = 1, keyCount do
        local strum = Strum:new(Settings.Game.Skin, keyCount, i) --- @type subpar.game.Strum
        strum.position:set(((i - (keyCount / 2) - 1) + 0.5) * config.Spacing, 0)
        self:addChild(strum)

        strum.alpha = 0
        strum.position.y = strum.position.y - 10

        local t = Tween:new() --- @type comet.gfx.Tween
        t:target({target = strum.position, properties = {y = strum.position.y + 10}})
        t:target({target = strum, properties = {alpha = 1}})
        t:start({duration = 0.5, ease = "outCirc", delay = (i * 0.1) + 0.2})
    end
end

return StrumLine