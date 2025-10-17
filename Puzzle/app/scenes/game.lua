display.setStatusBar(display.HiddenStatusBar)

local composer = require("composer")
local scenes = require("app.scene_names")

local lib = require("libs.app5iveLib")
local screen = require("libs.screen")
local settings = require("settings")

local scene = composer.newScene()

local UI_COLORS = {
    text = lib.convertHexToRGB("#F5A623"),
    label = lib.convertHexToRGB("#1e1e1e"),
}

local state = {
    currentLevel = 1,
    levelData = nil,
    config = {
        gw = 2,
        gh = 2,
        cw = 80,
        ch = 80,
        target = 0,
    },
    groups = {},
    grid = {},
    pieces = {},
    pieceList = {},
    teleports = {
        blue = nil,
    },
    ui = {},
    moves = 0,
    finishCount = 0,
    totalFinishes = 0,
    swipeActive = false,
}

local function updateUi()
    if state.ui.movesDisplay then
        state.ui.movesDisplay.text = tostring(state.moves)
        state.ui.movesLabel.x = state.ui.movesDisplay.x - state.ui.movesDisplay.width - 4
    end
    if state.ui.levelDisplay then
        state.ui.levelDisplay.text = tostring(state.currentLevel)
        state.ui.levelDisplay.x = state.ui.levelLabel.x + state.ui.levelLabel.width + 4
    end
    if state.ui.targetDisplay then
        state.ui.targetDisplay.text = tostring(state.config.target)
        state.ui.targetDisplay.x = state.ui.targetLabel.x + state.ui.targetLabel.width + 4
    end
end

local function clearGroup(group)
    if not group then
        return
    end
    while group.numChildren > 0 do
        local child = group[1]
        child:removeSelf()
    end
end

local function resetPieces()
    state.pieces = {}
    state.pieceList = {}
    state.teleports.blue = nil
    state.finishCount = 0
    state.totalFinishes = 0
end

local function gridKey(x, y)
    return string.format("%d:%d", x, y)
end

local function getCell(x, y)
    return state.grid[x] and state.grid[x][y] or nil
end

local function setPiece(piece)
    state.pieces[piece.id] = piece
    state.pieceList[#state.pieceList + 1] = piece
    local cell = getCell(piece.gridX, piece.gridY)
    if cell then
        cell.type = piece.type
        cell.type2 = piece.type
        cell.hasPiece = true
    end
end

local function createGridCell(holder, x, y)
    local asset = "middle"
    local config = state.config
    if x == 1 and y == 1 then
        asset = "topLeft"
    elseif x == config.gw and y == 1 then
        asset = "topRight"
    elseif x == 1 and y == config.gh then
        asset = "bottomLeft"
    elseif x == config.gw and y == config.gh then
        asset = "bottomRight"
    elseif y == 1 then
        asset = "top"
    elseif y == config.gh then
        asset = "bottom"
    elseif x == 1 then
        asset = "left"
    elseif x == config.gw then
        asset = "right"
    end

    local image = display.newImageRect(holder, "images/grid/grey/" .. asset .. ".png", config.cw, config.ch)
    image.x = (x - 1) * config.cw
    image.y = (y - 1) * config.ch
    image.gridX = x
    image.gridY = y
    image.hasPiece = false
    image.type = "empty"
    image.type2 = "empty"
    image.isArrow = nil
    state.grid[x][y] = image
    return image
end

local function ensureGrid()
    clearGroup(state.groups.gridLayer)
    state.grid = {}
    for x = 1, state.config.gw do
        state.grid[x] = {}
        for y = 1, state.config.gh do
            createGridCell(state.groups.gridLayer, x, y)
        end
    end
end

local function registerTeleport(piece)
    if piece.type == "blueTp" then
        state.teleports.blue = { x = piece.gridX, y = piece.gridY }
    end
end

local function spawnPiece(x, y, pieceType)
    local cell = getCell(x, y)
    if not cell then
        return nil
    end

    local group = state.groups.pieceMid
    local asset = "yellow_ball"

    if pieceType == "finish" then
        asset = "finish"
        group = state.groups.pieceTop
        state.totalFinishes = state.totalFinishes + 1
    elseif pieceType == "nomove" then
        asset = "nomove"
        group = state.groups.pieceMid
    elseif pieceType == "push" then
        asset = "push"
    elseif pieceType == "dumb" then
        asset = "dumb"
    elseif pieceType == "blueTp" then
        asset = "blueTp"
        group = state.groups.pieceTop
    elseif pieceType == "whiteTp" then
        asset = "whiteTp"
        group = state.groups.pieceBottom
    elseif pieceType == "upArrow" then
        asset = "upArrow"
        group = state.groups.pieceBottom
        cell.isArrow = "up"
    elseif pieceType == "rightArrow" then
        asset = "rightArrow"
        group = state.groups.pieceBottom
        cell.isArrow = "right"
    elseif pieceType == "downArrow" then
        asset = "downArrow"
        group = state.groups.pieceBottom
        cell.isArrow = "down"
    elseif pieceType == "leftArrow" then
        asset = "leftArrow"
        group = state.groups.pieceBottom
        cell.isArrow = "left"
    end

    local piece = display.newImageRect(
        group,
        "images/" .. asset .. ".png",
        state.config.cw * 0.6,
        state.config.ch * 0.6
    )
    piece.x = cell.x
    piece.y = cell.y
    piece.type = pieceType
    piece.gridX = x
    piece.gridY = y
    piece.id = system.getTimer() .. ":" .. gridKey(x, y)
    piece.isMovable = pieceType == "moveable" or pieceType == "push"
    setPiece(piece)
    registerTeleport(piece)

    if pieceType == "moveable" then
        piece.xScale = 0.2
        piece.yScale = 0.2
        transition.scaleTo(piece, { xScale = 1, yScale = 1, time = 400, transition = easing.outElastic })
    end

    return piece
end

local function getPiecesSorted(direction)
    local axis = (direction == "left" or direction == "right") and "x" or "y"
    local ascending = (direction == "left" or direction == "up")

    table.sort(state.pieceList, function(a, b)
        if axis == "x" then
            if ascending then
                return a.gridX < b.gridX
            end
            return a.gridX > b.gridX
        else
            if ascending then
                return a.gridY < b.gridY
            end
            return a.gridY > b.gridY
        end
    end)
    return state.pieceList
end

local function isWithinBounds(x, y)
    return x >= 1 and x <= state.config.gw and y >= 1 and y <= state.config.gh
end

local function canOccupy(x, y)
    local cell = getCell(x, y)
    return cell and not cell.hasPiece and cell.type ~= "nomove"
end

local function movePieceTo(piece, x, y, params)
    local oldCell = getCell(piece.gridX, piece.gridY)
    if oldCell then
        oldCell.hasPiece = false
        oldCell.type = "empty"
        oldCell.type2 = "empty"
    end

    piece.gridX = x
    piece.gridY = y
    local newCell = getCell(x, y)
    newCell.hasPiece = true
    newCell.type = piece.type
    newCell.type2 = piece.type

    transition.to(piece, {
        time = params.time or 120,
        x = newCell.x,
        y = newCell.y,
        transition = params.transition or easing.outQuad,
        onComplete = params.onComplete,
    })
end

local function handleTeleport(piece)
    if piece.type ~= "moveable" then
        return false
    end
    local cell = getCell(piece.gridX, piece.gridY)
    if not cell or cell.type ~= "blueTp" then
        return false
    end
    local teleport = state.teleports.blue
    if not teleport then
        return false
    end

    state.swipeActive = true
    local destination = getCell(teleport.x, teleport.y)
    if not destination then
        return false
    end

    transition.to(piece, {
        time = 80,
        alpha = 0,
        onComplete = function()
            movePieceTo(piece, teleport.x, teleport.y, {
                time = 1,
                onComplete = function()
                    piece.alpha = 1
                    state.swipeActive = false
                end,
            })
        end,
    })

    return true
end

local function advanceByArrow(piece)
    local cell = getCell(piece.gridX, piece.gridY)
    if not cell or not cell.isArrow then
        return false
    end

    local dx, dy = 0, 0
    if cell.isArrow == "up" then
        dy = -1
    elseif cell.isArrow == "down" then
        dy = 1
    elseif cell.isArrow == "left" then
        dx = -1
    elseif cell.isArrow == "right" then
        dx = 1
    end

    local nx, ny = piece.gridX + dx, piece.gridY + dy
    if not isWithinBounds(nx, ny) or not canOccupy(nx, ny) then
        return false
    end

    movePieceTo(piece, nx, ny, { time = 100 })
    return true
end

local function incrementFinishCount(piece)
    local cell = getCell(piece.gridX, piece.gridY)
    if cell and cell.type2 == "finish" then
        state.finishCount = state.finishCount + 1
    end
end

local function decrementFinishCount(piece)
    local cell = getCell(piece.gridX, piece.gridY)
    if cell and cell.type2 == "finish" then
        state.finishCount = math.max(0, state.finishCount - 1)
    end
end

local function prepareMove()
    state.moves = state.moves + 1
    state.swipeActive = true
    updateUi()
end

local function completeMove()
    state.swipeActive = false
    if state.finishCount >= state.totalFinishes and state.totalFinishes > 0 then
        composer.gotoScene(scenes.reload, {
            effect = "fromBottom",
            time = 300,
            params = {
                currentLevel = state.currentLevel,
                moves = state.moves,
                target = state.config.target,
            },
        })
    end
end

local function handlePush(piece, dx, dy)
    if piece.type ~= "push" then
        return false
    end
    local nx, ny = piece.gridX + dx, piece.gridY + dy
    if not isWithinBounds(nx, ny) or not canOccupy(nx, ny) then
        return false
    end
    movePieceTo(piece, nx, ny, { time = 120 })
    return true
end

local function attemptMove(piece, direction)
    local dx, dy = 0, 0
    if direction == "up" then
        dy = -1
    elseif direction == "down" then
        dy = 1
    elseif direction == "left" then
        dx = -1
    elseif direction == "right" then
        dx = 1
    end

    local targetX = piece.gridX + dx
    local targetY = piece.gridY + dy

    if not isWithinBounds(targetX, targetY) then
        return false
    end

    local targetCell = getCell(targetX, targetY)
    if targetCell.hasPiece then
        local occupant = nil
        for _, other in pairs(state.pieces) do
            if other.gridX == targetX and other.gridY == targetY then
                occupant = other
                break
            end
        end
        if occupant and occupant.type == "push" then
            if not handlePush(occupant, dx, dy) then
                return false
            end
        else
            return false
        end
    end

    decrementFinishCount(piece)
    movePieceTo(piece, targetX, targetY, {
        time = 140,
        onComplete = function()
            incrementFinishCount(piece)
            if not advanceByArrow(piece) then
                handleTeleport(piece)
            end
            completeMove()
        end,
    })

    return true
end

local function handleSwipe(direction)
    if state.swipeActive then
        return
    end

    local moved = false
    local pieces = getPiecesSorted(direction)

    for _, piece in ipairs(pieces) do
        if piece.type == "moveable" then
            if attemptMove(piece, direction) then
                moved = true
            end
        end
    end

    if moved then
        prepareMove()
    end
end

local function onTouch(event)
    if event.phase == "began" then
        state.touch = { startX = event.x, startY = event.y, handled = false }
        return true
    elseif event.phase == "moved" and state.touch and not state.touch.handled then
        local dx = event.x - state.touch.startX
        local dy = event.y - state.touch.startY
        if math.abs(dx) > 10 or math.abs(dy) > 10 then
            state.touch.handled = true
            if math.abs(dx) > math.abs(dy) then
                handleSwipe(dx > 0 and "right" or "left")
            else
                handleSwipe(dy > 0 and "down" or "up")
            end
        end
    elseif event.phase == "ended" or event.phase == "cancelled" then
        state.touch = nil
    end
    return true
end

local function loadLevel(levelNumber)
    local moduleName = "levels.level" .. levelNumber
    if package.loaded[moduleName] then
        package.loaded[moduleName] = nil
    end
    local ok, data = pcall(require, moduleName)
    if not ok then
        error("Failed to load level " .. tostring(levelNumber) .. ": " .. tostring(data))
    end
    return data
end

local function buildUi(sceneGroup)
    local uiGroup = display.newGroup()
    sceneGroup:insert(uiGroup)
    state.groups.ui = uiGroup

    local controls = display.newGroup()
    uiGroup:insert(controls)

    state.ui.movesDisplay = display.newText({
        parent = controls,
        text = tostring(state.moves),
        x = screen.left + 90,
        y = screen.bottom - 70,
        font = settings.defaultFontOblique,
        fontSize = 28,
    })
    state.ui.movesDisplay:setFillColor(UI_COLORS.text)

    state.ui.movesLabel = display.newText({
        parent = controls,
        text = "MOVES:",
        x = state.ui.movesDisplay.x - state.ui.movesDisplay.width - 4,
        y = state.ui.movesDisplay.y,
        font = settings.defaultFontOblique,
        fontSize = 18,
    })
    state.ui.movesLabel:setFillColor(UI_COLORS.label)

    state.ui.levelLabel = display.newText({
        parent = controls,
        text = "LEVEL:",
        x = screen.right - 200,
        y = state.ui.movesDisplay.y,
        font = settings.defaultFontOblique,
        fontSize = 18,
    })
    state.ui.levelLabel.anchorX = 0
    state.ui.levelLabel:setFillColor(UI_COLORS.label)

    state.ui.levelDisplay = display.newText({
        parent = controls,
        text = tostring(state.currentLevel),
        x = state.ui.levelLabel.x + state.ui.levelLabel.width + 4,
        y = state.ui.levelLabel.y,
        font = settings.defaultFontOblique,
        fontSize = 28,
    })
    state.ui.levelDisplay.anchorX = 0
    state.ui.levelDisplay:setFillColor(UI_COLORS.text)

    state.ui.targetLabel = display.newText({
        parent = controls,
        text = "TARGET:",
        x = state.ui.levelLabel.x,
        y = state.ui.levelLabel.y - 40,
        font = settings.defaultFontOblique,
        fontSize = 18,
    })
    state.ui.targetLabel.anchorX = 0
    state.ui.targetLabel:setFillColor(UI_COLORS.label)

    state.ui.targetDisplay = display.newText({
        parent = controls,
        text = tostring(state.config.target),
        x = state.ui.targetLabel.x + state.ui.targetLabel.width + 4,
        y = state.ui.targetLabel.y,
        font = settings.defaultFontOblique,
        fontSize = 22,
    })
    state.ui.targetDisplay.anchorX = 0
    state.ui.targetDisplay:setFillColor(UI_COLORS.text)

    local reloadButton = display.newImageRect(controls, "images/icons/reload.png", 200, 210)
    reloadButton.anchorX = 0.5
    reloadButton.anchorY = 1
    reloadButton.x = screen.centerX
    reloadButton.y = screen.bottom - 10
    reloadButton.xScale = 0.5
    reloadButton.yScale = 0.5
    reloadButton:addEventListener("touch", function(event)
        if event.phase == "began" then
            composer.gotoScene(scenes.reload, {
                effect = "fromBottom",
                time = 200,
                params = {
                    currentLevel = state.currentLevel,
                    moves = state.moves,
                    target = state.config.target,
                },
            })
        end
        return true
    end)

    state.ui.touchOverlay = display.newRect(sceneGroup, screen.centerX, screen.centerY, screen.width, screen.height)
    state.ui.touchOverlay.alpha = 0.01
    state.ui.touchOverlay.isHitTestable = true
    state.ui.touchOverlay:addEventListener("touch", onTouch)
end

local function buildScene(sceneGroup)
    state.groups.background = display.newGroup()
    state.groups.gridHolder = display.newGroup()
    state.groups.gridHolder.anchorChildren = true
    state.groups.gridHolder.anchorX = 0.5
    state.groups.gridHolder.anchorY = 0.5
    state.groups.gridHolder.x = screen.centerX
    state.groups.gridHolder.y = screen.centerY

    state.groups.gridLayer = display.newGroup()
    state.groups.pieceBottom = display.newGroup()
    state.groups.pieceMid = display.newGroup()
    state.groups.pieceTop = display.newGroup()

    sceneGroup:insert(state.groups.background)
    sceneGroup:insert(state.groups.gridHolder)
    state.groups.gridHolder:insert(state.groups.gridLayer)
    state.groups.gridHolder:insert(state.groups.pieceBottom)
    state.groups.gridHolder:insert(state.groups.pieceMid)
    state.groups.gridHolder:insert(state.groups.pieceTop)

    require("app.backgrounds.deep_dark").addBg(state.groups.background)
end

local function buildPieces()
    resetPieces()
    for index = 2, #state.levelData do
        local entry = state.levelData[index]
        spawnPiece(entry.x, entry.y, entry.type)
    end
end

local function buildLevel()
    ensureGrid()
    buildPieces()
    updateUi()
end

function scene:create(event)
    state.currentLevel = event.params.currentLevel or 1
    state.levelData = loadLevel(state.currentLevel)
    local configRow = state.levelData[1] or {}
    local baseCw = configRow.cw or 80
    local baseCh = configRow.ch or 80
    local gw = configRow.gw or 2
    local gh = configRow.gh or 2
    local maxWidth = screen.width * 0.85
    local maxHeight = math.max(200, screen.height * 0.7)
    local cellSize = math.min(baseCw, baseCh, maxWidth / gw, maxHeight / gh)
    state.config = {
        gw = gw,
        gh = gh,
        cw = cellSize,
        ch = cellSize,
        target = configRow.target or 0,
    }
    state.moves = 0
    state.finishCount = 0

    local sceneGroup = self.view
    buildScene(sceneGroup)
    buildUi(sceneGroup)
    buildLevel()
end

scene:addEventListener("create", scene)

local function onSceneShow(_, event)
    if event and event.phase == "will" then
        composer.removeScene(scenes.reload)
    end
end

local function onSceneDestroy()
    clearGroup(state.groups.background)
    clearGroup(state.groups.gridHolder)
    if state.ui.touchOverlay then
        state.ui.touchOverlay:removeEventListener("touch", onTouch)
        state.ui.touchOverlay:removeSelf()
        state.ui.touchOverlay = nil
    end
end

scene:addEventListener("show", onSceneShow)
scene:addEventListener("destroy", onSceneDestroy)

return scene
