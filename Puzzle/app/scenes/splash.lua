display.setStatusBar(display.HiddenStatusBar)

local composer = require("composer")
local scenes = require("app.scene_names")
local screen = require("libs.screen")
local settings = require("settings")

local scene = composer.newScene()

local state = {
    transitionTimer = nil,
}

local function goToMenu()
    composer.gotoScene(scenes.menu, { effect = "fade", time = 500 })
end

local function onSceneCreate(event)
    local sceneGroup = event and event.target or scene.view
    require("app.backgrounds.deep_dark").addBg(sceneGroup)

    local title = display.newText({
        parent = sceneGroup,
        text = "PUZZLE",
        x = screen.centerX,
        y = screen.centerY - 60,
        font = settings.defaultFont,
        fontSize = 60,
    })
    title:setFillColor(1, 1, 1)

    local subtitle = display.newText({
        parent = sceneGroup,
        text = "A game by Andre Glegg",
        x = screen.centerX,
        y = title.y + 60,
        font = settings.defaultFontOblique,
        fontSize = 20,
    })
    subtitle:setFillColor(0.85, 0.85, 0.85)

    local info = display.newText({
        parent = sceneGroup,
        text = "Swipe to move. Reach the goal with as few moves as possible.",
        x = screen.centerX,
        y = subtitle.y + 80,
        width = screen.width * 0.8,
        align = "center",
        font = settings.defaultFontOblique,
        fontSize = 18,
    })
    info:setFillColor(0.8, 0.8, 0.8)

    state.transitionTimer = timer.performWithDelay(1200, goToMenu)
end

scene:addEventListener("create", onSceneCreate)

local function onSceneHide(_, event)
    if event and event.phase == "will" and state.transitionTimer then
        timer.cancel(state.transitionTimer)
        state.transitionTimer = nil
    end
end

local function onSceneDestroy()
    if state.transitionTimer then
        timer.cancel(state.transitionTimer)
        state.transitionTimer = nil
    end
end

scene:addEventListener("hide", onSceneHide)
scene:addEventListener("destroy", onSceneDestroy)

return scene
