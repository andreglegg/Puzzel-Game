local background = {}
local screen = require("libs.screen")
local particleDesigner = require("particles.particleDesigner")
local lib = require("libs.app5iveLib")

local function addBackground(targetGroup)
    display.setDefault("background", lib.convertHexToRGB("#0A579B"))

    local emitter = particleDesigner.newEmitter("particles/stars.json")
    emitter.x = screen.centerX
    emitter.y = screen.centerY
    emitter.alpha = 0.3
    targetGroup:insert(emitter)
end

background.addBg = addBackground

return background
