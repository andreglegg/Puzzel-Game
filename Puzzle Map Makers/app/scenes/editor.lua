local composer = require("composer")

local scene = composer.newScene()

local lib = require("libs.app5iveLib")
local screen = require("libs.screen")
local widget = require("widget")
local lfs = require("lfs")

local BACKGROUND_COLOR = lib.convertHexToRGB("#ECECEC")
local PRIMARY_TEXT_COLOR = lib.convertHexToRGB("#1e1e1e")
local ACCENT_TEXT_COLOR = lib.convertHexToRGB("#0A579B")
local GRID_ASSET_PATH = "images/grid/grey/"
local PIECE_ASSET_PATH = "images/"
local GRID_SPACING = 2
local DEFAULT_CELL_SIZE = 80
local DEFAULT_TARGET = 0
local SCROLL_WIDTH = 260
local SCROLL_HEIGHT = 360

local PIECES = {
    { type = "finish", image = "finish.png" },
    { type = "moveable", image = "yellow_ball.png" },
    { type = "nomove", image = "nomove.png" },
    { type = "push", image = "push.png" },
    { type = "dumb", image = "dumb.png" },
    { type = "blueTp", image = "blueTp.png" },
    { type = "whiteTp", image = "whiteTp.png" },
    { type = "delete", image = "delete.png" },
    { type = "upArrow", image = "upArrow.png" },
    { type = "rightArrow", image = "rightArrow.png" },
    { type = "downArrow", image = "downArrow.png" },
    { type = "leftArrow", image = "leftArrow.png" },
}

local state = {
    groups = {},
    grid = {},
    pieces = {},
    pieceByCell = {},
    selectedPieceType = PIECES[1].type,
    levelNumber = 1,
    levelFiles = {},
    textFields = {},
    scrollView = nil,
    width = 2,
    height = 2,
    target = DEFAULT_TARGET,
    cellWidth = DEFAULT_CELL_SIZE,
    cellHeight = DEFAULT_CELL_SIZE,
}

local function clearGroup(group)
    if not group then
        return
    end
    while group.numChildren > 0 do
        local child = group[1]
        child:removeSelf()
    end
end

local function keyForCell(x, y)
    return string.format("%d:%d", x, y)
end

local function updateConfig()
    state.config = {
        type = "config",
        gw = state.width,
        gh = state.height,
        cw = state.cellWidth,
        ch = state.cellHeight,
        target = state.target,
    }
end

local function rebuildPieceData()
    local data = {}
    for _, piece in pairs(state.pieces) do
        data[#data + 1] = {
            type = piece.type,
            x = piece.gridX,
            y = piece.gridY,
        }
    end
    table.sort(data, function(a, b)
        if a.y == b.y then
            return a.x < b.x
        end
        return a.y < b.y
    end)
    state.levelData = { state.config }
    for _, row in ipairs(data) do
        state.levelData[#state.levelData + 1] = row
    end
end

local function removePieceAt(x, y)
    local key = keyForCell(x, y)
    local piece = state.pieceByCell[key]
    if not piece then
        return
    end
    piece:removeSelf()
    state.pieceByCell[key] = nil
    state.pieces[piece.id] = nil
    rebuildPieceData()
end

local function spawnPieceAt(x, y, pieceType)
    local assets = PIECE_ASSET_PATH .. pieceType .. ".png"
    removePieceAt(x, y)

    local piece = display.newImageRect(state.groups.pieces, assets, state.cellWidth * 0.6, state.cellHeight * 0.6)
    if not piece then
        return
    end

    local cell = state.grid[x][y]
    piece.x, piece.y = cell.x, cell.y
    piece.gridX, piece.gridY = x, y
    piece.type = pieceType
    piece.id = system.getTimer() .. keyForCell(x, y)
    state.pieces[piece.id] = piece
    state.pieceByCell[keyForCell(x, y)] = piece

    if pieceType == "moveable" then
        piece.width = piece.width / 5
        piece.height = piece.height / 5
        transition.scaleTo(piece, {
            delay = 100,
            xScale = 5,
            yScale = 5,
            time = 400,
            transition = easing.outElastic,
        })
    end

    rebuildPieceData()
end

local function deselectPalette()
    if state.selectedPalette then
        state.selectedPalette:setFillColor(1, 1, 1)
        state.selectedPalette = nil
    end
end

local function selectPalette(rect, pieceType)
    deselectPalette()
    state.selectedPalette = rect
    state.selectedPalette:setFillColor(lib.convertHexToRGB("#F5A623"))
    state.selectedPieceType = pieceType
end

local function onCellTouch(event)
    if event.phase ~= "began" then
        return true
    end
    local cell = event.target
    if not state.selectedPieceType then
        return true
    end
    if state.selectedPieceType == "delete" then
        removePieceAt(cell.gridX, cell.gridY)
    else
        spawnPieceAt(cell.gridX, cell.gridY, state.selectedPieceType)
    end
    return true
end

local function buildGrid()
    clearGroup(state.groups.grid)
    clearGroup(state.groups.pieces)
    state.grid = {}
    state.pieces = {}
    state.pieceByCell = {}

    local holder = state.groups.gridHolder
    holder.x = screen.centerX
    holder.y = screen.centerY - 40

    local width = state.width
    local height = state.height
    local cw = state.cellWidth
    local ch = state.cellHeight

    for x = 1, width do
        state.grid[x] = {}
        for y = 1, height do
            local asset = "middle"
            if x == 1 and y == 1 then
                asset = "topLeft"
            elseif x == width and y == 1 then
                asset = "topRight"
            elseif x == 1 and y == height then
                asset = "bottomLeft"
            elseif x == width and y == height then
                asset = "bottomRight"
            elseif y == 1 then
                asset = "top"
            elseif y == height then
                asset = "bottom"
            elseif x == 1 then
                asset = "left"
            elseif x == width then
                asset = "right"
            end

            local gridImage = display.newImageRect(holder, GRID_ASSET_PATH .. asset .. ".png", cw, ch)
            gridImage.x = (x - 1) * (cw + GRID_SPACING)
            gridImage.y = (y - 1) * (ch + GRID_SPACING)
            gridImage.gridX = x
            gridImage.gridY = y
            gridImage:addEventListener("touch", onCellTouch)
            state.grid[x][y] = gridImage
        end
    end

    holder.anchorChildren = true
    holder.anchorX = 0.5
    holder.anchorY = 0.5

    updateConfig()
    rebuildPieceData()
end

local function clampDimensions()
    if state.width < 2 then
        state.width = 2
    end
    if state.height < 2 then
        state.height = 2
    end
    if state.width > 10 then
        state.width = 10
    end
    if state.height > 10 then
        state.height = 10
    end
end

local function updateFieldValues()
    if state.textFields.width then
        state.textFields.width.text = tostring(state.width)
    end
    if state.textFields.height then
        state.textFields.height.text = tostring(state.height)
    end
    if state.textFields.target then
        state.textFields.target.text = tostring(state.target)
    end
    if state.textFields.levelNumber then
        state.textFields.levelNumber.text = tostring(state.levelNumber)
    end
end

local function refreshPalette()
    clearGroup(state.groups.palette)
    local padding = 12
    local size = 44
    local y = padding
    for _, item in ipairs(PIECES) do
        local rect = display.newRect(state.groups.palette, 0, y, size, size)
        rect.anchorX, rect.anchorY = 0, 0
        rect.strokeWidth = 2
        rect:setFillColor(1, 1, 1)
        rect:setStrokeColor(lib.convertHexToRGB("#1e1e1e"))

        local icon = display.newImageRect(
            state.groups.palette,
            PIECE_ASSET_PATH .. item.image,
            size * 0.75,
            size * 0.75
        )
        icon.x = rect.x + size * 0.5
        icon.y = rect.y + size * 0.5

        rect:addEventListener("touch", function(event)
            if event.phase == "began" then
                selectPalette(rect, item.type)
            end
            return true
        end)

        if state.selectedPieceType == item.type then
            selectPalette(rect, item.type)
        end

        y = y + size + padding
    end
end

local function saveLevel()
    rebuildPieceData()
    local levelNumber = state.levelNumber
    if levelNumber <= 0 then
        return
    end

    local lines = {}
    lines[#lines + 1] = "local level = {"
    for _, row in ipairs(state.levelData) do
        local segments = {}
        for key, value in pairs(row) do
            if type(value) == "string" then
                segments[#segments + 1] = string.format("%s=\"%s\"", key, value)
            else
                segments[#segments + 1] = string.format("%s=%s", key, tostring(value))
            end
        end
        lines[#lines + 1] = string.format("   { %s },", table.concat(segments, ", "))
    end
    lines[#lines + 1] = "}"
    lines[#lines + 1] = "return level"

    local content = table.concat(lines, "\n")
    local path = system.pathForFile("level" .. levelNumber .. ".lua", system.DocumentsDirectory)
    local file = io.open(path, "w+")
    if not file then
        print("[editor] Unable to open file for writing:", path)
        return
    end
    file:write(content)
    file:close()
    print("[editor] Saved", path)
end

local function loadLevelModule(levelModule)
    if package.loaded[levelModule] then
        package.loaded[levelModule] = nil
    end
    local ok, moduleData = pcall(require, levelModule)
    if not ok then
        print("[editor] Failed to load level module:", levelModule, moduleData)
        return
    end
    if type(moduleData) ~= "table" or not moduleData[1] then
        print("[editor] Invalid level data:", levelModule)
        return
    end

    local config = moduleData[1]
    state.width = tonumber(config.gw) or state.width
    state.height = tonumber(config.gh) or state.height
    state.cellWidth = tonumber(config.cw) or state.cellWidth
    state.cellHeight = tonumber(config.ch) or state.cellHeight
    state.target = tonumber(config.target) or DEFAULT_TARGET
    clampDimensions()
    updateFieldValues()
    buildGrid()

    for index = 2, #moduleData do
        local row = moduleData[index]
        if row.type and row.x and row.y then
            spawnPieceAt(row.x, row.y, row.type)
        end
    end
end

local function refreshLevelList()
    state.levelFiles = {}
    local levelsPath = system.pathForFile("levels", system.ResourceDirectory)
    if not levelsPath then
        return
    end

    for file in lfs.dir(levelsPath) do
        if file:match("^level%d+%.lua$") then
            state.levelFiles[#state.levelFiles + 1] = file
        end
    end
    table.sort(state.levelFiles)

    if state.scrollView then
        state.scrollView:removeSelf()
        state.scrollView = nil
    end

    local scrollView = widget.newScrollView({
        width = SCROLL_WIDTH,
        height = SCROLL_HEIGHT,
        horizontalScrollDisabled = true,
        backgroundColor = { 1, 1, 1, 0 },
    })
    scrollView.x = screen.left + SCROLL_WIDTH * 0.5 + 20
    scrollView.y = screen.centerY
    state.groups.ui:insert(scrollView)
    state.scrollView = scrollView

    local y = 20
    for _, file in ipairs(state.levelFiles) do
        local group = display.newGroup()
        scrollView:insert(group)

        local buttonBg = display.newRoundedRect(group, 0, y, SCROLL_WIDTH - 20, 36, 6)
        buttonBg.anchorX, buttonBg.anchorY = 0.5, 0
        buttonBg:setFillColor(lib.convertHexToRGB("#ECECEC"))
        buttonBg.strokeWidth = 1
        buttonBg:setStrokeColor(lib.convertHexToRGB("#1e1e1e"))

        local label = display.newText({
            parent = group,
            text = file:gsub("%.lua$", ""),
            x = buttonBg.x,
            y = buttonBg.y + buttonBg.height * 0.5,
            font = native.systemFontBold,
            fontSize = 18,
        })
        label:setFillColor(PRIMARY_TEXT_COLOR)

        local moduleName = "Puzzle Map Makers.levels." .. file:gsub("%.lua$", "")
        buttonBg:addEventListener("touch", function(event)
            if event.phase == "began" then
                state.levelNumber = tonumber(file:match("%d+")) or state.levelNumber
                updateFieldValues()
                loadLevelModule(moduleName)
            end
            return true
        end)

        y = y + 44
    end
end

local function onFieldInput(event)
    if event.phase ~= "ended" and event.phase ~= "submitted" then
        return
    end
    local value = tonumber(event.target.text)
    if not value then
        updateFieldValues()
        return
    end

    if event.target.key == "width" then
        state.width = value
        clampDimensions()
        buildGrid()
    elseif event.target.key == "height" then
        state.height = value
        clampDimensions()
        buildGrid()
    elseif event.target.key == "target" then
        state.target = math.max(0, value)
        updateConfig()
        rebuildPieceData()
    elseif event.target.key == "level" then
        state.levelNumber = math.max(1, math.floor(value + 0.5))
    end
    updateFieldValues()
end

local function createTextField(_parent, x, y, width, key, defaultValue)
    local field = native.newTextField(x, y, width, 34)
    field.anchorX = 0
    field.text = tostring(defaultValue)
    field.inputType = "number"
    field.key = key
    field:addEventListener("userInput", onFieldInput)
    state.textFields[key] = field
    return field
end

local function buildUI(sceneGroup)
    local background = display.newRect(sceneGroup, screen.centerX, screen.centerY, screen.width, screen.height)
    background:setFillColor(BACKGROUND_COLOR)

    state.groups.background = sceneGroup
    state.groups.gridHolder = display.newGroup()
    state.groups.grid = display.newGroup()
    state.groups.pieces = display.newGroup()
    state.groups.ui = display.newGroup()
    state.groups.palette = display.newGroup()

    sceneGroup:insert(state.groups.gridHolder)
    state.groups.gridHolder:insert(state.groups.grid)
    state.groups.gridHolder:insert(state.groups.pieces)
    sceneGroup:insert(state.groups.ui)
    sceneGroup:insert(state.groups.palette)

    state.groups.palette.x = screen.right - 120
    state.groups.palette.y = screen.centerY - 180

    local controlGroup = display.newGroup()
    controlGroup.x = screen.centerX - 160
    controlGroup.y = screen.top + 40
    state.groups.ui:insert(controlGroup)

    local widthLabel = display.newText({
        parent = controlGroup,
        text = "Width",
        x = 0,
        y = 0,
        font = native.systemFontBold,
        fontSize = 18,
    })
    widthLabel.anchorX = 0
    widthLabel:setFillColor(PRIMARY_TEXT_COLOR)

    createTextField(controlGroup, widthLabel.x, widthLabel.y + 20, 60, "width", state.width)

    local heightLabel = display.newText({
        parent = controlGroup,
        text = "Height",
        x = widthLabel.x + 80,
        y = widthLabel.y,
        font = native.systemFontBold,
        fontSize = 18,
    })
    heightLabel.anchorX = 0
    heightLabel:setFillColor(PRIMARY_TEXT_COLOR)

    createTextField(controlGroup, heightLabel.x, heightLabel.y + 20, 60, "height", state.height)

    local targetLabel = display.newText({
        parent = controlGroup,
        text = "Target",
        x = heightLabel.x + 80,
        y = heightLabel.y,
        font = native.systemFontBold,
        fontSize = 18,
    })
    targetLabel.anchorX = 0
    targetLabel:setFillColor(PRIMARY_TEXT_COLOR)

    createTextField(controlGroup, targetLabel.x, targetLabel.y + 20, 60, "target", state.target)

    local levelLabel = display.newText({
        parent = controlGroup,
        text = "Level #",
        x = targetLabel.x + 80,
        y = targetLabel.y,
        font = native.systemFontBold,
        fontSize = 18,
    })
    levelLabel.anchorX = 0
    levelLabel:setFillColor(PRIMARY_TEXT_COLOR)

    createTextField(controlGroup, levelLabel.x, levelLabel.y + 20, 60, "level", state.levelNumber)

    local buildButton = display.newText({
        parent = controlGroup,
        text = "Rebuild Grid",
        x = widthLabel.x,
        y = widthLabel.y + 70,
        font = native.systemFontBold,
        fontSize = 20,
    })
    buildButton.anchorX = 0
    buildButton:setFillColor(ACCENT_TEXT_COLOR)
    buildButton:addEventListener("touch", function(event)
        if event.phase == "began" then
            clampDimensions()
            updateFieldValues()
            buildGrid()
        end
        return true
    end)

    local saveButton = display.newText({
        parent = controlGroup,
        text = "Save",
        x = buildButton.x + 220,
        y = buildButton.y,
        font = native.systemFontBold,
        fontSize = 20,
    })
    saveButton.anchorX = 0
    saveButton:setFillColor(ACCENT_TEXT_COLOR)
    saveButton:addEventListener("touch", function(event)
        if event.phase == "began" then
            saveLevel()
        end
        return true
    end)

    refreshPalette()
    refreshLevelList()
end

local function onSceneCreate()
    display.setDefault("background", BACKGROUND_COLOR)
    buildUI(scene.view)
    clampDimensions()
    updateFieldValues()
    buildGrid()
end

local function onSceneShow(event)
    if event and event.phase == "did" then
        refreshLevelList()
    end
end

local function onSceneHide(event)
    if event and event.phase == "will" then
        deselectPalette()
    end
end

local function onSceneDestroy()
    for _, field in pairs(state.textFields) do
        field:removeSelf()
    end
    state.textFields = {}
    clearGroup(state.groups.gridHolder)
    clearGroup(state.groups.ui)
    clearGroup(state.groups.palette)
end

scene:addEventListener("create", onSceneCreate)
scene:addEventListener("show", onSceneShow)
scene:addEventListener("hide", onSceneHide)
scene:addEventListener("destroy", onSceneDestroy)

return scene
