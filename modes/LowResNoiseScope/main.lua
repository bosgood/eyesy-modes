require("eyesy")

-- LowResNoiseScope
-- low-resolution bar chart oscilloscope
--
-- knob1: scale of the effect the volume has on oscilloscope bar height
-- knob2: hue
-- knob3: acceleration of time
-- knob4: 2d Perlin noise location

NUM_SAMPLES = 256
w = of.getWidth()
h = of.getHeight()
w2 = w / 2
h2 = h / 2
w4 = w / 4
h4 = h / 4
c = glm.vec3(w2, h2, 0)
time = 0
AMPLITUDE = 1500
dir = 1

function setup()
    print("LowResNoiseScope")
end

function update()
end

function draw()
    scale = AMPLITUDE * knob1
    time = (time + (dir * knob3)) % 255
    if time == 0 then
        dir = dir * -1
    end
    barWidth = math.floor(w / NUM_SAMPLES)

    for i=1,NUM_SAMPLES do
        color = of.Color()
        noise = of.noise(i, knob4)
        color:setHsb(knob2 * 100 * noise, time, 255)
        amp = inL[i]
        if i % 2 == 0 then
            amp = inR[i]
        end
        drawSegment(i * barWidth, h2, barWidth, scale, color, amp)
    end
end

function drawSegment(x, y, width, scale, color, amp)
    of.setColor(color)
    of.beginShape()
        height = amp * scale
        of.drawRectangle(x, y, width, height * 0.55)
    of.endShape()
end
