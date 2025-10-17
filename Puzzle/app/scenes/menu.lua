display.setStatusBar( display.HiddenStatusBar )

local composer = require( "composer" )
local scenes = require( "app.scene_names" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------------------------------------
-- All code outside of the listener functions will only be executed ONCE unless "composer.removeScene()" is called
-- -----------------------------------------------------------------------------------------------------------------

-- Local forward references should go here

local lib 				= require("libs.app5iveLib")
local screen 			= require( "libs.screen")
local particleDesigner  = require( "particles.particleDesigner" )
local settings          = require( "settings")
--local blueBg           = require( "app.backgrounds.deep_blue")
-- -------------------------------------------------------------------------------


-- "scene:create()"
local startGameTimer

function scene:create( event )

--[[print( settings.defaultFont )
local backgroundMusic = audio.loadStream( "sounds/music/menu.ogg" )
audio.play( backgroundMusic, { channel=1 } )
audio.setVolume( 0.2, { channel=1 } ) 
--]]
    local sceneGroup = self.view

    local uiGroup = display.newGroup( )
    sceneGroup:insert(uiGroup)
    -- Initialize the scene here
    -- Example: add display objects to "sceneGroup", add touch listeners, etc.
    --popMenu.addMenu(screen.right-10, screen.top+10)
    --blueBg.addBg(sceneGroup)
    require( "app.backgrounds.deep_dark").addBg(sceneGroup)



local onComplete = function( event )
   print( "video session ended" )
end
media.playVideo( "BigBuckBunny_640x360.m4v", true, onComplete )

	local playButton = display.newText( uiGroup, "PLAY", screen.centerX, screen.centerY, settings.defaultFontOblique, 50 )
	playButton.touch = function( self, event )
		if event.phase == "began" then
			self.alpha = 0.5
	        startGameTimer = timer.performWithDelay(400, function()
			local options = {
			    effect = "slideLeft",
			    time = 300,
			    params = { currentLevel = 2}
			}        	
	        	composer.gotoScene( scenes.game, options )
	        end)			
			elseif event.phase == "ended" then
			self.alpha = 1
		end
	end

	playButton:addEventListener( "touch", playButton )
end


-- "scene:show()"
function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Called when the scene is still off screen (but is about to come on screen)
	composer.removeScene( scenes.thankyou )        
    elseif ( phase == "did" ) then
        -- Called when the scene is now on screen
        -- Insert code here to make the scene come alive
        -- Example: start timers, begin animation, play audio, etc.

    end
end


-- "scene:hide()"
function scene:hide( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Called when the scene is on screen (but is about to go off screen)
        -- Insert code here to "pause" the scene
        -- Example: stop timers, stop animation, stop audio, etc.
        if startGameTimer then
            timer.cancel( startGameTimer )
            startGameTimer = nil
        end
    elseif ( phase == "did" ) then
        -- Called immediately after scene goes off screen
    end
end


-- "scene:destroy()"
function scene:destroy( event )

    local sceneGroup = self.view

    -- Called prior to the removal of scene's view
    -- Insert code here to clean up the scene
    -- Example: remove display objects, save state, etc.
    if startGameTimer then
        timer.cancel( startGameTimer )
        startGameTimer = nil
    end
end


-- -------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-- -------------------------------------------------------------------------------

return scene
