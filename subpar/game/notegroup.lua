--- @class subpar.game.NoteGroup : comet.gfx.Object2D
local NoteGroup, super = Object2D:subclass("NoteGroup")

function NoteGroup:__init__(x, y, skin, keyCount)
    super.__init__(self, x, y)

    self.noteTextures = {} --- @type comet.gfx.Texture[]
    self.toRemove = {}
    
    local config = Assets.getSkinConfig(skin)["Notes" .. keyCount .. "K"]
    for i = 1, keyCount do
        local tex = comet.gfx:getTexture(Assets.getSkinImage("game/notes/" .. keyCount .. "k/" .. config.Notes:split(",")[i]:trim())) --- @type comet.gfx.Texture
        tex:reference()
        table.insert(self.noteTextures, tex)
    end
end

--- @param note subpar.game.Note
function NoteGroup:hitNote(note)
    local ct = Conductor.instance:getCurrentTime()
    self:removeNote(note)

    local strum = self.parent --- @type subpar.game.Strum
    strum:hit()

    if strum.strumLine.botplay then
        strum.releaseTimer = 50.0
    end
    local game = ScreenManager.instance.current --- @type subpar.screens.GameplayScreen
    game:addScore(Scoring.getScoreFromDiff(note.time - ct))
    game:showHitInfo(Scoring.getRatingFromDiff(note.time - ct), math.truncate(note.time - ct, 3))
end

--- @param note subpar.game.Note
function NoteGroup:missNote(note)
    self:removeNote(note)

    local game = ScreenManager.instance.current --- @type subpar.screens.GameplayScreen
    game:showHitInfo("miss", nil)
end

--- @param note subpar.game.Note
function NoteGroup:updateNote(note)
    local strum = self.parent --- @type subpar.game.Strum
    local strumLine = strum.strumLine --- @type subpar.game.StrumLine

    local ct = Conductor.instance:getCurrentTime()
    local ph = Conductor.instance:getCurrentPlayhead()

    note.position.x = note:getWidth() * 0.5
    note.position.y = ((ph - note.time) / strumLine.scrollSpeed) + (note:getHeight() * 0.5)

    if strumLine.botplay and note.time <= ph then
        self:hitNote(note)
    end
    if note.time < ct - (250 * strumLine.scrollSpeed) then
        self:missNote(note)
    end
end

--- @param note subpar.game.Note
function NoteGroup:removeNote(note)
    table.insert(self.toRemove, note)
end

function NoteGroup:_update(dt)
    for i = 1, #self.children do
        local object = self.children[i] --- @type comet.core.Object
        if object then
            self:updateNote(object)
            object:_update(dt)
        end
    end
    for i = 1, #self.toRemove do
        local note = self.toRemove[i] --- @type subpar.game.Note
        note:destroy()
        self:removeChild(note)
    end
    self.toRemove = {}
    self:update(dt)
end

function NoteGroup:destroy()
    for i = 1, #self.noteTextures do
        self.noteTextures[i]:dereference()
    end
    super.destroy(self)
end

return NoteGroup