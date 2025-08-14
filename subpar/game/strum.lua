--- @class subpar.game.Strum : comet.gfx.Image
local Strum, super = Image:subclass("Strum")

function Strum:__init__(skin, keyCount, lane)
    super.__init__(self)

    self.skin = skin
    self.keyCount = keyCount
    self.lane = lane

    local config = Assets.getSkinConfig(Settings.Game.Skin)["Notes" .. keyCount .. "K"]
    self.scale:set(config.Scale, config.Scale)
    
    self.strumTexture = comet.gfx:get(Assets.getSkinImage("game/notes/" .. keyCount .. "k/" .. config.Strums:split(",")[lane]:trim())) --- @type comet.gfx.Texture
    self.strumTexture:reference()
    
    self.pressTexture = comet.gfx:get(Assets.getSkinImage("game/notes/" .. keyCount .. "k/" .. config.PressStrums:split(",")[lane]:trim())) --- @type comet.gfx.Texture
    self.pressTexture:reference()

    self.hitTexture = comet.gfx:get(Assets.getSkinImage("game/notes/" .. keyCount .. "k/" .. config.HitStrums:split(",")[lane]:trim())) --- @type comet.gfx.Texture
    self.hitTexture:reference()

    self:loadTexture(self.strumTexture)
end

function Strum:press()
    self:loadTexture(self.pressTexture)
end

function Strum:hit()
    self:loadTexture(self.hitTexture)
end

function Strum:release()
    self:loadTexture(self.strumTexture)
end

function Strum:destroy()
    super.destroy(self)
    self.strumTexture:dereference()
    self.pressTexture:dereference()
    self.hitTexture:dereference()
end

return Strum