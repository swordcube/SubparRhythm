local ini = cometreq("lib.ini") --- @type comet.lib.Ini

--- @class subpar.Settings
local Settings = {
    Audio = {
        MasterVolume = 1, --- @type number
        MusicVolume = 1, --- @type number
        SFXVolume = 1 --- @type number
    },
    Video = {
        Fullscreen = false,
        VSync = false,
        FPS = 240
    },
    Input = {
        Binds4K = {"s", "d", "k", "l"} --- @type string[]
    },
    Game = {
        ContentFolder = "content",
        Skin = "default",
        NoteOffset = 0 --- @type number
    }
}
Settings.defaults = table.copy(Settings, true)

function Settings.load()
    --- @diagnostic disable-next-line: cast-local-type
    Settings = table.copy(Settings.defaults, true)

    local file = "profiles/" .. Global.currentProfile .. "/settings.ini"
    if not love.filesystem.exists(file) then
        print("Settings doesn't exist for " .. Global.currentProfile .. " - using defaults!")
        return
    end
    local s = ini.load(file)
    for key, value in pairs(s) do
        Settings[key] = {}
        for key2, value2 in pairs(value) do
            if string.startsWith(key2, "Binds") then
                local keys = string.split(value2, ",")
                for i = 1, #keys do
                    keys[i] = keys[i]:trim()
                end
                Settings[key][key2] = keys
            else
                SLog.verbose("Loaded " .. key2 .. " as " .. tostring(value2))
                Settings[key][key2] = value2
            end
        end
    end
end

function Settings:save()
    local save = {}
    for key, _ in pairs(Settings) do
        save[key] = Settings[key]
    end
    local file = "profiles/" .. Global.currentProfile .. "/settings.ini"
    ini.save(file, save)
end

return Settings