local ini = cometreq("lib.ini") --- @type comet.lib.Ini
local fs = love.filesystem

--- @class subpar.Assets
local Assets = {
    cachedSkins = {}
}

function Assets.clearCached()
    Assets.cachedSkins = {}
end

function Assets.getCurrentProfile()
    
end

function Assets.getContentAsset(name)
    return Settings.Game.ContentFolder .. "/" .. name
end

function Assets.getSkinAsset(name, skin)
    skin = skin or Settings.Game.Skin or "default"

    local maybeGoodPath = Settings.Game.ContentFolder .. "/skins/" .. skin .. "/" .. name
    if fs.exists(maybeGoodPath) then
        return maybeGoodPath
    end
    return Settings.Game.ContentFolder .. "/skins/default/" .. name
end

function Assets.getSkinImage(name, skin)
    local possiblePaths = {
        Assets.getSkinAsset(name .. ".png", skin),
        Assets.getSkinAsset(name .. ".PNG", skin),
        Assets.getSkinAsset(name .. ".jpg", skin),
        Assets.getSkinAsset(name .. ".JPG", skin),
        Assets.getSkinAsset(name .. ".jpeg", skin),
        Assets.getSkinAsset(name .. ".JPEG", skin)
    }
    for i = 1, #possiblePaths do
        if fs.exists(possiblePaths[i]) then
            return possiblePaths[i]
        end
    end
    return possiblePaths[1] -- fallback to first path
end

function Assets.getSkinXml(name, skin)
    local possiblePaths = {
        Assets.getSkinAsset(name .. ".xml", skin),
        Assets.getSkinAsset(name .. ".XML", skin)
    }
    for i = 1, #possiblePaths do
        if fs.exists(possiblePaths[i]) then
            return possiblePaths[i]
        end
    end
    return possiblePaths[1] -- fallback to first path
end

function Assets.getSkinFont(name, skin)
    local possiblePaths = {
        Assets.getSkinAsset(name .. ".ttf", skin),
        Assets.getSkinAsset(name .. ".TTF", skin),
        Assets.getSkinAsset(name .. ".otf", skin),
        Assets.getSkinAsset(name .. ".OTF", skin)
    }
    for i = 1, #possiblePaths do
        if fs.exists(possiblePaths[i]) then
            return possiblePaths[i]
        end
    end
    return possiblePaths[1] -- fallback to first path
end

function Assets.getSongAudio(name)
    local possiblePaths = {
        Assets.getContentAsset("songs/" .. name .. "/music.ogg"),
        Assets.getContentAsset("songs/" .. name .. "/music.OGG"),
        Assets.getContentAsset("songs/" .. name .. "/music.wav"),
        Assets.getContentAsset("songs/" .. name .. "/music.WAV"),
        Assets.getContentAsset("songs/" .. name .. "/music.mp3"),
        Assets.getContentAsset("songs/" .. name .. "/music.MP3")
    }
    for i = 1, #possiblePaths do
        if fs.exists(possiblePaths[i]) then
            return possiblePaths[i]
        end
    end
    return possiblePaths[1] -- fallback to first path
end

---
--- Returns the config file for a given skin
---
--- @param  skin  string  The name of the skin
--- @return subpar.data.SkinConfig
---
function Assets.getSkinConfig(skin)
    skin = skin or Settings.Game.Skin or "default"
    if not Assets.cachedSkins[skin] then
        local file = ini.load(Assets.getSkinAsset("config.ini", skin))
        Assets.cachedSkins[skin] = file
    end
    return Assets.cachedSkins[skin]
end

return Assets