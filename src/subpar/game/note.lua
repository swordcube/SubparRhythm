--- @class subpar.game.Note : comet.gfx.Image
local Note, super = Image:subclass("Note")

function Note:__init__(skin, keyCount, time, lane, type)
    super.__init__(self)

    self.skin = skin --- @type string
    self.keyCount = keyCount --- @type integer
    self.time = time --- @type number
    self.lane = lane --- @type integer
    self.type = type --- @type string

    if type == "SustainEnd" then
        SLog.warn("Sustains aren't handled yet, i'm lazy!")
    end
    local config = Assets.getSkinConfig(Settings.Game.Skin)["Notes" .. keyCount .. "K"]
    local tex = comet.gfx:getTexture(Assets.getSkinImage("game/notes/" .. keyCount .. "k/" .. config.Notes:split(",")[lane]:trim())) --- @type comet.gfx.Texture
    self:loadTexture(tex)
end

return Note