local Generative = {}

-- Generates random numbers with a bias towards a specific value
-- @param {number} minimum value to generate
-- @param {number} maximum value to generate
-- @param {number} skew generated values towards this value, must be between min and max
-- @param {number} (default: 0.5) amount to skew towards bias value
-- @return {number} a random number with bias
function Generative.randomBias(min, max, bias, influence)
  if influence == nil then
    influence = 0.5
  end

  local base = of.random(min, max)
  local mix = (of.random(1)) * influence
  return base * (1 - mix) + bias * mix
end

-- Determines whether an event will happen, based on a given probability
-- @param {number} a probability percentage between 0 and 1
-- @return {bool} true if the event will happen
function Generative.willHappen(probability)
  local rand = math.random(0, 100)
  return rand <= (probability * 100)
end

-- Gets the current average audio amplitude
function Generative.averageAmplitude()
  local sum = 0
  for _, amp in ipairs(inL) do
    sum = sum + amp
  end
  return sum / #inL
end

-- Converts radians to degrees
function Generative.toDegrees(radians)
  return radians * (180/math.pi)
end

-- Converts degrees to radians
function Generative.toRadians(degrees)
  return degrees * (math.pi/180)
end

return Generative
