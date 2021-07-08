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

-- Mode state
Bars = {}
TranslateVec = glm.vec2(0, 0)
BarIndex = 1
TranslateVecBias = glm.vec2(0, 0)

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
    local wiggle = COEF_MOVEMENT_WIGGLE * gauss.randomGaussian()
    -- Simulate TV out of sync by introducing random lateral movement
    rect.x = rect.x + wiggle

    -- Slowly scroll across the screen
    rect:translate(TranslateVec)

    if rect.x < 0 then
      numBarsOffscreenLeft = numBarsOffscreenLeft + 1
    end
    if rect.x > W then
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

  -- -- As the bars move offscreen, cycle the render start index
  -- if Bars[#Bars].x > W then
  --   BarIndex = (BarIndex % #Bars) + 1
  -- end
end

local function drawBar(i, rect)
  -- Bar code coloring - skip bars matching bgcolor
  if i % 2 == 1 then
    of.drawRectangle(rect)
  end
end

function draw()
  of.fill()
  of.setColor(COLOR_WHITE)

  -- Allow render to start at arbitrary index in table
  for i = BarIndex, #Bars do
    local rect = Bars[i]
    drawBar(i, rect)
  end
  -- But then loop around to paint the beginning afterwards
  if BarIndex > 1 then
    for i = 1, BarIndex-1 do
      local rect = Bars[i]
      drawBar(i, rect)
    end
  end
end
