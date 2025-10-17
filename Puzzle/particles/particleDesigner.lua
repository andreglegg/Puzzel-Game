local particleDesigner = {}

local json = require( "json" )

function particleDesigner.newEmitter( fileName, baseDir )

local filePath = system.pathForFile( fileName, baseDir )
local f = io.open( filePath, "r" )
local fileData = f:read( "*a" )
f:close()

local emitterParams = json.decode( fileData )
local emitter = display.newEmitter( emitterParams )

return emitter
end

return particleDesigner
