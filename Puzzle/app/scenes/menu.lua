display.setStatusBar(display.HiddenStatusBar)

local composer = require("composer")
local scenes = require("app.scene_names")
local screen = require("libs.screen")
local settings = require("settings")

local scene = composer.newScene()

local state = {
    startTimer = nil,
}

local function clearStartTimer()
    if state.startTimer then
        timer.cancel(state.startTimer)
        state.startTimer = nil
    end
end

local function createStartButton(group)
    local button = display.newRoundedRect(group, screen.centerX, screen.centerY + 60, 220, 64, 18)
    button:setFillColor(0.12, 0.12, 0.12)
    button.strokeWidth = 3
    button:setStrokeColor(0.96, 0.65, 0.14)

    local label = display.newText({
        parent = group,
        text = "PLAY",
        x = button.x,
        y = button.y,
        font = settings.defaultFontOblique,
        fontSize = 32,
    })

    label:setFillColor(1, 1, 1)

    button:addEventListener("touch", function(event)
        if event.phase == "began" then
            button.alpha = 0.7
            label.alpha = 0.7
            clearStartTimer()
            state.startTimer = timer.performWithDelay(250, function()
                composer.gotoScene(scenes.game, {
                    effect = "slideLeft",
                    time = 250,
                    params = { currentLevel = 1 },
                })
            end)
        elseif event.phase == "ended" or event.phase == "cancelled" then
            button.alpha = 1
            label.alpha = 1
        end
        return true
    end)
end

local function createUi(sceneGroup)
    local uiGroup = display.newGroup()
    sceneGroup:insert(uiGroup)

    local title = display.newText({
        parent = uiGroup,
        text = "PUZZLE",
        x = screen.centerX,
        y = screen.centerY - 80,
        font = settings.defaultFont,
        fontSize = 56,
    })
    title:setFillColor(1, 1, 1)

    local subtitle = display.newText({
        parent = uiGroup,
        text = "Swipe to guide the token to its goal",
        x = screen.centerX,
        y = title.y + 40,
        width = screen.width * 0.8,
        font = settings.defaultFontOblique,
        fontSize = 20,
        align = "center",
    })
    subtitle:setFillColor(0.9, 0.9, 0.9)

    createStartButton(uiGroup)
end

local function onSceneCreate()
    local sceneGroup = scene.view
    require("app.backgrounds.deep_dark").addBg(sceneGroup)
    createUi(sceneGroup)
end

scene:addEventListener("create", onSceneCreate)

local function onSceneShow(_, event)
    if event and event.phase == "will" then
        composer.removeScene(scenes.reload)
        composer.removeScene(scenes.thankyou)
    end
end

local function onSceneHide(_, event)
    if event and event.phase == "will" then
        clearStartTimer()
    end
end

local function onSceneDestroy()
    clearStartTimer()
end

scene:addEventListener("show", onSceneShow)
scene:addEventListener("hide", onSceneHide)
scene:addEventListener("destroy", onSceneDestroy)

return scene
