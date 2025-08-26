local fs = cometreq("lib.nativefs") --- @type comet.lib.nativefs
local utf8 = require("utf8")

local table = table

--- @class subpar.Chart
local Chart = {}

local function sortNote(a, b)
    if a.beat ~= b.beat then
        return a.beat < b.beat
    end
    return a.lane < b.lane
end

local function sortTimingPoint(a, b)
    return a.beat < b.beat
end

function Chart.loadMeta(song, _file)
    local file, err = nil, nil
    local path = "songs/" .. song .. "/chart.sbpc"
    if _file then
        file = _file
    else
        file, _, _, err = love.filesystem.read("string", path)
        if err then
            error("Failed to load chart metadata for " .. song .. ": " .. err)
        end
        file = string.replace(file, "\r", ""):replace("\n", "")
    end
    local result = {}
    
    local i = 1
    local split = string.split(file, ";")

    while i < #split do
        local line = split[i]
        if line:startsWith("$") then
            -- parse section
            local sectionName = line:sub(2)
            if sectionName ~= "meta" then
                goto continue
            end
            i = i + 1
            while i < #split do
                line = split[i]
                if line:startsWith("$") then
                    break
                end
                -- parse each value
                local split = string.split(line, "=")
                result[split[1]] = split[2]
                i = i + 1
            end
        end
        ::continue::
        i = i + 1
    end
    return result
end

function Chart.load(song, difficulty)
    -- beware! this code is probably hyper ass!

    local path = Settings.Game.ContentFolder .. "/songs/" .. song .. "/chart.sbpc"
    local file, _, _, err = love.filesystem.read("string", path)
    if err then
        error("Failed to load chart for " .. song .. ": " .. err)
    end
    file = string.replace(file, "\r", ""):replace("\n", "")

    local chart = {
        version = nil,
        meta = Chart.loadMeta(song, file),
        notetypes = {},
        timing = {},
        notes = {}
    }
    local i = 1
    local split = string.split(file, ";")

    while i < #split do
        local line = split[i]
        if line:startsWith("$") then
            local sectionName = line:sub(2)
            if sectionName == "chart" then
                -- parse basic chart meta (currently just version) 
                i = i + 1
                while i < #split do
                    line = split[i]
                    if line:startsWith("$") then
                        i = i - 1
                        break
                    end
                    -- parse each value
                    local split = string.split(line, "=")
                    if split[1] == "version" then
                        chart[split[1]] = split[2]
                    end
                    i = i + 1
                end
            elseif sectionName == "meta" then
                -- skip past this, we loaded this earlier already
                i = i + 1
                while i < #split do
                    line = split[i]
                    if line:startsWith("$") then
                        i = i - 1
                        break
                    end
                    i = i + 1
                end
            elseif sectionName == "notetypes" then
                -- parse note types
                i = i + 1
                while i < #split do
                    line = split[i]
                    if line:startsWith("$") then
                        i = i - 1
                        break
                    end
                    -- parse each value
                    local lineSplit = string.split(line, "=")
                    local valueSplit = lineSplit[2]:split(",")
                    chart.notetypes[lineSplit[1]] = {
                        id = valueSplit[1],
                        dangerous = valueSplit[2]:lower() == "true"
                    }
                    i = i + 1
                end
            elseif sectionName == "timing" then
                -- parse timing points
                i = i + 1
                while i < #split do
                    line = split[i]
                    if line:startsWith("$") then
                        i = i - 1
                        break
                    end
                    -- parse each value
                    local lineSplit = string.split(line, "=")
                    local valueSplit = lineSplit[2]:split(",")

                    local timeSig = valueSplit[2]:split("/")
                    local timingPoint = {
                        time = tonumber(lineSplit[1]),
                        bpm = tonumber(valueSplit[1]),
                        timeSignature = {tonumber(timeSig[1]), tonumber(timeSig[2])}
                    }
                    table.insert(chart.timing, timingPoint)
                    i = i + 1
                end
            elseif sectionName == "notes" then
                -- parse notes
                i = i + 1
                while i < #split do
                    line = split[i]
                    if line:startsWith("$") then
                        i = i - 1
                        break
                    end
                    if line:startsWith("@") then
                        local parsedDifficulty = line:sub(2)
                        if parsedDifficulty ~= difficulty then
                            i = i + 1
                            -- skip until we find the matching difficulty or we hit EOF
                            while i < #split do
                                local stop = false
                                line = split[i]

                                local isDiff = line:startsWith("@")
                                if line:startsWith("$") or isDiff then
                                    if isDiff then
                                        parsedDifficulty = line:sub(2)
                                    end
                                    if parsedDifficulty == difficulty then
                                        -- found the matching difficulty! use this one!
                                        stop = true
                                        break
                                    end
                                end
                                if stop then
                                    break
                                end
                                i = i + 1
                            end
                        end
                        -- start parsing notes for this difficulty
                        i = i + 1 -- skip the line containing the difficulty
                        while i < #split do
                            line = split[i]
                            if line:startsWith("$") or line:startsWith("@") then
                                -- stop if EOF or we hit another difficulty
                                i = i - 1
                                break
                            end
                            local lineSplit = string.split(line, "=")
                            local beat = tonumber(lineSplit[1])
                            
                            -- doing utf8 stuff so if you run out of regular characters, symbols, AND numbers
                            -- somehow, you can use emoji :D
                            local valueSplit = lineSplit[2]:split(",")
                            local keyCount = utf8.len(valueSplit[1])

                            for j = 1, keyCount do
                                local char = utf8.char(utf8.codepoint(valueSplit[1], j, j))
                                if char == "0" then
                                    -- 0 means no note, so move along!
                                    goto note_cont
                                else
                                    -- anything other than 0 is a note, so parse that thing!!!
                                    local storedNote = {
                                        beat = beat,
                                        lane = j,
                                        type = char == "1" and "default" or chart.notetypes[char].id
                                    }
                                    -- TODO: add sustain end type which will point to the last note
                                    -- of it's lane
                                    table.insert(chart.notes, storedNote)
                                end
                                ::note_cont::
                            end
                            i = i + 1
                        end
                        break
                    end
                    i = i + 1
                end
            end
        end
        i = i + 1
    end
    table.sort(chart.notes, sortNote)
    table.sort(chart.timing, sortTimingPoint)
    SLog.verbose("Loaded " .. song .. " [" .. difficulty .. "] chart with " .. #chart.notes .. " notes and " .. #chart.timing .. " timing points")
    return chart
end

return Chart