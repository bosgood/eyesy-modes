local LFO = {}

-- LFO sin wave function
-- @param {number} the period of the wave in milliseconds
-- @param {number} the maximum amplitude of the wave (absolute value)
-- @param {number} (optional) the value to start the wave at
function LFO.sine(periodMs, amplitude, elapsedMs)
  return of.clamp(
    math.sin(elapsedMs / periodMs) * amplitude,
    -amplitude,
    amplitude
  )
end

-- Creates a LFO sin wave generator function
-- @param {number} the period of the wave in milliseconds
-- @param {number} the maximum amplitude of the wave (absolute value)
-- @param {number} (optional) the value to start the wave at
function LFO.sineGenerator(periodMs, amplitude)
  return function(elapsedMs)
    return LFO.sine(periodMs, amplitude, elapsedMs)
  end
end

return LFO
