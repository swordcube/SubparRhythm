local Strum = require("subpar.game.strum") --- @type subpar.game.Strum
local Note = require("subpar.game.note") --- @type subpar.game.Note

local function sortNote(a, b)
    return a.time < b.time
end

--- @class subpar.game.StrumLine : comet.gfx.Object2D
local StrumLine, super = Object2D:subclass("StrumLine")

function StrumLine:__init__(keyCount)
    super.__init__(self)

    self.pressed = {}

    self.notePos = 1
    self.notesToSpawn = {}

    self.botplay = false

    -- How fast the notes scroll (in seconds)
    self.scrollSpeed = 0.5

    self.strums = Object2D:new() --- @type comet.gfx.Object2D
    self:addChild(self.strums)

    local config = Assets.getSkinConfig(Settings.Game.Skin)["Notes" .. keyCount .. "K"]
    self.keyCount = keyCount

    for i = 1, keyCount do
        self.pressed[i] = false

        local strum = Strum:new(Settings.Game.Skin, keyCount, i) --- @type subpar.game.Strum
        strum.strumLine = self
        strum.position:set(((i - (keyCount / 2) - 1) + 0.5) * config.Spacing, 0)
        self.strums:addChild(strum)

        strum.alpha = 0
        strum.position.y = strum.position.y - 10

        local t = Tween:new() --- @type comet.gfx.Tween
        t:target({target = strum.position, properties = {y = strum.position.y + 10}})
        t:target({target = strum, properties = {alpha = 1}})
        t:start({duration = 0.5, ease = "outCirc", delay = (i * 0.1) + 0.2})
    end
end

function StrumLine:update(dt)
    local spawnRange = 20 / self.scrollSpeed
    local notesToSpawn = self.notesToSpawn

    while self.notePos <= #notesToSpawn and notesToSpawn[self.notePos].beat <= Conductor.instance.curBeat + spawnRange do
        local rawNote = notesToSpawn[self.notePos]
        local strum = self.strums:getChild(rawNote.lane) --- @type subpar.game.Strum
        -- SLog.print("Spawning note at beat " .. rawNote.beat)

        local note = Note:new(strum.skin, strum.keyCount, Conductor.instance:getTimeAtBeat(rawNote.beat), strum.lane)
        note.position.y = -999999.0
        strum.notes:addChild(note)

        self.notePos = self.notePos + 1
    end
end

function StrumLine:input(e)
    if e.type == "key" then
        local binds = Settings.Input.Binds4K
        for i = 1, #binds do
            local bind = binds[i]
            if e.key == bind then
                if e.pressed and not self.pressed[i] then
                    self.pressed[i] = true

                    local strum = self.strums:getChild(i) --- @type subpar.game.Strum
                    strum:press()

                    if not self.botplay then
                        local ct = Conductor.instance:getCurrentTime()
                        local validNotes = table.filter(strum.notes.children, function(n)
                            return math.abs(n.time - ct) < 180 and n.lane == strum.lane
                        end)
                        if #validNotes ~= 0 then
                            strum:hit()
                            table.sort(validNotes, sortNote)
    
                            local note = validNotes[1] --- @type subpar.game.Note
                            strum.notes:hitNote(note)
                        end
                    end
                end
                if not e.pressed and self.pressed[i] then
                    self.pressed[i] = false

                    local strum = self.strums:getChild(i) --- @type subpar.game.Strum
                    strum:release()
                end
                break
            end
        end
    end
end

return StrumLine