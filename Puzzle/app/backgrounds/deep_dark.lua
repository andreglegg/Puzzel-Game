local background = {}
local screen            = require( "libs.screen")
local particleDesigner  = require( "particles.particleDesigner" )
local lib               = require("libs.app5iveLib")


local function addBg(group)
    display.setDefault( "background", lib.convertHexToRGB("#0A579B") )
    local   function emit(group, particle, x, y)
        local emitter = particleDesigner.newEmitter( "particles/".. particle ..".json" )
        emitter.x = x
        emitter.y = y
        group:insert( emitter )
        return emitter
    end

    local stars = emit( group, "stars", screen.centerX, screen.centerY)  
    stars.alpha = 0.3  
    
end

background.addBg = addBg


return background
