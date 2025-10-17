-- define a local table to store all references to functions/variables
local lib 				= require("libs.app5iveLib")

local popMenu = {}
local menuGroup = display.newGroup( )
local iconGroup = display.newGroup( )
local menuOpened = false
-- functions are now local:
local menuBg
menuGroup.alpha = 0
local dim = display.newRect( menuGroup, display.contentCenterX, display.contentCenterY, display.actualContentWidth, display.actualContentHeight )
dim:setFillColor(lib.convertHexToRGB("#1e1e1e"))
dim.alpha = 0.5
local openMenu = function ( )
	menuGroup.alpha = 1

	transition.to( menuBg, {time=400, width = display.actualContentWidth-10, height = 300, transition = easing.outCubic} )
end

local closeMenu = function ( )
	transition.to( menuBg, {time=100, width = 1, height = 1, onComplete = function( )
		-- body
		menuGroup.alpha = 0
	end} )
	
end

local menuToggle = function()
	iconGroup.alpha = 1
	if menuOpened then
		menuOpened = false 
		closeMenu()
	else
		menuOpened = true 
	    print( "Menu Toggle" )
	    openMenu()
	end
end

local makeIcon = function(x,y)
    local rect = display.newRect( iconGroup, display.contentCenterX, display.contentCenterY, 30, 5 )
    local rect = display.newRect( iconGroup, display.contentCenterX, rect.y+rect.height+5, 30, 5 )
    local rect = display.newRect( iconGroup, display.contentCenterX, rect.y+rect.height+5, 30, 5 )
    iconGroup.x, iconGroup.y = x,y
    iconGroup.anchorX, iconGroup.anchorY = 1,0
    iconGroup.anchorChildren = true
    local function touchedMenu( event )
    	if event.phase == "began" then
    	iconGroup.alpha = 0.5
    	elseif event.phase == "ended" then
    		menuToggle()
    		return true 
    	end
    	
    end
    iconGroup:addEventListener("touch", touchedMenu )

	menuBg = display.newRect( 0, 0, 150, 50 )
	menuBg:setFillColor(lib.convertHexToRGB("#F5A623"))
	menuBg.anchorX, menuBg.anchorY = 1,0
	menuBg.x, menuBg.y = iconGroup.x+5, iconGroup.y-5
	menuGroup:insert(menuBg)

end
-- assign a reference to the above local function
popMenu.makeIcon = makeIcon

local addMenu = function(x,y)
    makeIcon(x,y)
end
popMenu.addMenu = addMenu

-- Finally, return the table to be used locally elsewhere
return popMenu