local compat = require("compat")

-- LowResNoiseScope
-- low-resolution bar chart oscilloscope
--
-- knob1: scale of the effect the volume has on oscilloscope bar height
-- knob2: hue
-- knob3: acceleration of time
-- knob4: 2d Perlin noise location

NUM_SAMPLES = 256
AMPLITUDE = 1500
time = 0
dir = 1

function setup()
  compat:setup()
  print("LowResNoiseScope")
end

function update()
  compat:update()
end

local function drawSegment(x, y, width, scale, color, amp)
  of.setColor(color)
  of.beginShape()
    local height = amp * scale
    of.drawRectangle(x, y, width, height * 0.55)
  of.endShape()
end

function draw()
  compat:draw()
  local scale = AMPLITUDE * knob1
  time = (time + (dir * knob3)) % 255
  if time == 0 then
    dir = dir * -1
  end
  local barWidth = math.floor(of.getWidth() / NUM_SAMPLES)

  for i=1,NUM_SAMPLES do
    local color = of.Color()
    local noise = of.noise(i, knob4)
    color:setHsb(knob2 * 100 * noise, time, 255)
    local amp = inC[i]
    if i % 2 == 0 then
      amp = inC[i]
    end
    drawSegment(i * barWidth, of.getHeight() / 2, barWidth, scale, color, amp)
  end
end
