local Particle = {
  rect = nil,
}

function Particle:new(o)
  local o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Particle:draw()
  of.drawRectangle(self.rect)
end

function Particle:isOffscreen()
  return
    -- self.rect.x + self.rect.width <= 0 or
    self.rect.x > of.getWidth() or
    -- self.rect.y + self.rect.height > 0 or
    self.rect.y > of.getHeight()
end

return Particle
