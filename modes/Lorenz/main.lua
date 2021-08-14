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
  x = 0.1,
  y = 0.1,
  z = 0.1,
  -- a = 10, -- original
  a = 15, -- v1
  b = 28, -- original
  -- b = 24, -- v1
  -- b = 22, -- v2
  c = 8.0/3.0,
  dt = 0.01, -- original
  continuous = false,
  maxPointCount = 500,
  randomNoiseScale = 0.1,
  audioScale = 2,
  circleWidth = 1.5,
  rotateSpeed = 0.075,
}

local state = {
  x = config.x,
  y = config.y,
  z = config.z,
  points = {},
  lastInsert = 0,
  pointHue = 0,
  tick = 0,
}

function setup()
  compat:setup()
  print("Lorenz")
end

function update()
  compat:update()

  -- Calculate attractor position
  local dx = (config.a * (state.y - state.x)) * config.dt
  local dy = (state.x * (config.b - state.z) - state.y) * config.dt
  local dz = (state.x * state.y - config.c * state.z) * config.dt

  -- Store current position
  state.x = state.x + dx
  state.y = state.y + dy
  state.z = state.z + dz

  -- Extend structure with current point
  -- but respect the maximum point count
  local p = glm.vec3(state.x, state.y, state.z)
  local insertIdx = state.lastInsert + 1
  if insertIdx > config.maxPointCount then
    insertIdx = 1
    print("reset to 1")
  end
  if #state.points >= config.maxPointCount then
    state.points[insertIdx] = p
  else
    table.insert(state.points, insertIdx, p)
  end
  state.lastInsert = insertIdx

  -- Rotate color hue over time
  state.pointHue = (state.pointHue + 1) % 255
end

function draw()
  compat:draw()
  state.tick = state.tick + 1

  of.setColor(255)
  of.noFill()

  of.translate(W2(), H2())
  of.scale(5)
  of.rotateDeg((state.tick * config.rotateSpeed) % 360)
  of.fill()
  of.setLineWidth(1)

  -- of.beginShape()
  for i, p in ipairs(state.points) do
    if config.continuous then
      if i % 8 == 0 then
        of.endShape()
      elseif i % 4 == 0 then
        of.beginShape()
      end
    end

    -- Modulate shape outline by combining vertex points with other values
    local idx = i % #inC + 1
    local audioVal = inC[idx]
    local rx = audioVal
    local ry = audioVal
    local rz = audioVal

    -- Modulate with random values - makes wiggly lines
    rx = of.random(-1, 1) * config.randomNoiseScale
    ry = of.random(-1, 1) * config.randomNoiseScale
    rz = of.random(-1, 1) * config.randomNoiseScale

    -- Use alpha channel to fade out points relative to their place in line
    local alpha = of.map(0, #state.points, 0, 255, i)
    -- Vary the dot color with each step
    local dotHue = (state.pointHue + i) % 255
    of.setColor(of.Color.fromHsb(dotHue, 255, 255, alpha))

    -- Render either a single continuous shape or a dotted trail
    local rp = glm.vec3(rx, ry, rz)
    local pos = p + (rp * config.audioScale)
    if state.continuous then
      of.vertex(pos)
    else
      of.drawCircle(pos, config.circleWidth)
    end
  end
end
