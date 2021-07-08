-- RainbowSine
--
-- knob1:
-- knob2:
-- knob3:
-- knob4:
-- knob5: COEF_ROTATION_DEG

-- require("eyesy")

NUM_SAMPLES = 256
W = of.getWidth()
H = of.getHeight()
W2 = W / 2
H2 = H / 2
W4 = W / 4
H4 = H / 4
C = glm.vec3(W2, H2, 0)

local function map360(v)
  return of.map(v, 0, 360, 0, 255, true)
end

local function map100(v)
  return of.map(v, 0, 100, 0, 255, true)
end

-- Mode constants
COEF_BAR_WIDTH = 30
COEF_ROTATION_DEG = 0
COEF_NUM_BARS = 25
COEF_COLOR_SATURATION = 150
PALETTE = {
  of.Color.fromHsb(map360(360), map100(67), map100(98), COEF_COLOR_SATURATION),
  of.Color.fromHsb(map360(339), map100(68), map100(90), COEF_COLOR_SATURATION),
  of.Color.fromHsb(map360(288), map100(66), map100(86), COEF_COLOR_SATURATION),
  of.Color.fromHsb(map360(255), map100(67), map100(95), COEF_COLOR_SATURATION),
  of.Color.fromHsb(map360(228), map100(69), map100(96), COEF_COLOR_SATURATION),
  of.Color.fromHsb(map360(208), map100(85), map100(90), COEF_COLOR_SATURATION),
  of.Color.fromHsb(map360(188), map100(89), map100(75), COEF_COLOR_SATURATION),
  of.Color.fromHsb(map360(162), map100(90), map100(72), COEF_COLOR_SATURATION),
  of.Color.fromHsb(map360(131), map100(66), map100(75), COEF_COLOR_SATURATION),
  of.Color.fromHsb(map360(85), map100(85), map100(79), COEF_COLOR_SATURATION),
  of.Color.fromHsb(map360(42), map100(98), map100(98), COEF_COLOR_SATURATION),
  of.Color.fromHsb(map360(27), map100(92), map100(99), COEF_COLOR_SATURATION),
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
