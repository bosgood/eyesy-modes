-- QuadtreeDots
-- Scattered shape renderer based on a quadtree pattern
--
-- knob1: dot render frequency
-- knob2:
-- knob3:
-- knob4:
-- knob5:

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

Time = 0
Dots = {}
CenterBias = 0.75
DotRenderFrequency = 10
NumDots = 50
Tree = Quadtree:new(glm.vec4(0, 0, 0, 0))
DotSize = 10

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
  Time = (Time + 1) % 1000
  local freq = knob1 * DotRenderFrequency

  if math.floor(Time % freq) == 0 then
    for i = 1, NumDots do
      local locX = gen.randomBias(0, W, W2, CenterBias)
      local locY = gen.randomBias(0, W, W2, CenterBias)
      Dots[i] = glm.vec4(locX, locY, DotSize, DotSize)
    end
  end
end

function draw()
  of.fill()
  of.setColor(255, 255, 255)
  for _, v in ipairs(Dots) do
    of.drawCircle(v.x, v.y, v.z)
  end

  -- Visualize a Quadtree grid over the scene
  of.noFill()
  of.setColor(255, 255, 255)
  local grid = createQtGrid{
    width = W - 5,
    height = H - 5,
    points = Dots,
    gap = 1
  }
  for _, area in ipairs(grid.areas) do
    of.drawRectangle(area.x, area.y, area.width, area.height)
  end
end
