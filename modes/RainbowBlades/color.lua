local Color = {}

function Color.map360(v)
    return of.map(v, 0, 360, 0, 255, true)
end

function Color.map100(v)
    return of.map(v, 0, 100, 0, 255, true)
end

-- Gets the same color with a different hue value
function Color.withHue(color, hue)
    return of.Color.fromHsb(
        hue,
        color:getSaturation(),
        color:getBrightness()
    )
end

-- Gets the same color with a different saturation value
function Color.withSaturation(color, saturation)
    return of.Color.fromHsb(
        color:getHue(),
        saturation,
        color:getBrightness()
    )
end

-- Gets the same color with a different brightness value
function Color.withBrightness(color, brightness)
    return of.Color.fromHsb(
        color:getHue(),
        color:getSaturation(),
        brightness
    )
end

-- Gets the same color with a different alpha value
function Color.withAlpha(color, alpha)
    return of.Color.fromHsb(
        color:getHue(),
        color:getSaturation(),
        color:getBrightness(),
        alpha
    )
end

return Color
