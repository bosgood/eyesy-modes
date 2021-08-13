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

function setup()
  compat:setup()
  print("New Mode")
end

function update()
  compat:update()
end

function draw()
  compat:draw()
end
