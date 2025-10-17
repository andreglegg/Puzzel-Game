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
local particleDesigner = require( "particles.particleDesigner" )
local settings          = require( "settings")
--local blueBg           = require( "app.backgrounds.deep_blue")

-- -------------------------------------------------------------------------------

local delay = 300 --7000
local nextSceneTimer

-- "scene:create()"
function scene:create( event )

    local sceneGroup = self.view

   require( "app.backgrounds.deep_dark").addBg(sceneGroup)


	local options = 
	{
	    --parent = textGroup,
	    text = "Hello World",     
	    x = screen.left+5,
	    y = screen.top+5,
	    width = 100,     --required for multi-line and alignment
	    font = settings.defaultFont,   
	    fontSize = 10,
	    align = "left"  --new alignment parameter
	}

		local betaIcon = display.newText( options)
		betaIcon.anchorX, betaIcon.anchorY = 0,0
		betaIcon.text = [[BETA
IN DEVELOPMENT]]

	local options = 
	{
	    --parent = textGroup,
	    text = "Hello World",     
	    x = screen.centerX,
	    y = screen.centerY,
	    width = screen.width*0.9,     --required for multi-line and alignment
	    font = settings.defaultFontOblique,   
	    fontSize = 14,
	    align = "center"  --new alignment parameter
	}

	local betaWarning = display.newText( options )
	betaWarning.text = [[ BETA SOFTWARE

This mobile game is in beta and does not currently have a name.
 

WARNING: This game is property of Andre Glegg, You are not allowed to reverse engineer, decompile or disassemble this game or any portion of it]]
	betaWarning.anchorX, betaWarning.anchorY = 0.5, 0.5
	sceneGroup:insert(betaWarning)
    -- Initialize the scene here
    -- Example: add display objects to "sceneGroup", add touch listeners, etc.
end


-- "scene:show()"
function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Called when the scene is still off screen (but is about to come on screen)
    elseif ( phase == "did" ) then
        -- Called when the scene is now on screen
        -- Insert code here to make the scene come alive
        -- Example: start timers, begin animation, play audio, etc.
        nextSceneTimer = timer.performWithDelay(delay, function()
			local options = {
			    effect = "fade",
			    time = 1000,
			    params = { }
			}        	
        	composer.gotoScene( scenes.menu, options )
        end)
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
        if nextSceneTimer then
            timer.cancel( nextSceneTimer )
            nextSceneTimer = nil
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
    if nextSceneTimer then
        timer.cancel( nextSceneTimer )
        nextSceneTimer = nil
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
