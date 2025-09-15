local Image = cometreq("gfx.image") --- @type comet.gfx.Image
local Rectangle = cometreq("gfx.rectangle") --- @type comet.gfx.Rectangle

local StrumLine = require("subpar.game.strumline") --- @type subpar.game.StrumLine

--- @class subpar.screens.GameplayScreen : comet.core.Screen
local GameplayScreen, super = Screen:subclass("GameplayScreen")

function GameplayScreen:__init__(song, difficulty)
    super.__init__(self)

    self.currentSong = song
    self.currentDifficulty = difficulty
    self.currentChart = Chart.load(self.currentSong, self.currentDifficulty)
end

function GameplayScreen:enter()
    super.enter(self)
    comet.settings.bgColor = Color:new(Color.BLACK)
    
    local c = Conductor.instance --- @type subpar.plugins.Conductor
    c:reset(self.currentChart.timing[1].bpm, self.currentChart.timing[1].timeSignature)
    c:setupTimingPoints(self.currentChart.timing)
    c:setCurrentTime(c:getCurrentBeatLength() * -4.0)

    comet.mixer.music:setSource(Assets.getSongAudio(self.currentSong))
    comet.mixer.music.onComplete:connect(function(_)
        self:switchTo(require("subpar.screens.songselect"):new())
    end)

    -- TODO: allow for more keys than just 4k

    local skinConfig = Assets.getSkinConfig(Settings.Game.Skin)

    self.startingSong = true

    --- @protected
    self._score = 0

    self.camera = Camera:new() --- @type comet.gfx.Camera
    self.camera.zoom:set(1.1, 1.1)
    self:addChild(self.camera)

    self.bg = Image:new(Assets.getSkinImage("game/bg")) --- @type comet.gfx.Image
    self.bg.position:set(comet.getDesiredWidth() / 2, comet.getDesiredHeight() / 2)
    self.camera:addChild(self.bg)

    local t = Tween:new() --- @type comet.gfx.Tween
    t:target({target = self.camera.zoom, properties = {x = 1, y = 1}}):start({duration = 0.75, ease = "outCubic"})

    self.underlay = Rectangle:new() --- @type comet.gfx.Rectangle
    self.underlay:setTint(Color.BLACK)
    self.underlay:getTint().a = 0.5
    self.underlay:setSize((skinConfig.Notes4K.Spacing * 4) + 30, comet.getDesiredHeight())
    self.underlay.position:set(comet.getDesiredWidth() / 2, comet.getDesiredHeight() / 2)
    self.camera:addChild(self.underlay)
    
    self.strumLine = StrumLine:new(4) --- @type subpar.game.StrumLine
    self.strumLine.position:set(comet.getDesiredWidth() / 2, comet.getDesiredHeight() * 0.85)
    self.strumLine.notesToSpawn = self.currentChart.notes
    self.camera:addChild(self.strumLine)

    self.scoreLabel = Label:new() --- @type comet.gfx.Label
    self.scoreLabel.position:set(20, comet.getDesiredHeight() - 10)
    self.scoreLabel:setFont(Assets.getSkinFont("fonts/francois_one"))
    self.scoreLabel:setSize(48)
    -- self.scoreLabel.borderSize = 8
    self.scoreLabel.text = "000000"
    self.scoreLabel.centered = false
    self.scoreLabel.position.y = self.scoreLabel.position.y - self.scoreLabel:getHeight()
    self.camera:addChild(self.scoreLabel)

    self.tinyScoreLabel = Label:new() --- @type comet.gfx.Label
    self.tinyScoreLabel.position:set(20, comet.getDesiredHeight() - 60)
    self.tinyScoreLabel:setFont(Assets.getSkinFont("fonts/francois_one"))
    self.tinyScoreLabel:setSize(24)
    -- self.tinyScoreLabel.borderSize = 8
    -- self.tinyScoreLabel.borderPrecision = 16
    self.tinyScoreLabel.text = "Score"
    self.tinyScoreLabel.centered = false
    self.tinyScoreLabel.position.y = self.tinyScoreLabel.position.y - self.tinyScoreLabel:getHeight()
    self.camera:addChild(self.tinyScoreLabel)

    local bottomItems = {self.tinyScoreLabel, self.scoreLabel}
    for i, item in ipairs(bottomItems) do
        item.alpha = 0
        item.position.y = item.position.y - 10

        local t = Tween:new() --- @type comet.gfx.Tween
        t:target({target = item.position, properties = {y = item.position.y + 10}})
        t:target({target = item, properties = {alpha = 1}})
        t:start({duration = 0.5, ease = "outQuad", delay = (i * 0.1) + 0.1})
    end
    local ratingList = Scoring.getRatingList()
    self.ratingTextures = {} --- @type comet.gfx.Texture[]

    for _, rating in ipairs(ratingList) do
        self.ratingTextures[rating] = comet.gfx:getTexture(Assets.getSkinImage("game/ratings/" .. rating))
        self.ratingTextures[rating]:reference()
    end
    self.ratingDisplay = Image:new(self.ratingTextures[ratingList[1]]) --- @type comet.gfx.Image
    self.ratingDisplay:screenCenter()
    self.ratingDisplay.position.y = self.ratingDisplay.position.y - 20
    self.ratingDisplay.alpha = 0.0
    self.camera:addChild(self.ratingDisplay)

    self.msDisplayLabel = Label:new()
    self.msDisplayLabel.position:set(20, comet.getDesiredHeight() - 60)
    self.msDisplayLabel:setFont(Assets.getSkinFont("fonts/francois_one"))
    self.msDisplayLabel:setSize(24)
    self.msDisplayLabel.text = "0ms"
    self.msDisplayLabel:screenCenter()
    self.msDisplayLabel.position.y = self.msDisplayLabel.position.y + 20
    self.msDisplayLabel.alpha = 0.0
    self.camera:addChild(self.msDisplayLabel)
end

function GameplayScreen:getScore()
    return self._score
end

function GameplayScreen:setScore(newScore)
    self._score = newScore
    self.scoreLabel.text = string.format("%06d", self._score)

    Tween.cancelTweensOf(self.scoreLabel.scale)
    self.scoreLabel.scale:set(1.075, 1.075)

    local t = Tween:new() --- @type comet.gfx.Tween
    t:target({target = self.scoreLabel.scale, properties = {x = 1, y = 1}})
    t:start({duration = 0.35, ease = "outBack"})
end

function GameplayScreen:addScore(by)
    self:setScore(self._score + by)
end

function GameplayScreen:showHitInfo(rating, diff)
    self.ratingDisplay:loadTexture(self.ratingTextures[rating])
    self.ratingDisplay.alpha = 1

    local objectsToAnimate = {self.ratingDisplay}
    if diff then
        self.msDisplayLabel.text = string.format("%dms", diff)
        self.msDisplayLabel.alpha = 1
        table.insert(objectsToAnimate, self.msDisplayLabel)
    else
        Tween.cancelTweensOf(self.msDisplayLabel)
        Tween.cancelTweensOf(self.msDisplayLabel.scale)
        self.msDisplayLabel.alpha = 0.0
    end
    for i = 1, #objectsToAnimate do
        local object = objectsToAnimate[i]

        Tween.cancelTweensOf(object)
        Tween.cancelTweensOf(object.scale)
        object.scale:set(1.075, 1.075)

        local t = Tween:new() --- @type comet.gfx.Tween
        t:target({target = object.scale, properties = {x = 1, y = 1}})
        t:start({duration = 0.25, ease = "outBack"})

        local t = Tween:new() --- @type comet.gfx.Tween
        t:target({target = object, properties = {alpha = 0}})
        t:start({delay = 0.5, duration = 0.15})
    end
end

function GameplayScreen:update(dt)
    super.update(self, dt)
    local c = Conductor.instance --- @type subpar.plugins.Conductor
    if self.startingSong and c:getCurrentTime() >= 0.0 then
        self.startingSong = false
        c:setCurrentTime(0.0)
        
        comet.mixer.music:play()
        c.music = comet.mixer.music
    end
end

function GameplayScreen:exit()
    for _, texture in pairs(self.ratingTextures) do
        texture:dereference()
    end
    super.exit(self)
end

return GameplayScreen