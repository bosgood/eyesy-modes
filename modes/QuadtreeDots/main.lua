-- QuadtreeDots
-- Scattered shape renderer based on a quadtree pattern
--
-- knob1: dot render probability
-- knob2: dot bias towards center
-- knob3: dot count
-- knob4: audio amplitude effect on circle scale
-- knob5: limits audio jump range

-- Code heavily inspired by and ported from Javascript at:
-- https://github.com/georgedoescode/generative-utils/blob/master/src/createQtGrid.js

require("eyesy")
local gen = require("generative")
local Quadtree = require("quadtree")

NUM_SAMPLES = 256
W = of.getWidth()
H = of.getHeight()
W2 = W / 2
H2 = H / 2
W4 = W / 4
H4 = H / 4
C = glm.vec3(W2, H2, 0)

Time1 = 0
Time2 = 0
Dots = {}
CenterBias = 1
NumDots = 100
DotSize = 10
Grid = nil
LastAmplitude = 0
MaxRange = 0.0005

local function getGridArea(bounds, colSize, rowSize)
  return {
    col = {
      start = bounds.x / colSize,
      fin = (bounds.x + bounds.z) / colSize,
    },
    row = {
      start = bounds.y / rowSize,
      fin = (bounds.y + bounds.w) / rowSize,
    },
  }
end

local function getIndividualQtNodes(root)
  local individualNodes = {}

  local function getIndividualQtNodesInner(node)
    if #node.nodes == 0 then
      table.insert(individualNodes, node)
    else
      for _, n in ipairs(node.nodes) do
        getIndividualQtNodesInner(n)
      end
    end
  end
  getIndividualQtNodesInner(root)

  return individualNodes
end

local function createQtGrid(override)
  local opts = {
    width = W,
    height = H,
    points = {},
    gap = 0,
    maxQtObjects = 4,
    maxQtLevels = 10,
  }

  for k, v in pairs(override) do
    opts[k] = v
  end

  -- Instantiate and populate Quadtree with points
  local qt = Quadtree:new(glm.vec4(0, 0, opts.width, opts.height), opts.maxQtObjects, opts.maxQtLevels)
  for _, v in ipairs(opts.points) do
    qt:insert(v)
  end

  local maxSubdivisions = opts.maxQtLevels ^ 2
  local colSize = opts.width / maxSubdivisions
  local rowSize = opts.height / maxSubdivisions

  local areas = {}
  local nodes = getIndividualQtNodes(qt)
  for _, node in ipairs(nodes) do
    local gridArea = getGridArea(node.bounds, colSize, rowSize)
    table.insert(areas, {
      x = node.bounds.x + opts.gap,
      y = node.bounds.y + opts.gap,
      width = node.bounds.z - opts.gap * 2,
      height = node.bounds.w - opts.gap * 2,
      col = gridArea.col,
      row = gridArea.row,
    })
  end

  return {
    width = opts.width,
    height = opts.height,
    cols = maxSubdivisions,
    rows = maxSubdivisions,
    areas = areas,
  }
end

function setup()
  print("QuadtreeDots")
end

function update()
  Time1 = (Time1 + 1) % 360
  Time2 = (Time2 + 1) % 255

  -- Always force a refresh after dots updated, otherwise
  -- there is a delay where the screen is blank until
  -- the next probabilistic event
  local numDotsUpdated = false
  local numDots = math.floor(NumDots * knob3)
  if #Dots ~= numDots then
    Dots = {}
    numDotsUpdated = true
  end

  -- Update dot location probabilistically
  local refreshProbability = knob1
  if numDotsUpdated or gen.willHappen(refreshProbability) then
    for i = 1, numDots do
      local calcCenterBias = CenterBias * knob2
      local locX = gen.randomBias(0, W, W2, calcCenterBias)
      local locY = gen.randomBias(0, W, W2, calcCenterBias)
      Dots[i] = glm.vec4(locX, locY, DotSize, DotSize)
    end
  end

  Grid = createQtGrid{
    width = W,
    height = H,
    points = Dots,
    gap = 1
  }

  -- Allow amplitude to seek towards actual value but
  -- prevent large jumps
  local actualAmplitude = gen.averageAmplitude()
  local allowedRange = MaxRange * knob5
  local ampDifference = math.abs(math.abs(actualAmplitude) - math.abs(LastAmplitude))

  if actualAmplitude > LastAmplitude then
    LastAmplitude = math.min(LastAmplitude + allowedRange, actualAmplitude)
  else
    LastAmplitude = math.max(LastAmplitude - allowedRange, actualAmplitude)
  end
end

function draw()
  -- -- Draw scatterplot dots
  -- of.fill()
  -- of.setColor(255, 255, 255)
  -- for _, v in ipairs(Dots) do
  --   of.drawCircle(v.x, v.y, v.z)
  -- end

  -- Visualize a Quadtree grid over the scene
  of.noFill()
  of.setColor(255, 255, 255, math.sin(gen.toRadians(Time1)) * 100)
  for _, area in ipairs(Grid.areas) do
    of.drawRectangle(area.x, area.y, area.width, area.height)
  end

  -- Render circles on the active quadtree nodes
  of.fill()
  of.setColor(of.Color.fromHsb(Time2, 255, 255, 50))
  for _, area in ipairs(Grid.areas) do
    local rad = area.width * (math.abs(LastAmplitude) * knob4 * 500)
    of.drawCircle(area.x - rad, area.y - rad, rad)
  end
end
