-- RainbowBlades
--
-- knob1:
-- knob2:
-- knob3:
-- knob4:
-- knob5: COEF_ROTATION_DEG

local compat = require("compat")
local color = require("color")
local lfo = require("lfo")

NUM_SAMPLES = 256
W = of.getWidth()
H = of.getHeight()
W2 = W / 2
H2 = H / 2
W4 = W / 4
H4 = H / 4
C = glm.vec3(W2, H2, 0)

-- Mode constants
COLOR_BLACK = of.Color.fromHsb(116, 0, 10)
COEF_BAR_WIDTH = 30
COEF_ROTATION_DEG = 45
COEF_NUM_BARS = 25
COEF_COLOR_SATURATION = 150
COEF_TIME_ACCELERATION = 15
COEF_SINE_SLICES = 15
COEF_SINE_SLICE_WIDTH = 5
COEF_BAR_OPACITY = 50
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
ColorRotate = 0
Time = 0
Acceleration = 10
SineLFO = lfo.sineGenerator(1000, 10)

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
  compat:setup()
  print("RainbowBlades")
  populateBars()
end

function update()
  compat:update()
  Time = Time + 1

  -- Repopulate bars if quantity is changed
  if #Bars ~= COEF_NUM_BARS then
    populateBars()
  end

  -- It's a sine of the times
  local accMod = COEF_TIME_ACCELERATION * math.sin(Time)
  Acceleration = math.floor(Acceleration + accMod)
  if Time % of.clamp(Acceleration, 10, 20) == 0 then
    ColorRotate = ColorRotate + 1
  end

  for i, bar in ipairs(Bars) do
    bar.rect.height = of.getHeight()
    bar.color = PALETTE[((i + ColorRotate) % #PALETTE) + 1]
  end
end

function draw()
  compat:draw()
  of.setBackgroundColor(COLOR_BLACK)
  of.pushMatrix()
    -- Skew entire canvas diagonally
    of.rotateDeg(COEF_ROTATION_DEG)
    of.translate(-of.getWidth() / 20, -of.getHeight() / 2)

    for _, bar in ipairs(Bars) do
      -- Bounding rectangles drawn behind in with opacity
      of.setColor(color.withAlpha(bar.color, COEF_BAR_OPACITY))
      of.drawRectRounded(
        of.Rectangle(
          bar.rect.x,
          bar.rect.y,
          of.clamp(
            (bar.rect.width / 3) + SineLFO(of.getElapsedTimeMillis()),
            0,
            bar.rect.width * 0.5
          ),
          bar.rect.height
        ),
        10
      )

      -- Sharp-edged dagger shapes drawn as paths over rectangles
      local path = of.Path()
      path:moveTo(bar.rect.x, bar.rect.y)
      path:setColor(bar.color)
      path:setFillColor(bar.color)
      path:setFilled(true)

      for j = 1, COEF_SINE_SLICES do
        local to = glm.vec2(
          bar.rect.x + SineLFO(of.getElapsedTimeMillis()),
          (bar.rect.height / COEF_SINE_SLICES) * j
        )
        path:curveTo(to)
      end

      path:close()
      path:draw()
    end
  of.popMatrix()
end
