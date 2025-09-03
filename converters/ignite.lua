---@diagnostic disable: redefined-local

require("tools.stringtools")
require("tools.tabletools")

local conductor = require("utils.conductor")

local json = require("utils.json")

io.stdout:write("Please input the same folder as the chart/metadata: ")
io.stdout:flush()

local chartFolder = io.read("*l")
local cf, err = io.open(chartFolder .. "/chart.json", "r")
if not cf then
    error("Failed to open chart.json: " .. err)
end
local mf, err = io.open(chartFolder .. "/meta.json", "r")
if not mf then
    error("Failed to open meta.json: " .. err)
end

local chart = json.decode(cf:read("*a"))
local meta = json.decode(mf:read("*a"))

local output = ""
local function addToOutput(str)
    output = output .. str .. "\n"
end
-- add general chart metadata
addToOutput("$chart;")
addToOutput("version=0.1.0;\n")

-- add basic metadata
addToOutput("$meta;")
addToOutput("title=" .. meta.name .. ";")
addToOutput("artist=" .. meta.artist .. ";")
addToOutput("charter=" .. meta.chartist .. ";")
addToOutput("difficulties=Unknown;\n")

-- add timing points
addToOutput("$timing;")
addToOutput("0.0=" .. meta.bpm .. ",4/4;")

-- make a conductor for easier time -> beat conversion
local c = conductor:new() --- @type converter.utils.conductor
c:reset(meta.bpm, {4, 4})
c:setupTimingPoints({
    {
        time = 0,
        bpm = meta.bpm,
        timeSignature = {4, 4}
    }
})

-- add note types
local noteTypes = {"Default"}
local possibleLetters = {"A", "a", "B", "b", "C", "c", "D", "d", "E", "e", "F", "f", "G", "g", "H", "h", "I", "i", "J", "j", "K", "k", "L", "l", "M", "m", "N", "n", "O", "o", "P", "p", "Q", "q", "R", "r", "S", "s", "T", "t", "U", "u", "V", "v", "W", "w", "X", "x", "Y", "y", "Z", "z"}
local letterPos = 1
local typesToLetters = {["Default"] = "1"}

if #noteTypes ~= 0 then
    addToOutput("\n$notetypes;")
    for i = 1, #noteTypes do
        local noteType = noteTypes[i]
        if not typesToLetters[noteType] then
            typesToLetters[noteType] = possibleLetters[letterPos]
            letterPos = letterPos + 1
        end
        addToOutput(typesToLetters[noteType] .. "=" .. noteType .. ",false;")
    end
end
-- add notes
addToOutput("\n$notes;")
addToOutput("@Unknown;")

local notes = chart.notes
table.sort(notes, function(a, b)
    return a.t < b.t
end)
local curRow = -1
local rowStr = "0000"

for i = 1, #notes do
    local note = notes[i]
    note.p = ((note.p - 1) % 4) + 1

    local row = c:getBeatAtTime(note.t * 1000.0)
    if row > curRow and curRow >= 0 then
        addToOutput(tostring(curRow) .. "=" .. rowStr .. ";")
        rowStr = "0000"
    end
    curRow = row
    rowStr = string.replaceChar(rowStr, tostring(note.p), typesToLetters["Default"])
end
if rowStr ~= "0000" then
    addToOutput(tostring(curRow) .. "=" .. rowStr .. ";")
end

-- save the final output
io.stdout:write("Enter the output folder: ")
io.stdout:flush()

local outputFolder = io.read("*l")
local fcf, err = io.open(outputFolder .. "/chart.sbpc", "w")
if not fcf then
    print("Error opening output file: " .. err)
    return
end
fcf:write(output)
fcf:flush()
fcf:close()

print("Converted " .. meta.name .. " successfully!")