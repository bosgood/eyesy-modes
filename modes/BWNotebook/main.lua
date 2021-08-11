-- BWNotebook
-- Flecked pattern reminiscent of a black and white notebook

-- require("eyesy")
local gauss = require("gaussian")
local Particle = require("particle")

NUM_SAMPLES = 256
W = of.getWidth()
H = of.getHeight()
W2 = W / 2
H2 = H / 2
W4 = W / 4
H4 = H / 4
C = glm.vec3(W2, H2, 0)

-- Mode constants
COEF_NUM_PARTICLES = 1000
COEF_GAUSS_SCALE = 1
COEF_PARTICLE_SIZE = 10

-- Mode state
Rot = 0
Particles = {}

function particleRect()
  return of.Rectangle(
    of.getWidth() / 2,
    of.getHeight() / 2,
    COEF_PARTICLE_SIZE,
    COEF_PARTICLE_SIZE
  )
end

function setup()
  print("BWNotebook")

  for _ = 1, COEF_NUM_PARTICLES do
    table.insert(Particles, Particle:new({
      rect = particleRect(),
    }))
  end
end

function update()
  Rot = (Rot + 1) % 350

  local offscreen = {}
  for i, particle in ipairs(Particles) do
    particle.rect.x = particle.rect.x + (gauss.randomGaussian() * COEF_GAUSS_SCALE)
    particle.rect.y = particle.rect.y + (gauss.randomGaussian() * COEF_GAUSS_SCALE)

    -- Mark offscreen particles for collection
    if particle:isOffscreen() then
      table.insert(offscreen, i)
      print(string.format("(%f, %f, %f, %f)", particle.rect.x, particle.rect.y, particle.rect.width, particle.rect.height))
    end
  end

  -- Recycle any offscreen particles
  for _, i in ipairs(offscreen) do
    table.remove(Particles, i)
    table.insert(Particles, Particle:new({
      rect = particleRect(),
    }))
  end
end

function draw()
  of.pushMatrix()
    -- of.translate(Rot, Rot, Rot)
    -- of.rotateDeg(Rot)
    for _, particle in ipairs(Particles) do
      particle:draw()
    end
  of.popMatrix()
end
