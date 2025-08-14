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

    -- TODO: allow for more keys than just 4k

    local skinConfig = Assets.getSkinConfig(Settings.Game.Skin)

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
end

return GameplayScreen