-- New Mode

local compat = require("compat")

local function W()
  return of.getWidth()
end

local function W2()
  return of.getWidth() / 2
end

local function H()
  return of.getHeight()
end

local function H2()
  return of.getHeight() / 2
end

local function C()
  return glm.vec3(W2(), H2(), 0)
end

local config = {
  startStr = "To sit in solemn silence \nin a dull, \ndark, dock, In a\n pestilential prison, with\n a life-long \nlock \n    awaiting the sensation of a short, \nsharp, shock, From a cheap and \nchippy chopper on a big\n   black block",
  maxStrLen = 1000,
  audioScale = 1,
  drawX = 100,
  drawY = 100,
  maxCorruption = 300,
}

local state = {
  str = config.startStr,
  corruptedChars = 0,
}

local font = of.TrueTypeFont()

function setup()
  compat:setup()
  print("CorruptText")

  font:load("FiraCode-Light.ttf", 32)
end

function update()
  compat:update()

  -- Corrupt a random position in the string
  local randIdx = math.floor(of.random(1, #state.str))
  -- Generate random ASCII character
  local rval = of.random(0, 255)
  local code = string.char(math.floor(rval))
  state.str = string.sub(state.str, 1, randIdx) .. code .. string.sub(state.str, randIdx + 1, #state.str)

  -- Limit maximum amount of text corruption
  state.corruptedChars = state.corruptedChars + 1
  if state.corruptedChars >= config.maxCorruption then
    state.corruptedChars = 0
    state.str = config.startStr
  end
end

function draw()
  compat:draw()

  -- Modulate string draw location with audio data
  local audioVal = inC[#inC / 2]
  local ax = audioVal
  local ay = audioVal
  local ap = glm.vec2(ax, ay)
  local p = glm.vec2(config.drawX, config.drawY) + ap * config.audioScale

  font:drawString(state.str, p.x, p.y)
end
