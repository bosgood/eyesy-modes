-- New Mode

local compat = require("compat")

local function W()
    return of.getWidth()
end

local function W2()
    return of.getWidth() / 2
end

local function H()
    return of.getHeight()
end

local function H2()
    return of.getHeight() / 2
end

local function C()
    return glm.vec3(W2(), H2(), 0)
end

local config = {
    startStr = "arial",
    maxStrLen = 1000,
    audioScale = 2,
    drawX = 100,
    drawY = 100,
}

local state = {
    str = config.startStr,
}

local font = of.TrueTypeFont()

function setup()
    compat:setup()
    print("Arial")

    font:load("FiraCode-Light.ttf", 32)
end

function update()
    compat:update()

    -- Random ASCII characters to add to the string
    local rval = of.random(0, 255)
    local code = string.char(math.floor(rval))
    state.str = state.str .. code

    if #state.str % 100 == 0 then
        state.str = state.str .. "\n"
    end

    if #state.str > config.maxStrLen then
        state.str = config.startStr
    end
end

function draw()
    compat:draw()

    -- Modulate string draw location with audio data
    local audioVal = inC[#inC / 2]
    local ax = audioVal
    local ay = audioVal
    local ap = glm.vec2(ax, ay)
    local p = glm.vec2(config.drawX, config.drawY) + ap * config.audioScale

    font:drawString(state.str, p.x, p.y)
end
