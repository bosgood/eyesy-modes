-- RainbowSine
--
-- knob1:
-- knob2:
-- knob3:
-- knob4:
-- knob5: COEF_ROTATION_DEG

-- require("eyesy")
local color = require("color")

NUM_SAMPLES = 256
W = of.getWidth()
H = of.getHeight()
W2 = W / 2
H2 = H / 2
W4 = W / 4
H4 = H / 4
C = glm.vec3(W2, H2, 0)

-- Mode constants
COEF_BAR_WIDTH = 30
COEF_ROTATION_DEG = 0
COEF_NUM_BARS = 25
COEF_COLOR_SATURATION = 150
PALETTE = {
  of.Color.fromHsb(color.map360(360), color.map100(67), color.map100(98), COEF_COLOR_SATURATION),
  of.Color.fromHsb(color.map360(339), color.map100(68), color.map100(90), COEF_COLOR_SATURATION),
  of.Color.fromHsb(color.map360(288), color.map100(66), color.map100(86), COEF_COLOR_SATURATION),
  of.Color.fromHsb(color.map360(255), color.map100(67), color.map100(95), COEF_COLOR_SATURATION),
  of.Color.fromHsb(color.map360(228), color.map100(69), color.map100(96), COEF_COLOR_SATURATION),
  of.Color.fromHsb(color.map360(208), color.map100(85), color.map100(90), COEF_COLOR_SATURATION),
  of.Color.fromHsb(color.map360(188), color.map100(89), color.map100(75), COEF_COLOR_SATURATION),
  of.Color.fromHsb(color.map360(162), color.map100(90), color.map100(72), COEF_COLOR_SATURATION),
  of.Color.fromHsb(color.map360(131), color.map100(66), color.map100(75), COEF_COLOR_SATURATION),
  of.Color.fromHsb(color.map360(85), color.map100(85), color.map100(79), COEF_COLOR_SATURATION),
  of.Color.fromHsb(color.map360(42), color.map100(98), color.map100(98), COEF_COLOR_SATURATION),
  of.Color.fromHsb(color.map360(27), color.map100(92), color.map100(99), COEF_COLOR_SATURATION),
}

-- Mode state
Bars = {}

local function populateBars()
  for i = 0, COEF_NUM_BARS - 1 do
    local bar = {
      rect = of.Rectangle(i * COEF_BAR_WIDTH, 0, COEF_BAR_WIDTH, of.getHeight()),
      color = of.Color.fromHsb(61, 3, 235),
    }
    table.insert(Bars, bar)
  end
end

function setup()
  print("RainbowSine")
  populateBars()
end

function update()
  -- Repopulate bars if quantity is changed
  if #Bars ~= COEF_NUM_BARS then
    populateBars()
  end

  for i, bar in ipairs(Bars) do
    -- local lerpColor = of.lerp(0, 255, #Bars) * i
    -- bar.color:setHue(lerpColor)
    bar.color = PALETTE[(i % #PALETTE) + 1]
  end
end

function draw()
  of.pushMatrix()
    of.rotateDeg(COEF_ROTATION_DEG)
    for _, bar in ipairs(Bars) do
      of.setColor(bar.color)
      of.drawRectangle(bar.rect)
    end
  of.popMatrix()
end
