std = "lua53"

-- Solar2D exposes globals we rely on in runtime scenes
globals = {
  "display", "composer", "system", "timer", "transition", "Runtime",
  "media", "audio", "native", "graphics", "math", "easing"
}

-- Allow modules under Puzzle/ and Puzzle Map Makers/
files = {
  "Puzzle/**/*.lua",
  "Puzzle Map Makers/**/*.lua",
  "tests/**/*.lua"
}

ignore = {
  -- Composer scenes intentionally use unused event arguments in lifecycle callbacks
  "21/211",
}
