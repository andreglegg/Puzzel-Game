local composer = require("composer")
local scenes = require("app.scene_names")
local screen = require("libs.screen")
local settings = require("settings")
local lib = require("libs.app5iveLib")

local scene = composer.newScene()

local state = {
    stars = 1,
    timers = {},
}

local TOTAL_LEVELS = _G.totalLevels or 0

local function cancelTimers()
    for index = #state.timers, 1, -1 do
        timer.cancel(state.timers[index])
        state.timers[index] = nil
    end
end


local function computeStars(moves, target)
    if target <= 0 then
        return 1
    end
    if moves <= target then
        return 3
    elseif moves <= target + 3 then
        return 2
    end
    return 1
end

local function buildSummary(group, params)
    local background = display.newRoundedRect(group, screen.centerX, screen.centerY, screen.width * 0.8, 300, 16)
    background:setFillColor(0, 0, 0, 0.65)

    local title = display.newText({
        parent = group,
        text = string.format("Level %d", params.currentLevel),
        x = background.x,
        y = background.y - 110,
        font = settings.defaultFontOblique,
        fontSize = 34,
    })
    title:setFillColor(1, 1, 1)

    local starsGroup = display.newGroup()
    group:insert(starsGroup)
    local starSpacing = 80
    for index = 1, 3 do
        local star = display.newImageRect(starsGroup, "images/star.png", 54, 54)
        star.x = background.x + (index - 2) * starSpacing
        star.y = background.y - 20
        if index > state.stars then
            star:setFillColor(0.3, 0.3, 0.3)
        else
            star:setFillColor(1, 0.84, 0.2)
        end
    end

    local movesLabel = display.newText({
        parent = group,
        text = string.format("Moves: %d", params.moves or 0),
        x = background.x,
        y = background.y + 40,
        font = settings.defaultFont,
        fontSize = 22,
    })
    movesLabel:setFillColor(1, 1, 1)

    local targetLabel = display.newText({
        parent = group,
        text = string.format("Target: %d", params.target or 0),
        x = background.x,
        y = background.y + 80,
        font = settings.defaultFont,
        fontSize = 20,
    })
    targetLabel:setFillColor(0.9, 0.9, 0.9)
end

local function createButton(group, label, x, y, onTap)
    local button = display.newRoundedRect(group, x, y, 160, 52, 14)
    button:setFillColor(0.12, 0.12, 0.12)
    button.strokeWidth = 2
    button:setStrokeColor(lib.convertHexToRGB("#F5A623"))

    local text = display.newText({
        parent = group,
        text = label,
        x = button.x,
        y = button.y,
        font = settings.defaultFont,
        fontSize = 20,
    })
    text:setFillColor(1, 1, 1)

    button:addEventListener("touch", function(event)
        if event.phase == "began" then
            button.alpha = 0.7
            text.alpha = 0.7
        elseif event.phase == "ended" then
            button.alpha = 1
            text.alpha = 1
            onTap()
        elseif event.phase == "cancelled" then
            button.alpha = 1
            text.alpha = 1
        end
        return true
    end)
end

local function buildButtons(group, params)
    local buttonY = screen.centerY + 160
    createButton(group, "Retry", screen.centerX - 90, buttonY, function()
        composer.gotoScene(scenes.game, {
            effect = "slideRight",
            time = 250,
            params = { currentLevel = params.currentLevel },
        })
    end)

    local isLastLevel = TOTAL_LEVELS > 0 and params.currentLevel >= TOTAL_LEVELS
    local nextLabel = isLastLevel and "Menu" or "Next"
    createButton(group, nextLabel, screen.centerX + 90, buttonY, function()
        if isLastLevel then
            composer.gotoScene(scenes.menu, { effect = "fade", time = 300 })
        else
            composer.gotoScene(scenes.game, {
                effect = "slideLeft",
                time = 250,
                params = { currentLevel = params.currentLevel + 1 },
            })
        end
    end)
end

local function onSceneCreate(event)
    cancelTimers()
    local sceneGroup = scene.view
    state.params = event.params or {}
    state.stars = computeStars(tonumber(state.params.moves) or 0, tonumber(state.params.target) or 0)

    local background = display.newRect(sceneGroup, screen.centerX, screen.centerY, screen.width, screen.height)
    background:setFillColor(0, 0, 0, 0.55)

    buildSummary(sceneGroup, state.params)
    buildButtons(sceneGroup, state.params)
end

scene:addEventListener("create", onSceneCreate)

local function onSceneShow(_, event)
    if event.phase == "will" then
        composer.removeScene(scenes.game)
    end
end

local function onSceneHide(_, event)
    if event.phase == "will" then
        cancelTimers()
    end
end

local function onSceneDestroy()
    cancelTimers()
end

scene:addEventListener("show", onSceneShow)
scene:addEventListener("hide", onSceneHide)
scene:addEventListener("destroy", onSceneDestroy)

return scene
