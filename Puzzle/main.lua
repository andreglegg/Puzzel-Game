local composer = require( "composer" )
local scenes = require( "app.scene_names" )

system.setIdleTimer( true )
_G.totalLevels = 10

composer.gotoScene( scenes.splash )
