local LFO = {}

-- Creates a LFO sin wave generator function
-- @param {number} the period of the wave in milliseconds
-- @param {number} the maximum amplitude of the wave (absolute value)
-- @param {number} (optional) the value to start the wave at
function LFO.sine(periodMs, amplitude, startVal)
  -- local value = 0
  -- if startVal ~= nil then
  --   value = startVal
  -- end

  -- Store state by closing over the value
  return function(elapsedMs)
    return of.clamp(
      math.sin(elapsedMs / periodMs) * amplitude,
      -amplitude,
      amplitude
    )
  end
end

return LFO
