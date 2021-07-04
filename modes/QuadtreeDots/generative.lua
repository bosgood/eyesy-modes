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

  local base = math.random(min * 100, max * 100) / 100
  local mix = (math.random(0, 100) / 100) * influence
  return base * (1 - mix) + bias * mix
end

-- Determines whether an event will happen, based on a given probability
-- @param {number} a probability percentage between 0 and 1
-- @return {bool} true if the event will happen
function Generative.willHappen(probability)
  local rand = math.random(0, 100) / 100
  return rand <= probability
end

return Generative
