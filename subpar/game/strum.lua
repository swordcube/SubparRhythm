local NoteGroup = require("subpar.game.notegroup") --- @type subpar.game.NoteGroup

--- @class subpar.game.Strum : comet.gfx.Image
local Strum, super = Image:subclass("Strum")

function Strum:__init__(skin, keyCount, lane)
    super.__init__(self)

    self.strumLine = nil --- @type subpar.game.StrumLine

    self.notes = NoteGroup:new(0, 0, skin, keyCount) --- @type subpar.game.NoteGroup
    self:addChild(self.notes)

    self.skin = skin
    self.keyCount = keyCount
    self.lane = lane
    self.releaseTimer = 0.0

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

function Strum:update(dt)
    if self.releaseTimer > 0.0 then
        self.releaseTimer = self.releaseTimer - (dt * 1000.0)
        if self.releaseTimer <= 0.0 then
            self.releaseTimer = 99999999.0
            self:release()
        end
    end
end

function Strum:destroy()
    super.destroy(self)
    self.strumTexture:dereference()
    self.pressTexture:dereference()
    self.hitTexture:dereference()
end

return Strum