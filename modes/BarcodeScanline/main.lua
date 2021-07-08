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
COEF_MOVEMENT_SCROLL = 0.10
COEF_TRANSLATE_VEC_BIAS = 0.25
COEF_PCT_CORRECT_BARS_OFFSCREEN = 0.25
COEF_SINE_INFLUENCE = 0.1
COEF_SINE_TRANSFORM = 0.25

-- Mode state
Bars = {}
TranslateVec = glm.vec2(0, 0)
BarIndex = 1
TranslateVecBias = glm.vec2(0, 0)
SinTransform = 0

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
  -- Scroll sideways
  TranslateVec = glm.vec2(
    (TranslateVec.x + 1) * COEF_MOVEMENT_SCROLL + TranslateVecBias.x,
    TranslateVec.y + TranslateVecBias.y
  )

  -- Keep track of the amount of bars offscreen so corrections can be made
  local numBarsOffscreenLeft = 0
  local numBarsOffscreenRight = 0

  for _, rect in ipairs(Bars) do
    -- Resize with screen height
    rect.height = of.getHeight()

    local wiggle = COEF_MOVEMENT_WIGGLE * gauss.randomGaussian()
    -- Simulate TV out of sync by introducing random lateral movement
    rect.x = rect.x + wiggle

    -- Slowly scroll across the screen
    rect:translate(TranslateVec)

    if rect.x < 0 then
      numBarsOffscreenLeft = numBarsOffscreenLeft + 1
    end
    if rect.x > of.getWidth() then
      numBarsOffscreenRight = numBarsOffscreenRight + 1
    end
  end

  -- Correct once a certain threshold has been passed
  if numBarsOffscreenLeft > (COEF_PCT_CORRECT_BARS_OFFSCREEN * #Bars) then
    TranslateVecBias = glm.vec2(COEF_TRANSLATE_VEC_BIAS, TranslateVecBias.y)
  elseif numBarsOffscreenRight > (COEF_PCT_CORRECT_BARS_OFFSCREEN * #Bars) then
    TranslateVecBias = glm.vec2(-COEF_TRANSLATE_VEC_BIAS, TranslateVecBias.y)
  end

  -- Reset correction once all bars back in view
  if numBarsOffscreenLeft == 0 and numBarsOffscreenRight == 0 then
    TranslateVecBias = glm.vec2(0, TranslateVecBias.y)
  end

  -- Let the sine wave effect be modulated by a monotonically increasing value
  SinTransform = SinTransform + COEF_SINE_TRANSFORM
end

-- Draws a barcode bar; can be either a rectangle or a wide sine wave
local function drawBar(i, rect)
  -- Bar code coloring - skip bars matching bgcolor
  if i % 2 == 0 then
    return
  end

  of.beginShape()
    -- of.drawRectangle(rect)

    local steps = rect.height / 3
    local step = rect.height / steps
    for x = 0, steps do
      local wavePoint = math.sin(x + SinTransform) * COEF_SINE_INFLUENCE * SinTransform
      local v1 = glm.vec2(rect.x + wavePoint, step * x)
      local v2 = glm.vec2(rect.x + wavePoint + rect.width, step * x)
      of.vertex(v1)
      of.vertex(v2)
    end
  of.endShape()
end

function draw()
  of.fill()
  of.setColor(COLOR_WHITE)

  for i, rect in ipairs(Bars) do
    drawBar(i, rect)
  end
end
