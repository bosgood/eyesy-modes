local Color = {}

function Color.map360(v)
  return of.map(v, 0, 360, 0, 255, true)
end

function Color.map100(v)
  return of.map(v, 0, 100, 0, 255, true)
end

return Color
