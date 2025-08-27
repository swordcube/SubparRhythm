--- @class subpar.game.Note : comet.gfx.Image
local Note, super = Image:subclass("Note")

function Note:__init__(skin, keyCount, time, lane)
    super.__init__(self)

    self.skin = skin --- @type string
    self.keyCount = keyCount --- @type integer
    self.time = time --- @type number
    self.lane = lane --- @type integer

    local config = Assets.getSkinConfig(Settings.Game.Skin)["Notes" .. keyCount .. "K"]
    local tex = comet.gfx:get(Assets.getSkinImage("game/notes/" .. keyCount .. "k/" .. config.Notes:split(",")[lane]:trim())) --- @type comet.gfx.Texture
    self:loadTexture(tex)
end

return Note