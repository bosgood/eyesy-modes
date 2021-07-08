-- BarcodeScanline
--
-- knob1:
-- knob2:
-- knob3:
-- knob4:
-- knob5:

-- require("eyesy")
local gauss = require("gaussian")

-- Global constants
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
COLOR_WHITE = of.Color.fromHsb(61, 3, 235)
COEF_BAR_WIDTH = 30
COEF_MOVEMENT_WIGGLE = 0.75
COEF_MOVEMENT_SCROLL = 1

-- Mode state
Bars = {}
TranslateVec = glm.vec2(0, 0)

function setup()
  print("BarcodeScanline")

  -- Count the amount of screen real estate used already
  local usedWidth = 0

  -- Add bars until screen width exhausted
  while true do
    local width = math.abs(gauss.randomGaussian()) * COEF_BAR_WIDTH
    usedWidth = usedWidth + width
    -- Place bars in sequence one after another across the screen
    local bar = of.Rectangle(usedWidth, 0, width, H)
    table.insert(Bars, bar)

    -- Stop once all space has been filled
    if usedWidth >= W then
      break
    end
  end

  of.setBackgroundColor(COLOR_BLACK)
end

function update()
  -- Simulate TV out of sync by introducing random lateral movement
  local wiggle = COEF_MOVEMENT_WIGGLE * gauss.randomGaussian()
  for _, rect in ipairs(Bars) do
    rect.x = rect.x + wiggle
  end

  -- -- Scroll sideways
  -- TranslateVec = glm.vec2((TranslateVec.x + 1) * COEF_MOVEMENT_SCROLL, TranslateVec.y)
end

function draw()
  of.fill()
  of.setColor(COLOR_WHITE)

  for i, rect in ipairs(Bars) do
    -- Bar code coloring - skip bars matching bgcolor
    if i % 2 == 1 then
      of.drawRectangle(rect)
    end
  end
end
