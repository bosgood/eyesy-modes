-- Cross-platform compatibility library for EYESY modes to run on a desktop computer as well,
-- via Loaf, a standalone ofxLua application for live coding.
-- The API is designed to mimic that of the EYESY.
-- Implemented:
--   * knob[1-5] - set to the mapped 0-1 value of incoming MIDI CCs 20-24
-- Not implemented:
--   * trig (defined but always false)
--   * inL, inR (defined but initialized to zeroes)
--
-- https://www.critterandguitari.com/eyesy
-- https://github.com/danomatika/loaf

-- Usage:
--   -- In your program's header:
--   local compat = require("compat")
--   -- In your program's setup function:
--   compat:setup()
--   -- In your program's update function:
--   compat:update()
--   -- In your program's draw function:
--   compat:draw()

-- Define global parameters that the EYESY also defines
local function defineGlobals()
  knob1 = 0.5
  knob2 = 0.5
  knob3 = 0.5
  knob4 = 0.5
  knob5 = 0.5
  inL = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
  inR = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
  -- C is the center channel, aka the average of L/R
  inC = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
  bgColor = {255,100,0}
  trig = false
end

local on_eyesy = pcall(require, "eyesy")
if on_eyesy then
  EYESY = true
  LOAF = false
else
  EYESY = false
  LOAF = true
  defineGlobals()
end
local gauss = require("gaussian")

local Compatibility = {
  oscReceiver = nil,
  -- Listen on same port as ofEYESY itself by default
  port = 4000,
  -- Used to measure progress of time-based functions
  tick = 0,
}

-- Initialize OSC listener
function Compatibility:setup()
  if LOAF then
    of.setWindowShape(800, 600)
    of.setBackgroundColor(of.Color.fromHsb(bgColor[1], bgColor[2], bgColor[3]))
    local rec = osc.Receiver()
    rec:setup(self.port)
    self.oscReceiver = rec
  end
end

-- Processes OSC messages to affect global parameter state
local function processOscMessage(m)
  -- Unpack 4-byte midi message
  local midi = m:getArgAsMidiMessage(0)

  local a = midi & 0xFF
  local b = (midi >> 8) & 0xFF
  local c = (midi >> 16) & 0xFF
  local d = (midi >> 24) & 0xFF
  print(string.format("midi: %s %s %s %s", a, b, c, d))

  local ccVal = a
  local ccId = b
  local ccType = c

  -- Only process CC messages for now
  if ccType == 176 then
    -- MIDI CC 20
    if ccId == 32 then
      knob1 = of.map(ccVal, 0, 127, 0, 1)
    -- MIDI CC 21
  elseif ccId == 33 then
    knob2 = of.map(ccVal, 0, 127, 0, 1)
    -- MIDI CC 22
  elseif ccId == 34 then
    knob3 = of.map(ccVal, 0, 127, 0, 1)
    -- MIDI CC 23
  elseif ccId == 35 then
    knob4 = of.map(ccVal, 0, 127, 0, 1)
    -- MIDI CC 24
    elseif ccId == 36 then
      knob5 = of.map(ccVal, 0, 127, 0, 1)
    end
  end
end

function Compatibility:update()
  if LOAF then
    -- Handle any pending OSC messages
    while self.oscReceiver:hasWaitingMessages() do
      local m = osc.Message()
      self.oscReceiver:getNextMessage(m)
      processOscMessage(self, m)
    end

    -- Render gaussian noise into audio buffer to simulate sound
    -- if self.tick > #gauss.values then
    --   self.tick = 0
    -- end
    for i, _ in ipairs(inL) do
      local val = gauss.randomGaussian() * 0.05
      inL[i] = val
      inR[i] = val
    end
  end

  -- Average L/R audio channels to provide center channel
  for i = 1, #inL do
    local val = (inL[i] + inR[i]) / 2
    inC[i] = val
  end
end

function Compatibility:draw()
end

return Compatibility
