local fs = cometreq("lib.nativefs") --- @type comet.lib.nativefs

--- @class subpar.Global
local Global = {}
Global.currentProfile = "temp"

function Global.updateCurrentProfile()
    if not fs.getInfo("profiles/.current", "file") then
        fs.write("profiles/.current", "Profile1")
    end
    local file, err = fs.read("string", "profiles/.current")
    if not file then
        print("Failed to load current profile: " .. err .. " - making temp profile!")
        Global.currentProfile = "temp"
        return
    end
    Global.currentProfile = file:replace("\r", ""):replace("\n", ""):trim()
    print("[SUBPAR | INFO] Current profile set to: " .. Global.currentProfile)
end

function Global.setCurrentProfile(newProfile)
    local ok, err = fs.write("profiles/.current", newProfile)
    if not ok then
        error("Failed to set current profile: " .. err)
        return
    end
end

return Global