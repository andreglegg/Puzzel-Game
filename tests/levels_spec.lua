local helper = require("tests.spec_helper")

local function collect_level_modules(root, namespace)
    local levels_dir = root .. "levels"
    local handle = assert(io.popen(string.format("ls %q", levels_dir)))
    local modules = {}
    for file in handle:lines() do
        if file:match("^level%d+%.lua$") then
            local module_name = namespace .. ".levels." .. file:gsub("%.lua$", "")
            table.insert(modules, module_name)
        end
    end
    handle:close()
    table.sort(modules)
    return modules
end

local function validate_level(module_name)
    local ok, level = pcall(require, module_name)
    assert.is_true(ok, module_name .. " should load without errors")
    assert.is_table(level, module_name .. " must return a table")
    assert.is_true(#level >= 1, module_name .. " must contain at least one entry")

    local config = level[1]
    assert.is_table(config, module_name .. "config row missing")
    assert.is_equal("config", config.type, module_name .. " first row must be type=config")
    local required_keys = { "gw", "gh", "cw", "ch", "target" }
    for _, key in ipairs(required_keys) do
        assert.is_not_nil(config[key], module_name .. " config missing key: " .. key)
        assert.is_true(type(config[key]) == "number", module_name .. " config." .. key .. " must be numeric")
    end

    for index = 2, #level do
        local row = level[index]
        assert.is_table(row, string.format("%s entry %d must be a table", module_name, index))
        assert.is_string(row.type, string.format("%s entry %d missing type", module_name, index))
        if row.x then
            assert.is_true(type(row.x) == "number" and row.x >= 1 and row.x <= config.gw,
                string.format("%s entry %d x out of range", module_name, index))
        end
        if row.y then
            assert.is_true(type(row.y) == "number" and row.y >= 1 and row.y <= config.gh,
                string.format("%s entry %d y out of range", module_name, index))
        end
    end
end

local puzzle_levels = collect_level_modules(helper.puzzle_root, "Puzzle")
local editor_levels = collect_level_modules(helper.editor_root, "Puzzle Map Makers")

describe("Puzzle levels", function()
    for _, module_name in ipairs(puzzle_levels) do
        it(module_name .. " validates", function()
            validate_level(module_name)
        end)
    end
end)

describe("Editor reference levels", function()
    for _, module_name in ipairs(editor_levels) do
        it(module_name .. " validates", function()
            validate_level(module_name)
        end)
    end
end)
