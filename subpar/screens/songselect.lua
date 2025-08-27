--- @class subpar.screens.SongSelectScreen : comet.core.Screen
local SongSelectScreen, super = Screen:subclass("SongSelectScreen")

function SongSelectScreen:enter()
    super.enter(self)
    comet.settings.bgColor = 0xFF180F11

    self.bg = Image:new("content/skins/default/menus/images/bg.png") --- @type comet.gfx.Image
    self.bg.position:set(comet.getDesiredWidth() / 2, comet.getDesiredHeight() / 2)
    self:addChild(self.bg)

    self.menuBarBG = Rectangle:new() --- @type comet.gfx.Rectangle
    self.menuBarBG.centered = false
    self.menuBarBG:setTint(Color.BLACK)
    self.menuBarBG:getTint().a = 0.5
    self.menuBarBG:setSize(comet.getDesiredWidth(), 40)
    self.menuBarBG.position:set(0, comet.getDesiredHeight() - self.menuBarBG:getHeight())
    self:addChild(self.menuBarBG)
end

function SongSelectScreen:update(dt)
    super.update(self, dt)
    self.bg:rotate(dt * 20)
end

function SongSelectScreen:input(e)
    if e.type == "key" then
        local e = e --- @type comet.input.InputKeyEvent
        if e.key == "return" then
            ScreenManager.switchTo(require("subpar.screens.gameplay"):new("Beancore-G-Sides", "Expert"))
        end
    end
end

return SongSelectScreen