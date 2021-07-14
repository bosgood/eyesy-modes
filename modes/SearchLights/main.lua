-- SearchLights
--

-- require("eyesy")
local lfo = require("lfo")

-- Mode constants
NUM_SAMPLES = 256
W = of.getWidth()
H = of.getHeight()
W2 = W / 2
H2 = H / 2
W4 = W / 4
H4 = H / 4
C = glm.vec3(W2, H2, 0)

COEF_PATH_SLICES = 2048

-- Mode states
SineLFO = lfo.sineGenerator(1000, 1000)

function setup()
  print("SearchLights")
end

function update()
end

local function drawWeird(color, oscillator, startPoint, endPoint)
  local path = of.Path()
  path:moveTo(startPoint.x, startPoint.y)
  path:setColor(color)
  path:setFillColor(color)
  path:setFilled(true)

  for i = 1, COEF_PATH_SLICES do
    local val = oscillator()
    local to = glm.vec2(
      ((endPoint.x - startPoint.x) / COEF_PATH_SLICES * i) - 1,
      val
    )
    path:curveTo(to)
  end

  path:close()
  path:draw()
end

function draw()
  drawWeird(
    of.Color(255, 255, 255),
    SineLFO,
    glm.vec2(0, of.getHeight() / 2),
    glm.vec2(of.getWidth(), -1)
  )

  drawWeird(
    of.Color(100, 100, 100, 100),
    SineLFO,
    glm.vec2(of.getHeight() / 2, 0),
    glm.vec2(of.getWidth(), -1)
  )
end
