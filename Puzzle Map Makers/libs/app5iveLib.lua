local json = require("json")

local app5iveLib = {}

local function readSaveTable()
    if app5iveLib.saveTable then
        return app5iveLib.saveTable
    end

    local path = system.pathForFile("savedData.json", system.DocumentsDirectory)
    if not path then
        app5iveLib.saveTable = {}
        return app5iveLib.saveTable
    end

    local file = io.open(path, "r")
    if not file then
        app5iveLib.saveTable = {}
        return app5iveLib.saveTable
    end

    local contents = file:read("*a")
    file:close()

    app5iveLib.saveTable = json.decode(contents) or {}
    return app5iveLib.saveTable
end

function app5iveLib.getSaveValue(key)
    local saveTable = readSaveTable()
    return saveTable[key]
end

function app5iveLib.setSaveValue(key, value, persist)
    local saveTable = readSaveTable()
    saveTable[key] = value

    if persist then
        local path = system.pathForFile("savedData.json", system.DocumentsDirectory)
        if not path then
            return saveTable[key]
        end
        local file = io.open(path, "w+")
        if not file then
            return saveTable[key]
        end
        file:write(json.encode(saveTable))
        file:close()
    end

    return saveTable[key]
end

function app5iveLib.convertRGB(r, g, b)
    local valid = r and g and b and r <= 255 and r >= 0 and g <= 255 and g >= 0 and b <= 255 and b >= 0
    assert(valid, "RGB values must be between 0 and 255")
    return r / 255, g / 255, b / 255
end

function app5iveLib.convertHexToRGB(hexCode)
    assert(type(hexCode) == "string" and #hexCode == 7, "Hex value must be in the form #RRGGBB")
    local clean = hexCode:gsub("#", "")
    local r = tonumber("0x" .. clean:sub(1, 2)) / 255
    local g = tonumber("0x" .. clean:sub(3, 4)) / 255
    local b = tonumber("0x" .. clean:sub(5, 6)) / 255
    return r, g, b
end

return app5iveLib
