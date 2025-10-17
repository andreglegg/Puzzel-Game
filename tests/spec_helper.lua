local sep = package.config:sub(1, 1)
local current_file = debug.getinfo(1, "S").source:sub(2)
local repo_root = current_file:match("^(.*" .. sep .. ")tests" .. sep .. "spec_helper%.lua$")
if not repo_root then
    error("Unable to determine repository root from spec_helper")
end

local function prepend_path(pattern)
    local new_path = repo_root .. pattern
    if not package.path:find(new_path, 1, true) then
        package.path = new_path .. ";" .. package.path
    end
end

prepend_path("Puzzle" .. sep .. "?.lua")
prepend_path("Puzzle" .. sep .. "?" .. sep .. "init.lua")
prepend_path("Puzzle" .. sep .. "?" .. sep .. "?.lua")
prepend_path("Puzzle Map Makers" .. sep .. "?.lua")
prepend_path("Puzzle Map Makers" .. sep .. "?" .. sep .. "init.lua")

return {
    repo_root = repo_root,
    puzzle_root = repo_root .. "Puzzle" .. sep,
    editor_root = repo_root .. "Puzzle Map Makers" .. sep
}
