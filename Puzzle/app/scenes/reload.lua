local composer = require( "composer" )
local scene = composer.newScene()
local screen            = require( "libs.screen")
local settings          = require( "settings")
local particleDesigner  = require( "particles.particleDesigner" )
local lib               = require("libs.app5iveLib")
local scenes            = require( "app.scene_names" )

local currentLevel, moves, target
local totalLevels       = _G.totalLevels or 0

local activeTimers = {}
local activeTransitions = {}

local function trackTimer( ... )
    local handle = timer.performWithDelay( ... )
    activeTimers[#activeTimers + 1] = handle
    return handle
end

local function cancelTimers()
    for i = #activeTimers, 1, -1 do
        timer.cancel( activeTimers[i] )
        activeTimers[i] = nil
    end
    activeTimers = {}
end

local function queueTransition( target, params )
    if not target then
        return nil
    end
    local handle = transition.to( target, params )
    activeTransitions[#activeTransitions + 1] = handle
    return handle
end

local function cancelTransitions()
    for i = #activeTransitions, 1, -1 do
        transition.cancel( activeTransitions[i] )
        activeTransitions[i] = nil
    end
    activeTransitions = {}
end

local backgroundGroupRef, starsGroupRef, textGroupRef, statsGroupRef, buttonGroupRef


function scene:create( event )
    local sceneGroup = self.view
    cancelTimers()
    cancelTransitions()

    local params = event.params or {}
    currentLevel = params.currentLevel or 1
    moves = tonumber(params.moves) or 0
    target = tonumber(params.target) or 0
    local backgroundGroup = display.newGroup( )
    local starsGroup = display.newGroup( )
    local textGroup = display.newGroup( )
    local statsGroup = display.newGroup( )

    backgroundGroupRef = backgroundGroup
    starsGroupRef = starsGroup
    textGroupRef = textGroup
    statsGroupRef = statsGroup
    
    sceneGroup:insert( backgroundGroup )
    sceneGroup:insert( textGroup )
    sceneGroup:insert( starsGroup )
    sceneGroup:insert( statsGroup )

    local   function emit(group, particle, x, y)
        local emitter = particleDesigner.newEmitter( "particles/".. particle ..".json" )
        emitter.x = x
        emitter.y = y
        group:insert( emitter )            
        return emitter
    end

    require( "app.backgrounds.deep_dark").addBg(backgroundGroup) 




    local starSize = 70
    local starxOffset = 80
    local staryOffset = 15
    local firstAnimationTime = 500
    local secondAnimationTime = 400
    local toastY = screen.centerY+70
    local toast = "Good!"

    local star1Outline = display.newImageRect( starsGroup, "images/starout.png", starSize, starSize )
    star1Outline.x, star1Outline.y = screen.centerX-starxOffset, screen.centerY
    star1Outline.rotation = -15

    local star2Outline = display.newImageRect( starsGroup, "images/starout.png", starSize, starSize )
    star2Outline.x, star2Outline.y = screen.centerX, screen.centerY-staryOffset

    local star3Outline = display.newImageRect( starsGroup, "images/starout.png", starSize, starSize )
    star3Outline.x, star3Outline.y = screen.centerX+starxOffset, screen.centerY
    star3Outline.rotation = 15  

    starsGroup.y = -80

    local numberOfStars 

    if moves <= target then
        numberOfStars = 3
    elseif moves > target and moves <= target+3 then
        numberOfStars = 2
    else
        numberOfStars = 1
    end

  



  

   

    if numberOfStars == 3 then
         toast = "Perfect!"
        local star1 = display.newImageRect( starsGroup, "images/star.png", starSize/2, starSize/2 )
        star1.x, star1.y = screen.centerX-starxOffset+50, screen.centerY+100
        star1.rotation = -15
        starsGroup:insert(star1Outline)          
        queueTransition( star1, { time = firstAnimationTime,  x = star1Outline.x-starSize/2, y = star1Outline.y-starSize, xScale = 1.5, yScale = 1.5, transition =easing.outCubic,onComplete = function( )
            starsGroup:insert(star1)
                queueTransition( star1, { time = secondAnimationTime, x = star1Outline.x, y = star1Outline.y, xScale = 2, yScale = 2, transition = easing.inCubic,onComplete = function( )
                display.remove( star1Outline )
                local starGlow = emit(starsGroup, "starGlow", star1.x, star1.y)
             end} )

        end } )

        local star2 = display.newImageRect( starsGroup, "images/star.png", starSize/2, starSize/2 )
        star2.x, star2.y = screen.centerX, screen.centerY+100
        starsGroup:insert(star1Outline)    
        queueTransition( star2, { time = firstAnimationTime, x = star2Outline.x, y = star2Outline.y-starSize, xScale = 1.5, yScale = 1.5, transition =easing.outCubic,onComplete = function( )
            starsGroup:insert(star2)
                queueTransition( star2, { time = secondAnimationTime, x = star2Outline.x, y = star2Outline.y, xScale = 2, yScale = 2, transition = easing.inCubic,onComplete = function( )
                display.remove( star2Outline )
             
                local starGlow = emit(starsGroup, "starGlow", star2.x, star2.y)
             end} )

        end } )  

        local star3 = display.newImageRect( starsGroup, "images/star.png", starSize/2, starSize/2 )
        star3.x, star3.y = screen.centerX+starxOffset-50, screen.centerY+100
        star3.rotation = 15
        starsGroup:insert(star1Outline) 
        queueTransition( star3, { time = firstAnimationTime, x = star3Outline.x+starSize/2, y = star3Outline.y-starSize, xScale = 1.5, yScale = 1.5, transition =easing.outCubic,onComplete = function( )
            starsGroup:insert(star3)
                queueTransition( star3, { time = secondAnimationTime, x = star3Outline.x, y = star3Outline.y, xScale = 2, yScale = 2, transition = easing.inCubic,onComplete = function( )
                display.remove( star3Outline )
                local starGlow = emit(starsGroup, "starGlow", star3.x, star3.y)
             end} )

        end } )    
    elseif numberOfStars == 2 then
         toast = "Awesome!"
        local star1 = display.newImageRect( starsGroup, "images/star.png", starSize/2, starSize/2 )
        star1.x, star1.y = screen.centerX-starxOffset+50, screen.centerY+100
        star1.rotation = -15
        starsGroup:insert(star1Outline)          
        queueTransition( star1, { time = firstAnimationTime,  x = star1Outline.x-starSize/2, y = star1Outline.y-starSize, xScale = 1.5, yScale = 1.5, transition =easing.outCubic,onComplete = function( )
            starsGroup:insert(star1)
                queueTransition( star1, { time = secondAnimationTime, x = star1Outline.x, y = star1Outline.y, xScale = 2, yScale = 2, transition = easing.inCubic,onComplete = function( )
                display.remove( star1Outline )
                local starGlow = emit(starsGroup, "starGlow", star1.x, star1.y)
             end} )

        end } )
        local star3 = display.newImageRect( starsGroup, "images/star.png", starSize/2, starSize/2 )
        star3.x, star3.y = screen.centerX+starxOffset-50, screen.centerY+100
        star3.rotation = 15
        starsGroup:insert(star1Outline)         
        queueTransition( star3, { time = firstAnimationTime, x = star3Outline.x+starSize/2, y = star3Outline.y-starSize, xScale = 1.5, yScale = 1.5, transition =easing.outCubic,onComplete = function( )
            starsGroup:insert(star3)
                queueTransition( star3, { time = secondAnimationTime, x = star3Outline.x, y = star3Outline.y, xScale = 2, yScale = 2, transition = easing.inCubic,onComplete = function( )
                display.remove( star3Outline )
                local starGlow = emit(starsGroup, "starGlow", star3.x, star3.y)
             end} )

        end } )   
    else

        local star2 = display.newImageRect( starsGroup, "images/star.png", starSize/2, starSize/2 )
        star2.x, star2.y = screen.centerX, screen.centerY+100
        starsGroup:insert(star1Outline)            
        queueTransition( star2, { time = firstAnimationTime, x = star2Outline.x, y = star2Outline.y-starSize, xScale = 1.5, yScale = 1.5, transition =easing.outCubic,onComplete = function( )
            starsGroup:insert(star2)
                queueTransition( star2, { time = secondAnimationTime, x = star2Outline.x, y = star2Outline.y, xScale = 2, yScale = 2, transition = easing.inCubic,onComplete = function( )
                display.remove( star2Outline )
                local stream = emit(textGroup, "stream", screen.centerX-screen.width/2, toastY)  
                stream.alpha = 0.1              
                local starGlow = emit(starsGroup, "starGlow", star2.x, star2.y)
             end} )

        end } )  

    end


    local levelCompleteText = display.newText( textGroup, "Level ".. currentLevel .." Completed", screen.centerX, star2Outline.y - starSize  , settings.defaultFontOblique, 30 )
    queueTransition( levelCompleteText, {time=2000, y = levelCompleteText.y-90, transition =  easing.outElastic} )
   
    local statsBg = display.newImageRect( backgroundGroup, "images/statsBg.png", 573, 52 )
    statsBg.x, statsBg.y = screen.centerX, screen.centerY
    statsBg.alpha = 0
    local movesText = display.newText( statsGroup, "Moves: ", screen.centerX, screen.centerY, settings.defaultFont, 20 )
    movesText.anchorX = 0
    local movesDisplay = display.newText( statsGroup, moves, movesText.x + movesText.contentWidth, screen.centerY, settings.defaultFont, 20 )
    movesDisplay.anchorX = 0; movesDisplay:setFillColor(lib.convertHexToRGB("#F5A623"))   
    local sep1 = display.newText( statsGroup, " / ", movesDisplay.x+movesDisplay.contentWidth, screen.centerY, settings.defaultFont, 30 )
    sep1.anchorX = 0
    local targetText = display.newText( statsGroup, "Target: ", sep1.x+sep1.contentWidth, screen.centerY, settings.defaultFont, 20 )
    targetText.anchorX = 0
    local targetDisplay = display.newText( statsGroup, target, targetText.x+targetText.contentWidth, screen.centerY, settings.defaultFont, 20 )
    targetDisplay.anchorX = 0; targetDisplay:setFillColor(lib.convertHexToRGB("#F5A623")) 
    local sep2 = display.newText( statsGroup, " / ", targetDisplay.x+targetDisplay.contentWidth, screen.centerY, settings.defaultFont, 30 )
    sep2.anchorX = 0
    local bestText = display.newText( statsGroup, "Best: ", sep2.x+sep2.contentWidth, screen.centerY, settings.defaultFont, 20 )
    bestText.anchorX = 0
    local bestDisplay = display.newText( statsGroup, "3", bestText.x+bestText.contentWidth, screen.centerY, settings.defaultFont, 20 )
    bestDisplay.anchorX = 0; bestDisplay:setFillColor(lib.convertHexToRGB("#F5A623")) 

    statsGroup.anchorChildren = true
    statsGroup.anchorX, statsGroup.anchorY = 0.5, 0.5
    statsGroup.x, statsGroup.y = screen.centerX, screen.centerY

    local toastText

    local timerid = trackTimer(900, function()
        toastText = display.newText( textGroup, toast, screen.centerX+100, toastY, settings.defaultFontOblique, 70 )
        queueTransition( toastText, {time=1000, x = toastText.x-100, transition =  easing.outElastic } )
        local flare = emit(sceneGroup, "flare", screen.centerX-100, toastText.y)

        local flash = display.newCircle( sceneGroup, screen.centerX, toastY, screen.height )
        flash.xScale = 0.01; flash.yScale = 0.01
        flash.alpha = 0
        queueTransition( flash, {time=800, xScale= 1, yScale = 1, alpha =0.9, onComplete = function (  )
                            local stream = emit(textGroup, "stream", screen.centerX-screen.width/2, toastY)  
                stream.alpha = 0.1 
            queueTransition( flash, {time=500, alpha = 0, onComplete = function( )
                display.remove( flash )
            end} )

        end} )
    end)

    local buttonGroup = display.newGroup( )
    buttonGroupRef = buttonGroup

    local nextLevelButton = display.newImageRect( buttonGroup, "images/nextLevelButton.png", 127.4, 49 )
    nextLevelButton.x, nextLevelButton.y = screen.centerX, screen.centerY+155
    nextLevelButton.touch = function( self, event )
        if event.phase == "began" then
            self.alpha = 0.5
            local timerid = trackTimer(400, function()

            if currentLevel == totalLevels then
                --print( "go to thank you... blank screen" )
                                    local options = {
                                    effect = "fade",
                                    time = 1000,
                                }   
                composer.gotoScene( scenes.thankyou, options )
                --return nil
            else

            --local timerid = timer.performWithDelay(100, function()
                                local options = {
                                    effect = "slideLeft",
                                    time = 300,
                                    params = { currentLevel = currentLevel+1}
                                }       
                composer.gotoScene( scenes.game, options )
            --end)
            end
            end) 


            elseif event.phase == "ended" then
            self.alpha = 1


        end
    end

    nextLevelButton:addEventListener( "touch", nextLevelButton )
    local sharAlpha = 0.5
    local shareButton = display.newImageRect( buttonGroup, "images/shareButtonDisabled.png", 118.3, 49 )
    shareButton.x, shareButton.y = nextLevelButton.x + nextLevelButton.contentWidth, screen.centerY+155
    shareButton.alpha = 0.5
    shareButton.touch = function( self, event )
        if event.phase == "began" then
            self.alpha = 0.5
            elseif event.phase == "ended" then
            self.alpha = sharAlpha

            -- Handler that gets notified when the alert closes
            local function onComplete( event )
                if ( event.action == "clicked" ) then
                    local i = event.index
                    if ( i == 1 ) then
                        -- Do nothing; dialog will simply dismiss
                        print( "closed beta popup" )
                    end
                end
            end

            -- Show alert with two buttons
            local alert = native.showAlert( "Beta", "This feature is not available in during testing", { "OK" }, onComplete )
 
        end
    end

    shareButton:addEventListener( "touch", shareButton )

    sceneGroup:insert( buttonGroup )
    buttonGroup.anchorChildren = true
    buttonGroup.x, buttonGroup.y = screen.centerX, screen.centerY+150


end

-- "scene:show()"
function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Called when the scene is still off screen (but is about to come on screen)
     composer.removeScene( scenes.game )       
    elseif ( phase == "did" ) then
        -- Called when the scene is now on screen
        -- Insert code here to make the scene come alive
        -- Example: start timers, begin animation, play audio, etc.

    end

--[[

if currentLevel == totalLevels then
	--print( "go to thank you... blank screen" )
						local options = {
						effect = "slideLeft",
						time = 1000,
					}   
	composer.gotoScene( scenes.thankyou, options )
	--return nil
else

--local timerid = timer.performWithDelay(100, function()
					local options = {
						effect = "slideLeft",
						time = 300,
					    params = { currentLevel = currentLevel+1}
					}   	
	composer.gotoScene( scenes.game, options )
--end)
end
]]

end


-- "scene:hide()"
function scene:hide( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Called when the scene is on screen (but is about to go off screen)
        -- Insert code here to "pause" the scene
        -- Example: stop timers, stop animation, stop audio, etc.
        cancelTimers()
        cancelTransitions()
        starsGroupRef, textGroupRef, statsGroupRef, buttonGroupRef = nil, nil, nil, nil
    elseif ( phase == "did" ) then
        -- Called immediately after scene goes off screen
        composer.removeScene( scenes.reload )
    end
end


-- "scene:destroy()"
function scene:destroy( event )

    local sceneGroup = self.view

    -- Called prior to the removal of scene's view
    -- Insert code here to clean up the scene
    -- Example: remove display objects, save state, etc.
    cancelTimers()
    cancelTransitions()
    starsGroupRef, textGroupRef, statsGroupRef, buttonGroupRef = nil, nil, nil, nil
    backgroundGroupRef = nil

end


-- -------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-- -------------------------------------------------------------------------------

return scene
