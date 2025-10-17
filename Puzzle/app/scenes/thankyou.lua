local composer = require("composer")
local scenes = require("app.scene_names")
local screen = require("libs.screen")
local settings = require("settings")

local scene = composer.newScene()

local state = {
    timerHandle = nil,
}

local function returnToMenu()
    composer.gotoScene(scenes.menu, { effect = "fade", time = 400 })
end

local function onSceneCreate()
    local sceneGroup = scene.view
    require("app.backgrounds.deep_dark").addBg(sceneGroup)

    local title = display.newText({
        parent = sceneGroup,
        text = "Thanks for Playing!",
        x = screen.centerX,
        y = screen.centerY - 40,
        font = settings.defaultFont,
        fontSize = 36,
    })
    title:setFillColor(1, 1, 1)

    local body = display.newText({
        parent = sceneGroup,
        text = [[You completed all available levels.
More puzzles are on the way.]],
        x = screen.centerX,
        y = title.y + 60,
        align = "center",
        width = screen.width * 0.7,
        font = settings.defaultFontOblique,
        fontSize = 20,
    })
    body:setFillColor(0.85, 0.85, 0.85)

    state.timerHandle = timer.performWithDelay(2000, returnToMenu)
end

local function onSceneShow(_, event)
    if event.phase == "will" then
        composer.removeScene(scenes.reload)
    end
end

local function onSceneHide(_, event)
    if event.phase == "will" and state.timerHandle then
        timer.cancel(state.timerHandle)
        state.timerHandle = nil
    end
end

local function onSceneDestroy()
    if state.timerHandle then
        timer.cancel(state.timerHandle)
        state.timerHandle = nil
    end
end

scene:addEventListener("create", onSceneCreate)
scene:addEventListener("show", onSceneShow)
scene:addEventListener("hide", onSceneHide)
scene:addEventListener("destroy", onSceneDestroy)

return scene
