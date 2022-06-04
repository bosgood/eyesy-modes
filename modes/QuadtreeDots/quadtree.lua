-- Quadtree implementation
-- ported from Javascript:
-- https://github.com/timohausmann/quadtree-js/tree/v1.2.1

local Quadtree = {
    maxObjects = 10,
    maxLevels = 4,
    level = 0,
}

-- Construct a new Quadtree
-- @param {glm.vec4} rectangle bounds
-- @param {number?} maximum objects in tree
-- @param {number?} maximum levels in tree
-- @param {number?} current depth level
function Quadtree:new(bounds, maxObjects, maxLevels, level)
    local o = {
        objects = {},
        nodes = {},
    }
    setmetatable(o, self)
    self.__index = self

    o.bounds = bounds
    if maxObjects ~= nil then
        o.maxObjects = maxObjects
    end
    if maxLevels ~= nil then
        o.maxLevels = maxLevels
    end
    if level ~= nil then
        o.level = level
    end

    return o
end

-- Splits the node into 4 subnodes
function Quadtree:split()
    local nextLevel = self.level + 1
    local subWidth = self.bounds.z / 2
    local subHeight = self.bounds.w / 2
    local x = self.bounds.x
    local y = self.bounds.y

    -- top right node
    self.nodes[1] = Quadtree:new(glm.vec4(x + subWidth, y, subWidth, subHeight), self.maxObjects, self.maxLevels, nextLevel)

    -- top left node
    self.nodes[2] = Quadtree:new(glm.vec4(x, y, subWidth, subHeight), self.maxObjects, self.maxLevels, nextLevel)

    -- bottom left node
    self.nodes[3] = Quadtree:new(glm.vec4(x, y + subHeight, subWidth, subHeight), self.maxObjects, self.maxLevels, nextLevel)

    -- bottom right node
    self.nodes[4] = Quadtree:new(glm.vec4(x + subWidth, y + subHeight, subWidth, subHeight), self.maxObjects, self.maxLevels, nextLevel)
end

-- Determine which node the given object belongs to
-- @param {glm.vec4} bounds of the area to be checked
-- @return {list<number>} array of indexes of the intersecting subnodes
function Quadtree:getIndex(area)
    local indexes = {}
    local verticalMidpoint = self.bounds.x + (self.bounds.z / 2)
    local horizontalMidpoint = self.bounds.y + (self.bounds.w / 2)

    local startIsNorth = area.y < horizontalMidpoint
    local startIsWest = area.x < verticalMidpoint
    local endIsEast = area.x + area.z > verticalMidpoint
    local endIsSouth = area.y + area.w > horizontalMidpoint

    -- top-right quad
    if startIsNorth and endIsEast then
        table.insert(indexes, 1)
    end

    -- top-left quad
    if startIsWest and endIsSouth then
        table.insert(indexes, 2)
    end

    -- bottom-left quad
    if startIsWest and endIsSouth then
        table.insert(indexes, 3)
    end

    -- bottom-rigth quad
    if endIsEast and endIsSouth then
        table.insert(indexes, 4)
    end

    return indexes
end

-- Inserts the object into the node. If the node exceeds the capacity,
-- it will split and add all objects to their corresponding subnodes.
-- @param {glm.vec4} bounds of the object to be added
function Quadtree:insert(area)
    -- If there exist subnodes, insert on matching subnodes
    if #self.nodes > 0 then
        local indexes = self:getIndex(area)
        for _, idx in ipairs(indexes) do
            self.nodes[idx]:insert(area)
        end
        return
    end

    -- Otherwise, store the object here
    table.insert(self.objects, area)

    -- maxObjects reached but not maxLevels
    if #self.objects > self.maxObjects and self.level < self.maxLevels then
        -- Only split if subnodes don't already exist
        if #self.nodes == 0 then
            self:split()
        end

        -- Add all objects to their corresponding subnode
        for _, obj in ipairs(self.objects) do
            local indexes = self:getIndex(obj)
            for _, idx in ipairs(indexes) do
                table.insert(self.nodes[idx], obj)
            end
        end

        -- Clean up this node
        self.objects = {}
    end
end

-- Finds all objects that collide with the given area
-- @param {glm.vec4} bounds of the object to be checked
-- @return {list<glm.vec4>} array with all detected objects
function Quadtree:retrieve(area)
    local indexes = self:getIndex(area)
    local foundObjs = self.objects

    -- If subnodes exist, retrieve their objects
    if #self.nodes > 0 then
        for _, idx in ipairs(indexes) do
            local objs = indexes[idx]:retrieve(area)
            local allObjs = {}
            for _, obj in ipairs(foundObjs) do
                table.insert(allObjs, obj)
            end
            for _, obj in ipairs(objs) do
                table.insert(allObjs, obj)
            end

            foundObjs = allObjs
        end
    end

    -- Remove duplicates
    local seen = {}
    local uniqueObjs = {}
    for _, obj in ipairs(foundObjs) do
        local id = string.format("(%d,%d,%d,%d)", obj.x, obj.y, obj.z, obj.w)
        if seen[id] == nil then
            seen[id] = obj
            table.insert(uniqueObjs, obj)
        end
    end

    return uniqueObjs
end

-- Clears the tree
function Quadtree:clear()
    self.objects = {}
    for _, node in ipairs(self.nodes) do
        node:clear()
    end
    self.nodes = {}
end

return Quadtree
