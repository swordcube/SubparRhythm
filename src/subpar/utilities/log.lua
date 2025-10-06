local Native = cometreq("native") --- @type comet.Native

--- @class subpar.utilities.Log
local Log = {}

function Log.output(type, fgColor, bgColor, ...)
    Native.setConsoleColors(Native.ConsoleColor.NONE, bgColor)
    
    io.stdout:write("[ ")
    io.stdout:flush()

    Native.setConsoleColors(Native.ConsoleColor.RED, bgColor)
    
    io.stdout:write("SUB")
    io.stdout:flush()

    Native.setConsoleColors(Native.ConsoleColor.BLUE, bgColor)
    
    io.stdout:write("PAR")
    io.stdout:flush()

    Native.setConsoleColors(Native.ConsoleColor.NONE, bgColor)
    
    io.stdout:write(" | ")
    io.stdout:flush()

    Native.setConsoleColors(fgColor, bgColor)
    
    io.stdout:write(type)
    io.stdout:flush()

    Native.setConsoleColors(Native.ConsoleColor.NONE, bgColor)
    
    io.stdout:write(" ] ")
    io.stdout:flush()

    Native.setConsoleColors(Native.ConsoleColor.NONE, Native.ConsoleColor.NONE)

    local str = table.join(table.pack(...), ", ") .. "\n"
    io.stdout:write(str)
    io.stdout:flush()
end

function Log.print(...)
    Log.output(" PRINT ", Native.ConsoleColor.CYAN, Native.ConsoleColor.NONE, ...)
end

function Log.warn(...)
    Log.output("WARNING", Native.ConsoleColor.YELLOW, Native.ConsoleColor.NONE, ...)
end

function Log.error(...)
    Log.output(" ERROR ", Native.ConsoleColor.RED, Native.ConsoleColor.NONE, ...)
end

function Log.verbose(...)
    if comet.isDebug() then
        Log.output("VERBOSE", Native.ConsoleColor.MAGENTA, Native.ConsoleColor.NONE, ...)
    end
end

return Log