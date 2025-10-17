local composer = require( "composer" )
local scenes = require( "app.scene_names" )
local lib 				= require("libs.app5iveLib")
display.setDefault( "background", lib.convertHexToRGB("#ECECEC") )


composer.gotoScene( scenes.editor )
