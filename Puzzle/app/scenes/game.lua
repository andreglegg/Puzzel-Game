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
local stopwatch          = require "libs.stopwatch"
------------------------------
local performance = require('libs.performance')

------------------------------

-- -------------------------------------------------------------------------------
local GRID_WIDTH = 2
local GRID_HEIGHT = 2
local CELL_WIDTH = 80
local CELL_HEIGHT = 80
local CELL_SPACING = 0
local Y_OFFSET = 0

local finishes = 0
local finishCount = 0
local spawndelay = 400

local pieces = {}
local directionToMove = "none"

local thisLevel
local currentLevel 

local moves = 0
local touchBox

local tutorialTitleText

local xChain, yChain = {}, {}
local isXChain, isYChain = false, false

local tp1, tp2, tp3 = {},{},{}

local teleportObject

local hideTouch = true

-- "scene:create()"
function scene:create( event )
	moves = 0
	finishes = 0
	finishCount = 0
	pieces = {}
	directionToMove = "none"
	xChain, yChain = {}, {}
	isXChain, isYChain = false, false
	tp1, tp2, tp3 = {}, {}, {}
	teleportObject = nil
	hideTouch = true
	touchBox = nil

	currentLevel = event.params.currentLevel or 1
	local thisLevel 	= require( "levels.level".. currentLevel)


	--print( level.[1] )

	composer.removeScene( scenes.reload )

	 GRID_WIDTH = thisLevel[1].gw
	 GRID_HEIGHT = thisLevel[1].gh
	 CELL_WIDTH = thisLevel[1].cw
	 CELL_HEIGHT = thisLevel[1].ch

    local sceneGroup = self.view

    local backgroundGroup = display.newGroup( )
    local gridGroup = display.newGroup( )
    local objectsGroup = display.newGroup( )
    local uiGroup = display.newGroup( )

    sceneGroup:insert(backgroundGroup)
    sceneGroup:insert(gridGroup)
    sceneGroup:insert(objectsGroup)
    sceneGroup:insert(uiGroup)
    -- Initialize the scene here
    -- Example: add display objects to "sceneGroup", add touch listeners, etc.
	--performance:newPerformanceMeter()
    local movesDisplay 
    local levelDisplay
    local movesText
    local bestText
    local targetText
    local timeDisplay
    local levelText
    local reloadTextDisplay
	local uiTextGroup = display.newGroup( )
    function makeUi()
    	-- body
    	
    	local pauseButton = display.newImageRect( uiTextGroup, "images/icons/pause.png",  116.4, 100 )
    	pauseButton.x, pauseButton.y = screen.left + 10, screen.bottom - 10
    	pauseButton.anchorX, pauseButton.anchorY = 0, 1
    	pauseButton.xScale, pauseButton.yScale = 0.5, 0.5

    	local helpButton = display.newImageRect( uiTextGroup, "images/icons/help.png",  71, 100 )
    	helpButton.x, helpButton.y = pauseButton.x+pauseButton.contentWidth, pauseButton.y
    	helpButton.anchorX, helpButton.anchorY = 0, 1
		helpButton.xScale, helpButton.yScale = 0.5, 0.5

    	local shopButton = display.newImageRect( uiTextGroup, "images/icons/shop.png",  116.4, 100 )
    	shopButton.x, shopButton.y = screen.right - 10, screen.bottom - 10
    	shopButton.anchorX, shopButton.anchorY = 1, 1
    	shopButton.xScale, shopButton.yScale = 0.5, 0.5

    	local inventoryButton = display.newImageRect( uiTextGroup, "images/icons/inventory.png",  71, 100 )
    	inventoryButton.x, inventoryButton.y = shopButton.x-shopButton.contentWidth, shopButton.y
    	inventoryButton.anchorX, inventoryButton.anchorY = 1, 1
		inventoryButton.xScale, inventoryButton.yScale = 0.5, 0.5    	

    	local reloadButton = display.newImageRect( uiTextGroup, "images/icons/reload.png",  200, 210 )
    	reloadButton.x, reloadButton.y = screen.centerX, screen.bottom - 10
    	reloadButton.anchorX, reloadButton.anchorY = 0.5, 1
    	reloadButton.xScale, reloadButton.yScale = 0.5, 0.5

    	Y_OFFSET = (reloadButton.height*0.5) 
    	

    	local targetDisplay = display.newText( uiTextGroup, thisLevel[1].target, pauseButton.x+pauseButton.width/1.8, pauseButton.y-pauseButton.height/1.8, settings.defaultFontOblique, 16 )
    	targetDisplay.anchorX, targetDisplay.anchorY = 1, 1
    	targetDisplay:setFillColor(lib.convertHexToRGB("#F5A623"))

    	targetText = display.newText( uiTextGroup, "TARGET:", targetDisplay.x-targetDisplay.width-1, targetDisplay.y, settings.defaultFontOblique, 16 )
    	targetText.anchorX, targetText.anchorY = 1, 1
    	
    	movesDisplay = display.newText( uiTextGroup, moves, targetDisplay.x+10, targetDisplay.y-(targetDisplay.height), settings.defaultFontOblique, 23 )
    	movesDisplay.anchorX, movesDisplay.anchorY = 1, 1
    	movesDisplay:setFillColor(lib.convertHexToRGB("#F5A623"))


    	movesText = display.newText( uiTextGroup, "MOVES:", movesDisplay.x-movesDisplay.width-1, movesDisplay.y, settings.defaultFontOblique, 23 )
    	movesText.anchorX, movesText.anchorY = 1, 1


    	bestText = display.newText( uiTextGroup, "BEST:", shopButton.x-shopButton.width/1.8, shopButton.y-shopButton.height/1.8, settings.defaultFontOblique, 16 )
    	bestText.anchorX, bestText.anchorY = 0, 1

    	bestDisplay = display.newText( uiTextGroup, "3", bestText.x+bestText.width+1, shopButton.y-shopButton.height/1.8, settings.defaultFontOblique, 16 )
    	bestDisplay.anchorX, bestDisplay.anchorY = 0, 1
    	bestDisplay:setFillColor(lib.convertHexToRGB("#F5A623"))
    	
  
    	levelText = display.newText( uiTextGroup, "LEVEL:", bestText.x-10, bestText.y-bestText.height, settings.defaultFontOblique, 23 )
    	levelText.anchorX, levelText.anchorY = 0, 1

    	levelDisplay = display.newText( uiTextGroup, currentLevel, levelText.x+levelText.width, targetDisplay.y-(targetDisplay.height), settings.defaultFontOblique, 23 )
    	levelDisplay.anchorX, levelDisplay.anchorY = 0, 1
    	levelDisplay:setFillColor(lib.convertHexToRGB("#F5A623"))

    	reloadTextDisplay = display.newText( uiTextGroup, "10", reloadButton.x , reloadButton.y-3 , settings.defaultFontOblique, 12 )
    	reloadTextDisplay.anchorY = 1
    	reloadTextDisplay:setFillColor(lib.convertHexToRGB("#1e1e1e"))
    	
    	uiTextGroup.anchorChildren = true
    	uiTextGroup.x, uiTextGroup.y = screen.centerX, screen.bottom+uiTextGroup.height
    	uiTextGroup.anchorY = 1

    	transition.to( uiTextGroup, {delay =400, y= screen.bottom-10, time=200, transition=easing.outBack } )
    	 
    	uiGroup:insert(uiTextGroup)
    end
    makeUi()
	--stopwatch:new()
    --print( stopwatch:getElapsedSeconds() )
 

local function updateUiText()
	levelDisplay.text = currentLevel
	levelDisplay.x = levelText.x+levelText.width+1
    movesDisplay.text = moves
    movesText.x = movesDisplay.x-movesDisplay.width-1	
end   
		touchBox = display.newRect( uiGroup, screen.centerX, screen.centerY, screen.width, screen.height )

		touchBox.alpha = 0.01



	local   function emit(group, particle, x, y)
        local emitter = particleDesigner.newEmitter( "particles/".. particle ..".json" )
        emitter.x = x
        emitter.y = y
        group:insert( emitter )
        return emitter
    end

require( "app.backgrounds.deep_dark").addBg(backgroundGroup) 



function print_r ( t )  
    local print_r_cache={}
    local function sub_print_r(t,indent)
        if (print_r_cache[tostring(t)]) then
            print(indent.."*"..tostring(t))
        else
            print_r_cache[tostring(t)]=true
            if (type(t)=="table") then
                for pos,val in pairs(t) do
                    if (type(val)=="table") then
                        print(indent.."["..pos.."] => "..tostring(t).." {")
                        sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
                        print(indent..string.rep(" ",string.len(pos)+6).."}")
                    elseif (type(val)=="string") then
                        print(indent.."["..pos..'] => "'..val..'"')
                    else
                        print(indent.."["..pos.."] => "..tostring(val))
                    end
                end
            else
                print(indent..tostring(t))
            end
        end
    end
    if (type(t)=="table") then
        print(tostring(t).." {")
        sub_print_r(t,"  ")
        print("}")
    else
        sub_print_r(t,"  ")
    end
    print()
end
 

	--
	-- Grid Holder
	local gridHolder = display.newGroup( )
	local piecesGroup = display.newGroup( )
	local piecesBottom = display.newGroup( )
	local piecesMid = display.newGroup( )
	local piecesTop = display.newGroup( )
	piecesGroup:insert(piecesBottom)
	piecesGroup:insert(piecesMid)
	piecesGroup:insert(piecesTop)

	--
	-- Create a 2D array to hold our objects.
	local grid = {}
	for x=1, GRID_WIDTH do
	    grid[x] = {}
	    for y=1, GRID_HEIGHT do
	    	local xPos, yPos = (x-1) * (CELL_WIDTH + CELL_SPACING), (y-1) * (CELL_HEIGHT + CELL_SPACING)
	    	--grid[x][y] = display.newRect( xPos, yPos, CELL_WIDTH, CELL_HEIGHT )

	    	local bgPiece = "topLeft"

	    	if x == GRID_WIDTH and y == 1 then
	    		bgPiece = "topRight"
	    	elseif x == 1 and y == GRID_HEIGHT then
	    		bgPiece = "bottomLeft"
	    	elseif x == GRID_WIDTH and y == GRID_HEIGHT then
	    		bgPiece = "bottomRight"
	    	elseif x > 1 and x < GRID_WIDTH and y == 1 then
	    		bgPiece = "top"
	    	elseif x > 1 and x < GRID_WIDTH and y == GRID_HEIGHT then
	    		bgPiece = "bottom"
	    	elseif x == 1 and y > 1 and y < GRID_HEIGHT then
	    		bgPiece = "left"
	    	elseif x == GRID_WIDTH and y > 1 and y < GRID_HEIGHT then
	    		bgPiece = "right"
	    	elseif x > 1 and x < GRID_WIDTH and y > 1 and y < GRID_HEIGHT then
	    		bgPiece = "middle"
	    	end 

	    	local gridMargin = 45/100 * screen.width

	    	if GRID_WIDTH > 2 then
	    		gridMargin = 35/100 * screen.width
	    	end
	    	if GRID_WIDTH > 4 then
	    		gridMargin = 15/100 * screen.width
	    	end
	    	--if GRID_WIDTH * CELL_WIDTH > screen.width-20 then
	    		CELL_WIDTH, CELL_HEIGHT = (screen.width-gridMargin) / GRID_WIDTH, (screen.width-gridMargin) / GRID_WIDTH --CELL_WIDTH*0.5, CELL_HEIGHT*0.5
	    	--end
	    	grid[x][y] = display.newImageRect("images/grid/grey/".. bgPiece ..".png", CELL_WIDTH, CELL_HEIGHT )
	    	grid[x][y].x, grid[x][y].y = xPos, yPos
	        grid[x][y].hasPiece = false
	        grid[x][y].type = "empty"
	        gridHolder:insert(grid[x][y])
	        grid[x][y].status = display.newText(gridHolder, tostring(grid[x][y].type), xPos, yPos, native.systemFont, 10 )
	        grid[x][y].status.alpha = 0
	        grid[x][y].enterFrame = function(self, event)
	        	grid[x][y].status.text = tostring( grid[x][y].type )
	        end
	        Runtime:addEventListener("enterFrame", grid[x][y])
	    end
	end



	gridHolder.anchorX = 0.5
	gridHolder.anchorY = 0.5

	gridHolder.anchorChildren = true

	gridHolder.x = screen.centerX 
	gridHolder.y = (screen.height - uiTextGroup.height-20)/2 --screen.bottom - Y_OFFSET

	gridHolder:insert(piecesGroup)
	gridGroup:insert( gridHolder )


	local finger2 = display.newImageRect( piecesGroup, "images/finger.png", 50, 78 )
	finger2.anchorY = 0
	finger2.alpha = 0

local function movePiece( direction )

 print(  )

	local function compare( a, b )
		if direction == "up" then
	    	return a.y < b.y
		elseif direction == "down" then
			return a.y > b.y
		elseif direction == "left" then
			return a.x < b.x
		elseif direction == "right" then
			return a.x > b.x
		end
	end

	table.sort( pieces, compare )

	--print_r(pieces)


	local function checkFinish(xTo,yTo)
		--if grid[xTo][yTo].finish == true and grid[xTo][yTo].type == "moveable" then
		-- body
		
			print( "finish count: "..finishCount )
		if finishCount == finishes then
			print( "Stage Cleared!" )
			touchBox:removeEventListener("touch", touchBox )
			--touchBox:removeSelf( )
			--touchBox = nil
			local function nextLevel( )	
			

				local timerid = timer.performWithDelay(800, function()
					local options = {
					    effect = "fromBottom",
					    time = 300,
					    params = { currentLevel = currentLevel, moves = moves, target = thisLevel[1].target }
					}     					
					composer.gotoScene( scenes.reload, options )
				end)
			end

			local theDelay = 250

			for i = 1, #pieces do
				if pieces[i].type == "finish" then
				transition.to( pieces[i], { rotation=pieces[i].rotation + 360*2, time=500, transition=easing.inOutCubic, onComplete=nextLevel })
				local timerid = timer.performWithDelay(theDelay, function()
				emit(piecesGroup, "ring_explode", pieces[i].x, pieces[i].y) 
				theDelay = theDelay + theDelay

				--print( theDelay )					
				end)
				end
			end

		end
		--elseif grid[xTo][yTo].type2 == "normal" then
		
		--end

		--print( "Finish Count: " .. finishCount )

	end

	local function checkRange(xTo, yTo)
		if xTo < 1 or xTo > GRID_WIDTH or yTo < 1 or yTo > GRID_HEIGHT then
			--print( "Position out of range:", xTo, yTo )
			return false
--		elseif yTo-1 < 1 then
--			return false
		else
			return true
		end

	end

	local function checkMove(xTo, yTo)
		if grid[xTo][yTo].type == "nomove" then
				--print( "nomove", yTo )
			return false
		else
				--print( "move: ", yTo )
			return true
		end

	end

	local function checkDoubleChain(xTo, yTo)
		if grid[xTo][yTo].hasPiece  then
				--print( "cant move because hasPiece: ", xTo, yTo )
			return false
		else
				--print( "move to: ", xTo, yTo )
			return true
		end

	end


	local function checkPush(xPos, yPos)
		if direction == "up" and grid[xPos][yPos+1] and grid[xPos][yPos+1].type == "moveable"
		or direction == "up" and grid[xPos][yPos+1] and grid[xPos][yPos+1].type == "push" and grid[xPos][yPos+2] and grid[xPos][yPos+2].type == "moveable" then
			return true
		elseif direction == "down" and grid[xPos][yPos-1] and grid[xPos][yPos-1].type == "moveable"
		or direction == "down" and grid[xPos][yPos-1] and grid[xPos][yPos-1].type == "push" and grid[xPos][yPos-2] and grid[xPos][yPos-2].type == "moveable" then
			return true
		elseif direction == "left" and grid[xPos+1] and grid[xPos+1][yPos].type == "moveable"
			or direction == "left" and grid[xPos+1] and grid[xPos+1][yPos].type == "push" and grid[xPos+2] and grid[xPos+2][yPos].type == "moveable" then
			return true
		elseif direction == "right" and grid[xPos-1] and grid[xPos-1][yPos].type == "moveable"
			or direction == "right" and grid[xPos-1] and grid[xPos-1][yPos].type == "push" and grid[xPos-2] and grid[xPos-2][yPos].type == "moveable" then
			return true
		end
		return false
	end



					local thisTime = 100

					 function teleportObject(object)
						-- body
						print( "finished move to: ", tp1.x, tp1.y )
						--object.x, object.y = grid[tp1.x][tp1.y].x, grid[tp1.x][tp1.y].y
						local function bounceAnimation(object)
							local tpAnimation = emit(piecesGroup, "blurTp", grid[tp1.x][tp1.y].x, grid[tp1.x][tp1.y].y)
							
						end
						--object.width, object.height = object.width/5, object.height/5
						--print( tp1.x , tp1.y )
						transition.to(object, { time = 1, delay = thisTime*5, x = grid[tp1.x][tp1.y].x, y = grid[tp1.x][tp1.y].y,transition= thisTransition, onComplete=bounceAnimation})
						grid[object.xPos][object.yPos].hasPiece = false
						grid[object.xPos][object.yPos].type = "blueTp"
						grid[object.xPos][object.yPos].type2 = "blueTp"
						object.xPos,object.yPos  = tp1.x, tp1.y
						grid[tp1.x][tp1.y].hasPiece = true
						--grid[xTo][yTo].type = "moveable"
						
						local timerid = timer.performWithDelay(150, function()
							hideTouch = false
						end)

					end


	local thisTransition =  easing.outBack
	local thisTime = 100
	local xTo, yTo



	finishCount = 0

	for i = 1, #pieces do
		local piece = pieces[i]


		if piece.type == "moveable" or piece.type == "push" or piece.type == "dumb" then
			if piece.type == "moveable" then
				moves = moves + 1
				hideTouch = true
			end
			xTo, yTo = piece.xPos, piece.yPos

			local function ifFinish(  )
				if piece.type == "mooveable" then
					if not grid[piece.xPos][piece.yPos].finish and grid[xTo][yTo].finish then
						finishCount = finishCount + 1	
					elseif not grid[xTo][yTo].finish then
						finishCount = finishCount - 1
					end
				end				
			end
			------------------
			if direction == "up" then
				yTo = piece.yPos-1
				if checkRange(xTo, yTo) and checkMove(xTo, yTo) and checkDoubleChain(xTo, yTo) then
					--print( "in range", xTo, yTo )					
					ifFinish()

				else
					yTo = piece.yPos
				end	
			-------------------	
			elseif direction == "down" then
				yTo = piece.yPos+1
				if checkRange(xTo, yTo) and checkMove(xTo, yTo) and checkDoubleChain(xTo, yTo) then
					--print( "in range", xTo, yTo )
					ifFinish()
				else
					yTo = piece.yPos
				end

			-------------------
			elseif direction == "left" then
				xTo = piece.xPos-1			
				if checkRange(xTo, yTo) and checkMove(xTo, yTo) and checkDoubleChain(xTo, yTo) then
					--print( "in range", xTo, yTo )
					if grid[xTo+2] and grid[xTo+2][yTo].type == "moveable" then
						print( "Double" )
					end
					ifFinish()					
				else
					xTo = piece.xPos
				end
				
			-------------------
			elseif direction == "right" then
				xTo = piece.xPos+1
				if checkRange(xTo, yTo) and checkMove(xTo, yTo) and checkDoubleChain(xTo, yTo) then
					--print( "in range", xTo, yTo )
					ifFinish()

 				else
					xTo = piece.xPos
				end	
									
			end			
			------------------
				if piece.type == "push" and not checkPush(piece.xPos, piece.yPos) then
					xTo, yTo = piece.xPos, piece.yPos
				end	
			----------		

				if grid[xTo][yTo].type2 == "blueTp" and piece.type == "moveable" then
					print( "wow" )


					local tpAnimation = emit(piecesGroup, "firstBlurTp", grid[xTo][yTo].x, grid[xTo][yTo].y)
					grid[piece.xPos][piece.yPos].hasPiece = false
					grid[piece.xPos][piece.yPos].type = "empty"
					piece.xPos,piece.yPos  = xTo, yTo
					grid[xTo][yTo].hasPiece = true
					grid[xTo][yTo].type2 = "blueTp"
					grid[xTo][yTo].type = "blueTp"
					transition.to(piece, { time = thisTime, x = grid[xTo][yTo].x, y = grid[xTo][yTo].y,transition= thisTransition, onComplete=teleportObject(piece)})

			
				else
			----------	
				--- Check if piece is on an arrow
				local currentlyTransition = false
				local isFirstTransition = true
				local delay

				local function flashArrows(image)
							local flashArrow = display.newImageRect( piecesBottom, "images/".. image ..".png", CELL_WIDTH*.7, CELL_HEIGHT*.7 )
							--flashArrow.fill.effect = "filter.invert"
							flashArrow:setFillColor(lib.convertHexToRGB("#F5A623"))
							flashArrow.alpha = 0.6
							flashArrow.x, flashArrow.y = grid[piece.xPos][piece.yPos].x, grid[piece.xPos][piece.yPos].y
							transition.fadeOut( flashArrow, {delay=150,time=500, transition=  easing.outCirc, onComplete = function( )
								flashArrow:removeSelf( )
								flashArrow = nil
							end} )					
				end

					local function arrowFunction(  )
						--print( grid[piece.xPos][piece.yPos].isRightArrow )
						hideTouch = true
						local xTo, yTo = piece.xPos, piece.yPos
						local thisDelay = 300

						local currentArrow = "none"

						if grid[piece.xPos][piece.yPos].isRightArrow then
							currentArrow = "rightArrow"
							xTo, yTo = piece.xPos+1, piece.yPos

						elseif grid[piece.xPos][piece.yPos].isUpArrow then
							currentArrow = "upArrow"
							xTo, yTo = piece.xPos, piece.yPos-1

						elseif grid[piece.xPos][piece.yPos].isDownArrow then
							currentArrow = "downArrow"
							xTo, yTo = piece.xPos, piece.yPos+1

						elseif grid[piece.xPos][piece.yPos].isLeftArrow then
							currentArrow = "leftArrow"
							xTo, yTo = piece.xPos-1, piece.yPos
						end

						if currentArrow ~= "none" and checkRange(xTo, yTo) and checkMove(xTo, yTo) and checkDoubleChain(xTo, yTo) then 

							--if not string.find(grid[xTo][yTo].type, "Arrow") and grid[xTo][yTo].hasPiece then
								print("hasPiece piece?....", grid[xTo][yTo].hasPiece, xTo, yTo )
							--else
								flashArrows(currentArrow)

								if isFirstTransition then
									isFirstTransition = false
									delay = thisTime
								else
									delay = 0
								end
								--local xTo, yTo = piece.xPos+1, piece.yPos
								transition.to(piece, { delay= delay*2, time = thisTime, x = grid[xTo][yTo].x, y = grid[xTo][yTo].y,transition= thisTransition, onComplete=function(o)
	        					--do something else
	        					local timerid = timer.performWithDelay(thisTime, function()
	  
		       						
									grid[piece.xPos][piece.yPos].hasPiece = false
									grid[piece.xPos][piece.yPos].type = currentArrow
									piece.xPos,piece.yPos  = xTo, yTo
									grid[xTo][yTo].type = piece.type
									grid[xTo][yTo].hasPiece = true
									piece.x, piece.y = grid[xTo][yTo].x, grid[xTo][yTo].y 						
	        						arrowFunction()
	        					end)
	        					end
	    						})		
    						--end					

						else


							hideTouch = false
							isFirstTransition = true

				if grid[piece.xPos][piece.yPos].type2 == "blueTp" and piece.type == "moveable" and checkRange(tp1.x, tp1.y) and checkMove(tp1.x, tp1.y) and checkDoubleChain(tp1.x, tp1.y) then
					print( "wow" )


					local tpAnimation = emit(piecesGroup, "firstBlurTp", grid[xTo][yTo].x, grid[xTo][yTo].y)
					grid[piece.xPos][piece.yPos].hasPiece = false
					grid[piece.xPos][piece.yPos].type = "empty"
					piece.xPos,piece.yPos  = xTo, yTo
					grid[xTo][yTo].hasPiece = true
					grid[xTo][yTo].type2 = "blueTp"
					grid[xTo][yTo].type = "blueTp"
					transition.to(piece, { time = thisTime, x = grid[xTo][yTo].x, y = grid[xTo][yTo].y,transition= thisTransition, onComplete=teleportObject(piece)})

				end

							print( "x and y: ", piece.xPos, piece.yPos, grid[piece.xPos][piece.yPos].finish )
							if piece.type == "moveable" then	
								if grid[piece.xPos][piece.yPos].finish then
									--print( "finish" )
									finishCount = finishCount + 1
								else
									finishCount = finishCount - 1
									--print( "not finish" )
								end

					        	checkFinish(piece.xPos,piece.yPos)
					        	print( "check finish" )
					    	end
						end



						
					end
					
					grid[piece.xPos][piece.yPos].hasPiece = false
					grid[piece.xPos][piece.yPos].type = "empty"
					piece.xPos,piece.yPos  = xTo, yTo
					grid[xTo][yTo].hasPiece = true
					

					if string.find(grid[xTo][yTo].type, "Arrow") then
					--grid[xTo][yTo].type = "rightArrow"
					else
					grid[xTo][yTo].type = "moveable"
						if piece.type == "push" then
						grid[xTo][yTo].type = "push"
						end
						if piece.type == "dumb" then
						grid[xTo][yTo].type = "dumb"
						end					
								
					end	
					transition.to(piece, { time = thisTime, x = grid[xTo][yTo].x, y = grid[xTo][yTo].y,transition= thisTransition, onComplete=arrowFunction()})
				
				end
			----------


			------------------
-- finish
		end

	end




				if moves == 1 and currentLevel == 1 then
					piecesGroup:insert(finger2)
				local function moveFinger()
					tutorialTitleText.text = "Swipe Right"
					
					local function listener(obj)
						if moves == 1 then
						finger2.y = grid[1][1].y
						finger2.alpha = 0.6
						transition.to( finger2, {x = grid[2][2].x, time = 800,  transition = easing.inOutQuad, onComplete=moveFinger()} )
						end
					end
					finger2.x, finger2.y = grid[1][2].x, grid[1][2].y
					finger2.alpha = 0.6
					transition.to( finger2, {y = grid[1][2].y, time = 800,  transition = easing.inOutQuad, onComplete=listener} )
					
				end
				moveFinger()
				elseif finger2 then
					finger2.alpha = 0
				end		
updateUiText()


--hideTouch = false
end


	local function spawnPiece(xPos, yPos, pieceType)
		if xPos < 1 or xPos > GRID_WIDTH or yPos < 1 or yPos > GRID_HEIGHT then
			print( "Position out of range:", xPos, yPos )
			return nil
		end

		local alpha = 1
		local object = "yellow_ball"
		local group = piecesMid
		if pieceType == "finish" then
			object = "finish"
			finishes = finishes + 1
			group = piecesTop
		elseif pieceType == "nomove" then
			object = "nomove"
			group = piecesMid
		elseif pieceType == "push" then
			object = "push"
			group = piecesMid
		elseif pieceType == "dumb" then
			object = "dumb"
			group = piecesMid	
		elseif pieceType == "blueTp" then
			object = "blueTp"
			group = piecesTop
		elseif pieceType == "whiteTp" then
			object = "whiteTp"
			group = piecesBottom	
		elseif pieceType == "upArrow" then
			object = "upArrow"
			group = piecesBottom	
			grid[xPos][yPos].isUpArrow = true
		elseif pieceType == "rightArrow" then
			object = "rightArrow"
			group = piecesBottom	
			grid[xPos][yPos].isRightArrow = true
		elseif pieceType == "downArrow" then
			object = "downArrow"
			group = piecesBottom	
			grid[xPos][yPos].isDownArrow = true
		elseif pieceType == "leftArrow" then
			object = "leftArrow"
			group = piecesBottom	
			grid[xPos][yPos].isLeftArrow = true				
		end

		local piece = display.newImageRect(group, "images/"..object ..".png", CELL_WIDTH*.6, CELL_HEIGHT*.6 )
		piece.x = grid[xPos][yPos].x
		piece.y =	grid[xPos][yPos].y
		piece.xPos, piece.yPos = xPos, yPos
		piece.type = pieceType
		piece.alpha = alpha
	-- O>M = object.movable
		grid[xPos][yPos].type = pieceType
		grid[xPos][yPos].type2 = pieceType


		local thisTransition =  easing.outBack
		local thisTime = 100

		if pieceType == "finish" then
			grid[xPos][yPos].finish = true
		elseif pieceType == "nomove" then
		elseif pieceType == "push" then
			grid[xPos][yPos].hasPiece = true		

		elseif pieceType == "dumb" then
			grid[xPos][yPos].hasPiece = true
			piece.width, piece.height = piece.width/1.2, piece.height/1.2
			--piece:setFillColor(lib.convertHexToRGB("#F5A623"))
		elseif pieceType == "moveable" then
			grid[xPos][yPos].hasPiece = true
			piece.width, piece.height = piece.width/5, piece.height/5
			transition.scaleTo( piece, { delay = spawndelay, xScale=5, yScale=5, time=500, transition=easing.outElastic  } )
			 
		end

		if pieceType == "blueTp" then
			
			local function rotateTp()
				transition.to(piece,{time=2000, rotation=piece.rotation+360, onComplete=rotateTp})
			end
			rotateTp() -- start moving sky
		end


		if pieceType == "whiteTp" then
			tp1.x, tp1.y = xPos, yPos
			local function rotateTp()
				
				transition.to(piece,{time=2000, rotation=piece.rotation-360, onComplete=rotateTp})
			end
			rotateTp() -- start moving sky
		end

		if string.find(pieceType, "Arrow") then
			piece.fill.effect = "filter.polkaDots"

			piece.fill.effect.numPixels = 2
			piece.fill.effect.dotRadius = 1
			piece.fill.effect.aspectRatio = ( piece.width*0.9) / (piece.height*0.9 )
			piece:setFillColor(lib.convertHexToRGB("#F5A623"))
			local function blink()
			    if piece.alpha and piece.alpha < 0.6 then
			        transition.to( piece, {time=math.random(30,500), alpha=0.6})
			    else 
			        transition.to( piece, {time=math.random(30,500), alpha=0.4})
			    end
			    
			end
			local arrowBlink = timer.performWithDelay(300+piece.xPos, blink, 0)

			piece.isOnArrow = false
			piece.arrowEnterFrame  = function ( self, event )
				-- body
				if grid[xPos][yPos].hasPiece and grid[xPos][yPos].type == "moveable" then
					piece.isOnArrow = true
				else
					piece.isOnArrow = false	
				end

				
			end
			Runtime:addEventListener("enterFrame", piece.arrowEnterFrame)
		end


		return piece
	end	

		for i = 1, #thisLevel do
			--print( thisLevel[i]["type"] )

			if thisLevel[i].type == "config" then

			else


			--print( "Finishes: " .. finishes )
			local piece = spawnPiece(thisLevel[i]["x"], thisLevel[i]["y"], thisLevel[i]["type"])
			table.insert(pieces, piece)
			end
		end


	if currentLevel == 1 then 
		 tutorialTitleText = display.newText( uiGroup, "Swipe Down", screen.centerX, screen.centerY-180, settings.defaultFontOblique, 20 )


		local timerid = timer.performWithDelay(1000, function()
			local finger = display.newImageRect( piecesGroup, "images/finger.png", 50, 78 )
				finger.anchorY = 0
				finger.alpha = 0.6
				finger.x, finger.y = grid[1][1].x, grid[1][1].y 
				local function moveFinger()
					
					local function listener(obj)
						if moves == 0 then
						finger.y = grid[1][1].y
						finger.alpha = 0.6
						transition.to( finger, {y = grid[1][2].y, time = 1000, transition = easing.inOutQuad,  onComplete=moveFinger()} )
						elseif moves == 1 then
							finger:removeSelf( )
						end
					end
					transition.to( finger, {y = grid[1][2].y, time = 1000, transition = easing.inOutQuad,  onComplete=listener} )
					
				end

				moveFinger()
			end)

	end


		local gotDirection = false
		touchBox.touch = function( self, event )

			if event.phase == "began" then

				print( "touch" )
			--print( directionToMove )

			elseif event.phase == "moved" then

			
		 		local dX = event.x - event.xStart
		 		local dY = event.y - event.yStart

		 		if gotDirection == false then
		        if ( dX > 10 ) then
		        	gotDirection = true
		            --swipe right
		            	movePiece("right")
		            --print( "right" )
		        elseif ( dX < -10 ) then
		        	gotDirection = true
		            --swipe left
		            	movePiece("left")
		            --print( "left" )
		        elseif ( dY < -10 ) then
		        	gotDirection = true
		            --swipe up
		            	movePiece("up")
		            --print( "up" )
		        elseif ( dY > 10 ) then
		        	gotDirection = true
		            --swipe down
		            directionToMove = "down"

		            	movePiece("down")
		            --print( "Down" )   
		            
		        end
		    end
		    
			elseif event.phase == "ended" then
				gotDirection = false
				--directionToMove = "none"
				--print( directionToMove )
			end
		end



end


-- "scene:show()"
function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Called when the scene is still off screen (but is about to come on screen)
	composer.removeScene( scenes.reload )
		composer.removeScene( scenes.menu )
    elseif ( phase == "did" ) then
        -- Called when the scene is now on screen
        -- Insert code here to make the scene come alive
        -- Example: start timers, begin animation, play audio, etc.

        local timerid = timer.performWithDelay(spawndelay, function()
        	hideTouch = false
        	touchBox:addEventListener("touch", touchBox )
        end)
        		


    end

    local function enterFrame(  )
		if hideTouch then
    		touchBox.alpha = 0
    	else
    		touchBox.alpha = 0.01
    	end    		
    end
    Runtime:addEventListener("enterFrame", enterFrame )

end


-- "scene:hide()"
function scene:hide( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Called when the scene is on screen (but is about to go off screen)
        -- Insert code here to "pause" the scene
        -- Example: stop timers, stop animation, stop audio, etc.
    elseif ( phase == "did" ) then
        -- Called immediately after scene goes off screen

    end
end


-- "scene:destroy()"
function scene:destroy( event )

    local sceneGroup = self.view

    -- Called prior to the removal of scene's view
    -- Insert code here to clean up the scene
    -- Example: remove display objects, save state, etc.]
    --touchBox:removeEventListener("touch", onTouch )
    --Runtime:removeEventListener("enterFrame", movesDisplay )
    --Runtime:removeEventListener("enterFrame", levelDisplay )
    Runtime:removeEventListener("enterFrame", blinkenLighten)
end


-- -------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-- -------------------------------------------------------------------------------

return scene
