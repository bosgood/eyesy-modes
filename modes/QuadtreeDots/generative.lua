local Generative = {}

-- function randomBias(min, max, bias, influence = 0.5) {
--     const base = random(min, max);
--     const mix = random(0, 1) * influence;
--     return base * (1 - mix) + bias * mix;
--   }

-- Generates random numbers with a bias towards a specific value
-- min: minimum value to generate
-- max: maximum value to generate
-- bias: skew generated values towards this value, must be between min and max
-- influence: (default: 0.5) amount to skew towards bias value
function Generative.randomBias(min, max, bias, influence)
  if influence == nil then
    influence = 0.5
  end

  local base = math.random(min, max)
  local mix = math.random(0, 1) * influence
  return base * (1 - mix) + bias * mix
end

return Generative
