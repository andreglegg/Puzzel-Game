local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------------------------------------
-- All code outside of the listener functions will only be executed ONCE unless "composer.removeScene()" is called
-- -----------------------------------------------------------------------------------------------------------------

local lib 				= require("libs.app5iveLib")
local screen 			= require( "libs.screen")
local lfs = require( "lfs" )
display.setDefault( "background", lib.convertHexToRGB("#ECECEC") )
-- Local forward references should go here
local GRID_WIDTH = 2
local GRID_HEIGHT = 2
local CELL_WIDTH = 80
local CELL_HEIGHT = 80
local CELL_SPACING = 2
local Y_OFFSET = 0

local MK_GRID_WIDTH, MK_GRID_HEIGHT
local backgroundGroup = display.newGroup( )
local gridGroup = display.newGroup( )
local objectsGroup = display.newGroup( )
local uiGroup = display.newGroup( )
local gridHolder = display.newGroup()
local piecesGroup = display.newGroup()
local bounds
local margin = 10
local levels = {}
local grid = {}
local pieces = {}
local finishes = 0
local floating
--system.activate("mouse")
local currentLevel = {}
local levelNumber = 0

local widthField 
local heightField

-- Functions

local lfs = require( "lfs" )
local spawnPiece

-- "scene:create()"
function scene:create( event )

    local sceneGroup = self.view
    sceneGroup:insert(backgroundGroup)
    sceneGroup:insert(gridGroup)
    sceneGroup:insert(objectsGroup)
    sceneGroup:insert(uiGroup)

--    local cursor = display.newImage( uiGroup, "images/cursor.png",  1,1)

function print_r ( t )  
    local print_r_cache={}
    local function sub_print_r(t,indent)
        if (print_r_cache[tostring(t)]) then
            print(indent.."*"..tostring(t))
        else
            print_r_cache[tostring(t)]=true
            if (type(t)=="table") then
                for pos,val in pairs(t) do
                    local posStr = tostring(pos)
                    if (type(val)=="table") then
                        print(indent.."["..posStr.."] => "..tostring(t).." {")
                        sub_print_r(val,indent..string.rep(" ",#posStr+8))
                        print(indent..string.rep(" ",#posStr+6).."}")
                    elseif (type(val)=="string") then
                        print(indent.."["..posStr..'] => "'..val..'"')
                    else
                        print(indent.."["..posStr.."] => "..tostring(val))
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

local level = { 
   {type="config", gw=2, gh=2, cw=80, ch=80, target=2},
   {type="finish", x=2, y=2 },
   {type="moveable", x=1, y=1 },
}

local function generateLevelFile(  )
	-- Data (string) to write
	print( "saving data" )
	--print_r(currentLevel)
	local gw, gh

			gw = widthField.text
			gh = heightField.text

			print( gw, gh )

			print( "target: "..targetField.text )
	local dataStart = "local level = { \n   {type=\"config\", gw="..gw..", gh="..gh..", cw=80, ch=80, target=".. targetField.text .."},\n"
	local s = ""
	for i=1,piecesGroup.numChildren do
		print( piecesGroup[i].yPos )
		local piece = piecesGroup[i]
		--if piece.type ~= "config" then
			print( piece.type )
			s = s .. "   {type=\"" .. piece.type .. "\", x="..piece["xPos"]..", y="..piece["yPos"].." },\n"
		--end
		
	end

	local dataEnd = "}\nreturn level"

	local saveData = dataStart .. s .. dataEnd
	
	-- Path for the file to write
	local path = system.pathForFile( "level".. levelNumber ..".lua", system.DocumentsDirectory )

	-- Open the file handle
	local file, errorString = io.open( path, "w+" )

	if not file then
    -- Error occurred; output the cause
    print( "File error: " .. errorString )
	else
    -- Write data to file
    file:write( saveData )
    -- Close the file handle
    io.close( file )
end

file = nil
end

    local blueBg = display.newRect( backgroundGroup, screen.centerX, screen.centerY, 700, 650 )
    blueBg:setFillColor( lib.convertHexToRGB("#0A579B") )



    local function makeGrid(width, height)

		finishes = 0

		--
		-- Create a 2D array to hold our objects.
		pieces = {}
		GRID_WIDTH, GRID_HEIGHT = width, height
		removeAllFromGroup(gridHolder)
		removeAllFromGroup(piecesGroup)
		
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

		    	grid[x][y] = display.newImageRect(gridHolder, "images/grid/grey/".. bgPiece ..".png", CELL_WIDTH, CELL_HEIGHT )
		    	grid[x][y].x, grid[x][y].y = xPos, yPos
		        grid[x][y].hasPiece = false
		        grid[x][y].type = "empty"
		        gridHolder:insert(grid[x][y])
		        grid[x][y].status = display.newText(gridHolder, tostring(grid[x][y].type), xPos, yPos, native.systemFont, 10 )
		        grid[x][y].status.alpha = 0
				local function onObjectTouch( event )
				    if ( event.phase == "began" ) then
				        --print( "Touch event began on: " .. x, y )
				        --spawnPiece(x,y)
				        if floating and floating.type == "delete" then
				        	print( "remove piece" )
				        	removePiece(x,y)
				        elseif floating then
				        	print( "spawnPiece:",x,y )
				        	spawnPiece(x, y, floating.type)
				        	
				        end
				    elseif ( event.phase == "ended" ) then
				        --print( "Touch event ended on: " .. x,y )
				        --print_r(  pieces )
				    end
				    return true
				end
				grid[x][y]:addEventListener( "touch", onObjectTouch )
		    end
		end



		gridHolder.anchorX = 0.5
		gridHolder.anchorY = 0.5
		gridHolder.anchorChildren = true

		gridHolder.x = blueBg.x 
		gridHolder.y = blueBg.y --screen.bottom - Y_OFFSET

		gridHolder:insert(piecesGroup)
		gridGroup:insert( gridHolder )
	    bounds = gridGroup.contentBounds 	
    end
   






	local function handlerFunction( event )


	    if ( event.phase == "began" ) then
	        -- user begins editing defaultField
	        --print( event.text )

	    elseif ( event.phase == "ended" or event.phase == "submitted" ) then
	        -- do something with defaultField text
	        --print( event.target.text, "ended" )
	        if event.target.type == "widthField" then
	        	MK_GRID_WIDTH = tonumber(event.target.text)
	        elseif event.target.type == "heightField" then
	        	MK_GRID_HEIGHT = tonumber(event.target.text)
	        end	        

	    elseif ( event.phase == "editing" ) then
	        --print( event.text )
	        if event.target.type == "widthField" then
	        	MK_GRID_WIDTH = event.target.text
	        elseif event.target.type == "heightField" then
	        	MK_GRID_HEIGHT = event.target.text
	        end	 

	    end  
	end

	local builMapGroup = display.newGroup( )

	widthField = native.newTextField( blueBg.x, blueBg.y-blueBg.height/2-30, 60, 36 )
	widthField.anchorX = 0
	widthField.inputType = "number"
	widthField.type = "widthField"
	widthField.text = 2

	widthField:addEventListener( "userInput", handlerFunction )

	heightField = native.newTextField(  widthField.x+widthField.width+margin, widthField.y, 60, 36 )
	heightField.anchorX = 0
	heightField.inputType = "number"
	heightField.type = "heightField"
	heightField.text = 2

	heightField:addEventListener( "userInput", handlerFunction )
	MK_GRID_WIDTH, MK_GRID_HEIGHT = tonumber(widthField.text), tonumber(heightField.text)
	builMapGroup:insert(widthField); builMapGroup:insert(heightField)

	local buildMapButton = display.newText( builMapGroup, "Build/Rebuild", heightField.x+heightField.width+margin, heightField.y, native.systemFontBold, 20 )
	buildMapButton.anchorX = 0
	buildMapButton:setFillColor( lib.convertHexToRGB("#1e1e1e") )
	buildMapButton.touch = function( self, event )
		if event.phase == "began" then
				currentLevel = {}
				makeGrid(MK_GRID_WIDTH, MK_GRID_HEIGHT)			
				elseif event.phase == "ended" then
			end
		end

	buildMapButton:addEventListener( "touch", buildMapButton )	

	builMapGroup.anchorChildren = true
	builMapGroup.anchorY = 1

	builMapGroup.x, builMapGroup.y = screen.centerX, blueBg.y-blueBg.height/2-margin



	local targetText = display.newText( builMapGroup, "Target: ", buildMapButton.x+buildMapButton.width+margin*10, buildMapButton.y, native.systemFontBold, 20 )
	targetText.anchorX = 0
	targetText:setFillColor( lib.convertHexToRGB("#1e1e1e") )

	targetField = native.newTextField(  targetText.x-100, targetText.y, 60, 36 )
	targetField.anchorX = 0
	targetField.inputType = "number"
	targetField.type = "heightField"
	targetField.text = 0

	targetField:addEventListener( "userInput", handlerFunction )





	local xHighlight = display.newRect( uiGroup, screen.centerX, screen.centerY, blueBg.width, CELL_HEIGHT )
	local yHighlight = display.newRect( uiGroup, screen.centerX, screen.centerY, CELL_WIDTH, blueBg.height )

	xHighlight.alpha = 0.3
	yHighlight.alpha = 0.3

	local levelsDisplayText = display.newText( builMapGroup, "Levels", 10, 60, native.systemFontBold, 28 )
	levelsDisplayText.anchorX, levelsDisplayText.anchorY = 0, 1
	levelsDisplayText:setFillColor( lib.convertHexToRGB("#0A579B") )
	uiGroup:insert(levelsDisplayText)

	local levelNumberField = native.newTextField( levelsDisplayText.x + levelsDisplayText.width+margin , levelsDisplayText.y, 60, 36 )
	levelNumberField.anchorX, levelNumberField.anchorY = 0, 1
	levelNumberField.inputType = "number"
	levelNumberField.type = "levelNumberField"
	levelNumberField.text = levelNumber

	widthField:addEventListener( "userInput", handlerFunction )	
	
	local addLevelButton = display.newText( uiGroup, "+", levelNumberField.x + levelNumberField.width+margin*2 , levelNumberField.y, native.systemFontBold, 30 )
	addLevelButton:setFillColor( lib.convertHexToRGB("#1e1e1e") )
	addLevelButton.anchorX, addLevelButton.anchorY = 0, 1
	addLevelButton.touch = function( self, event )
		if event.phase == "began" then
				--generateLevelFile()
				print( "add level" )
				levelNumber = levelNumber + 1	
				levelNumberField.text = levelNumber
				elseif event.phase == "ended" then
			end
		end

	addLevelButton:addEventListener( "touch", addLevelButton )	


	local saveText = display.newText( uiGroup, "save", addLevelButton.x + addLevelButton.width+margin*2 , addLevelButton.y, native.systemFontBold, 30 )
	saveText:setFillColor( lib.convertHexToRGB("#1e1e1e") )
	saveText.anchorX, saveText.anchorY = 0, 1
	saveText.touch = function( self, event )
		if event.phase == "began" then
				generateLevelFile()		
				elseif event.phase == "ended" then
			end
		end

	saveText:addEventListener( "touch", saveText )		
	 

 


	local function onMouseMove( event )
		-- body
		--if event.phase == "began" then
			--print( event.x )


		if floating ~= nil then
			floating.x, floating.y = event.x, event.y
		end

    if event.isPrimaryButtonDown then
        -- The mouse's primary/left button is currently pressed down.
        --print( "mouse left click" )
    else
        -- The mouse's primary/left button is not being pressed.
    end
		if(event.x < bounds.xMin) or
        (event.x > bounds.xMax) or
        (event.y < bounds.yMin) or
        (event.y > bounds.yMax) then
        
        	xHighlight.alpha, yHighlight.alpha = 0.01, 0.01

        else 

        	xHighlight.alpha, yHighlight.alpha = 0.05, 0.05
        	xHighlight.y, yHighlight.x = event.y, event.x
        end	
		--end
		if event.phase == "ended" then
			print( "event ended" )
		end


	end

	Runtime:addEventListener("mouse", onMouseMove)

	 function spawnPiece(xPos, yPos, pieceType)
		--pieces = {}
		if xPos < 1 or xPos > GRID_WIDTH or yPos < 1 or yPos > GRID_HEIGHT then
			print( "Position out of range:", xPos, yPos )
			return nil
		end


		local object = "yellow_ball"

		if pieceType == "finish" then
			object = "finish"
			finishes = finishes + 1
		elseif pieceType == "nomove" then
			object = "nomove"
		elseif pieceType == "push" then
			object = "push"
		elseif pieceType == "dumb" then
			object = "dumb"	
		elseif pieceType == "blueTp" then
			object = "blueTp"
		elseif pieceType == "whiteTp" then
			object = "whiteTp"	
		elseif pieceType == "upArrow" then
			object = "upArrow"
		elseif pieceType == "rightArrow" then
			object = "rightArrow"
		elseif pieceType == "downArrow" then
			object = "downArrow"
		elseif pieceType == "leftArrow" then
			object = "leftArrow"				
		end

		local piece = display.newImageRect( piecesGroup, "images/"..object ..".png", CELL_WIDTH*.6, CELL_HEIGHT*.6 )
		piece.x = grid[xPos][yPos].x
		piece.y =	grid[xPos][yPos].y
		piece.xPos, piece.yPos = xPos, yPos
		piece.type = pieceType
	-- O>M = object.movable
		grid[xPos][yPos].type = pieceType
		local data = {type=pieceType, x=xPos, y=yPos}
		table.insert( currentLevel, data )
		grid[xPos][yPos].hasPiece = true

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
		elseif pieceType == "moveable" then
			grid[xPos][yPos].hasPiece = true
			piece.width, piece.height = piece.width, piece.height
			
		end
		--return piece
	end	

function removePiece(xPos, yPos)

	if grid[xPos][yPos] then
		local removedType = grid[xPos][yPos].type
		for j = piecesGroup.numChildren, 1, -1 do
			local piece = piecesGroup[j]
			if piece and piece.xPos and piece.yPos and xPos == piece.xPos and yPos == piece.yPos then
				piece:removeSelf()
			end
		end

		if removedType == "finish" and finishes > 0 then
			finishes = finishes - 1
		end

		grid[xPos][yPos].hasPiece = false
		grid[xPos][yPos].finish = nil
		grid[xPos][yPos].type = "empty"
		grid[xPos][yPos].type2 = nil

		if currentLevel then
			for i = #currentLevel, 1, -1 do
				local entry = currentLevel[i]
				if type(entry) == "table" and entry.x == xPos and entry.y == yPos and entry.type ~= "config" then
					table.remove(currentLevel, i)
				end
			end
		end
	end	

end

function removeAllFromGroup( group )
				--print( "removing all ", group.numChildren )
	while group.numChildren > 0 do
		local child = group[1]
        if child then child:removeSelf() end
        	--print("group.numChildren" , group.numChildren )
		end	


end

 function loadLevel( thisLevel )
 		print( "load Level", thisLevel )
 		local thisLevel = thisLevel
		for i = 1, #thisLevel do
			

			if thisLevel[i].type == "config" then
				MK_GRID_WIDTH, MK_GRID_HEIGHT = thisLevel[i].gw, thisLevel[i].gh
				widthField.text, heightField.text, targetField.text = MK_GRID_WIDTH, MK_GRID_HEIGHT, thisLevel[i].target
			else
				--event.localPlayerScore
				 spawnPiece(thisLevel[i]["x"], thisLevel[i]["y"], thisLevel[i]["type"])
				--table.insert(pieces, piece)
			end
		end	
		currentLevel = {}
		currentLevel = nil
		currentLevel = {thisLevel}

		print_r(currentLevel)


		gridHolder.anchorX = 0.5
		gridHolder.anchorY = 0.5
		gridHolder.anchorChildren = true

		gridHolder.x = blueBg.x 
		gridHolder.y = blueBg.y --screen.bottom - Y_OFFSET

end


	local widget = require( "widget" )

	-- ScrollView listener
	local function scrollListener( event )

	    local phase = event.phase
	    if ( phase == "began" ) then --print( "Scroll view was touched" )
	    elseif ( phase == "moved" ) then --print( "Scroll view was moved" )
	    elseif ( phase == "ended" ) then --print( "Scroll view was released" )
	    end

	    -- In the event a scroll limit is reached...
	    if ( event.limitReached ) then
	        if ( event.direction == "up" ) then --print( "Reached bottom limit" )
	        elseif ( event.direction == "down" ) then --print( "Reached top limit" )
	        elseif ( event.direction == "left" ) then --print( "Reached right limit" )
	        elseif ( event.direction == "right" ) then --print( "Reached left limit" )
	        end
	    end

	    return true
	end

	-- Create the widget
	local scrollView = widget.newScrollView(
	    {
	        top = 75,
	        left = 0,
	        width = 300,
	        height = 400,
	        scrollWidth = 600,
	        scrollHeight = 800,
	        listener = scrollListener
	    }
	)

	
	--scrollView:insert( test )
	-- Create a image and insert it into the scroll view
	-- background = display.newImageRect( "assets/scrollimage.png", 768, 1024 )
	--scrollView:insert( background )
	local doc_path = system.pathForFile( "levels")
	
	local scrollMargin = margin

	local bgdark = false

	for file in lfs.dir( doc_path ) do
	    -- File is the current file or directory name
	    if string.match(file, "level") then
		    print( "Found file: " .. file )
		    table.insert( levels, file )
		    local levelHolder = display.newGroup( )
		    local levelBG = display.newRect( levelHolder, 3, 20+scrollMargin, 200, 36 )
		    levelBG.file = file
		    levelBG.anchorX, levelBG.anchorY = 0, 1
		    levelBG:setFillColor( lib.convertHexToRGB("#0A579B") )
		    local fileText = file:gsub("%.lua", "")
		    local level = display.newText( levelHolder, fileText, levelBG.x+margin, levelBG.y-5, native.systemFontBold, 20 )
		    level.anchorX, level.anchorY = 0, 1
		    if not bgdark then
		    	levelBG.alpha = 0.01
		    	bgdark = true
		    	levelBG.type = tostring( bgdark )
		    else
		    	levelBG.alpha = 0.1
		    	bgdark = false
		    end
			local function onObjectTouch( self, event )
			    --if ( event.phase == "began" ) then
		    		local levelFile = event.target.file
		    		levelFile = levelFile:gsub("%.lua", "")
		    			print( #currentLevel )
					  for i=1, #currentLevel do
					    --currentLevel[i]:removeSelf()
					    -- Can also use: objectsOnScreen[i].isVisible = false
					    --currentLevel[i] = nil
					    print( "nill out" )
					  end
					  --currentLevel = {}
					--currentLevel = nil		    		
		    		local thisLevel = require( "levels.".. levelFile)
		    		print( "thisLevel: ", #thisLevel )
		    		print_r(thisLevel)	
		    		levelNumberField.text = levelFile:gsub("%level", "")
		    		levelNumber = tonumber( levelNumberField.text )
		    		--currentLevel = {}
		    		if thisLevel[1] then
		    		
		    		--currentLevel = nil
		    		
		    		print_r(thisLevel)
		    		makeGrid(thisLevel[1].gw, thisLevel[1].gh)	

		    		loadLevel(thisLevel)

		    		end			        
			    --end
			    --return true
			end 

			levelBG.touch = onObjectTouch
			levelBG:addEventListener( "touch", levelBG )		    
		    

		    level:setFillColor(lib.convertHexToRGB("#1e1e1e"))
		    levelHolder.anchorX, levelHolder.anchorY = 0, 1
		    levelHolder.filename = file
		    scrollView:insert( levelHolder )
		    builMapGroup:insert(scrollView)
		    scrollMargin = levelHolder.height + scrollMargin
		end
	end

	uiGroup:insert(scrollView)

	makeGrid(MK_GRID_WIDTH, MK_GRID_HEIGHT)

local function addPiceToMouse(type, image)
	if floating then floating:removeSelf( ) end
	floating = display.newImageRect( uiGroup, "images/"..image, 40, 40 )
	floating.x, floating.y = 1,1
	floating.type = type
end	

-------- 	RIGHT SIDE
	local rightSide = display.newRect( uiGroup, blueBg.x+blueBg.width/2, blueBg.y-blueBg.height/2 , 200, blueBg.height )
	rightSide.anchorX, rightSide.anchorY = 0, 0
	rightSide:setFillColor( lib.convertHexToRGB("#1e1e1e") )
	local piecesLocal = {
							{ type="finish", image="finish.png" },
							{ type="moveable", image="yellow_ball.png" },
							{ type="nomove", image="nomove.png" },
							{ type="push", image="push.png" },
							{ type="dumb", image="dumb.png" },
							{ type="blueTp", image="blueTp.png" },
							{ type="whiteTp", image="whiteTp.png" },
							{ type="delete", image="delete.png" },
							{ type="upArrow", image="upArrow.png" },
							{ type="rightArrow", image="rightArrow.png" },
							{ type="downArrow", image="downArrow.png" },
							{ type="leftArrow", image="leftArrow.png" },
						}

local yLocation = 30
	for i = 1, #piecesLocal do
		local piece = piecesLocal[i]
		local icon = display.newImageRect( "images/".. piece.image, 40, 40 )
		icon.type = piece.type
		icon.image = piece.image
		icon.x, icon.y = rightSide.x+rightSide.width/2, rightSide.y+margin + yLocation
		yLocation = yLocation + 60
		icon.touch = function(self, event)
			if event.phase == "began" then
				print( "touch", self.type )
				addPiceToMouse(self.type, self.image)
			end
		end
		icon:addEventListener( "touch", icon )
	end

	local function enterFrame( )
	end

	Runtime:addEventListener("enterFrame", enterFrame )
	-- Called when a key event has been received
	local function onKeyEvent( event )
	    -- Print which key was pressed down/up
	    local message = "Key '" .. event.keyName .. "' was pressed " .. event.phase
	    print( message )

	    -- If the "back" key was pressed on Android or Windows Phone, prevent it from backing out of the app
	    if ( event.keyName == "back" ) then
	        local platformName = system.getInfo( "platformName" )
	        if ( platformName == "Android" ) or ( platformName == "WinPhone" ) then
	            return true
	        end
	    end

	    -- IMPORTANT! Return false to indicate that this app is NOT overriding the received key
	    -- This lets the operating system execute its default handling of the key
	    return false
	end

	-- Add the key event listener
	Runtime:addEventListener( "key", onKeyEvent )

end


-- "scene:show()"
function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Called when the scene is still off screen (but is about to come on screen)
    elseif ( phase == "did" ) then
       
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
end


-- -------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-- -------------------------------------------------------------------------------

return scene
