
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
display.setDefault( "background", lib.convertHexToRGB("#0A579B") )
-- -------------------------------------------------------------------------------

local delay = 10000 --7000
local returnTimer

-- "scene:create()"
function scene:create( event )

    local sceneGroup = self.view

	local   function emit(particle, x, y)
        local emitter = particleDesigner.newEmitter( "particles/".. particle ..".json" )
        emitter.x = x
        emitter.y = y
        sceneGroup:insert( emitter )
        return emitter
    end

	local stars = emit("stars", screen.centerX, screen.centerY)  
	stars.alpha = 0.3  

	local options = 
	{
	    --parent = textGroup,
	    text = "Hello World",     
	    x = screen.centerX,
	    y = screen.centerY,
	    width = screen.width*0.9,     --required for multi-line and alignment
	    font = native.systemFontBold,   
	    fontSize = 14,
	    align = "center"  --new alignment parameter
	}

	local betaWarning = display.newText( options )
	betaWarning.text = [[THANKS FOR TESTING!

Congratulations! you've completed all the levels currently available for testing. This game in development(BETA) a lot might be different when it is released.]]
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
	composer.removeScene( scenes.reload )
        
    elseif ( phase == "did" ) then
        -- Called when the scene is now on screen
        -- Insert code here to make the scene come alive
        -- Example: start timers, begin animation, play audio, etc.
        returnTimer = timer.performWithDelay(delay, function()
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
        if returnTimer then
            timer.cancel( returnTimer )
            returnTimer = nil
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
    if returnTimer then
        timer.cancel( returnTimer )
        returnTimer = nil
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
