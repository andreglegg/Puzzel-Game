local performance = {}

local mFloor = math.floor
local sGetInfo = system.getInfo
local sGetTimer = system.getTimer

local prevTime = 0
performance.added = true

local function createText()
    local memory = display.newText("00 00.00 000", 10, 0, "Helvetica", 14)
    memory:setFillColor(1)
    memory.anchorY = 0
    memory.x = display.contentCenterX
    memory.y = display.screenOriginY + 25

    local function onTap(self)
        collectgarbage("collect")
        if performance.added then
            Runtime:removeEventListener("enterFrame", performance.labelUpdater)
            performance.added = false
            self.alpha = 0.05
        else
            Runtime:addEventListener("enterFrame", performance.labelUpdater)
            performance.added = true
            self.alpha = 1
        end
    end

    memory:addEventListener("tap", onTap)
    return memory
end

function performance.labelUpdater()
    local curTime = sGetTimer()
    if curTime == prevTime then
        return
    end

    local frame = mFloor(1000 / (curTime - prevTime))
    local textureMemory = mFloor(sGetInfo("textureMemoryUsed") * 0.0001) * 0.01
    local luaMemory = mFloor(collectgarbage("count"))

    performance.text.text = string.format("%02d %05.2f %03d", frame, textureMemory, luaMemory)
    performance.text:toFront()
    prevTime = curTime
end

function performance.newPerformanceMeter()
    performance.text = createText()
    Runtime:addEventListener("enterFrame", performance.labelUpdater)
end

return performance
