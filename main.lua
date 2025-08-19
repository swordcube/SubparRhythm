comet = require("thirdparty.comet")

-- No need to define love.load, love.update, or love.draw! comet.init() will handle this for you!
-- You still can if you need to, just make sure to call the respective comet functions too!
comet.init({
    flags = require("flags"),
    settings = {
        fpsCap = 240,
        bgColor = {0.0, 0.0, 0.0, 1.0},
        dimensions = {1280, 720},
        parallelUpdate = false
    },
    screen = function() return require("subpar.screens.initscreen"):new() end
})