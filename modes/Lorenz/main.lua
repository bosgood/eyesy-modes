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

local state = {
  x = 0.1,
  y = 0.1,
  z = 0.1,
  a = 10,
  b = 28,
  c = 8.0/3.0,
  points = {},
}

function setup()
  compat:setup()
  print("Lorenz")
end

function update()
  compat:update()

  -- Calculate attractor position
  local dt = 0.01
  local dx = (state.a * (state.y - state.x)) * dt
  local dy = (state.x * (state.b - state.z) - state.y) * dt
  local dz = (state.x * state.y - state.c * state.z) * dt

  -- Store current position
  state.x = state.x + dx
  state.y = state.y + dy
  state.z = state.z + dz
  -- Extend structure with current point
  local p = glm.vec3(state.x, state.y, state.z)
  table.insert(state.points, p)
end

function draw()
  compat:draw()

  of.setColor(255)
  of.noFill()

  of.translate(W2(), H2())
  of.scale(5)

  of.beginShape()
  for _, p in ipairs(state.points) do
    of.vertex(p)
  end
  of.endShape()
end
