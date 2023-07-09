local Pill = {}
Pill.__index = Pill

function Pill.new(x, y, super)
    local self = {}

    self.x = x
    self.y = y
    self.alive = true
    self.super = not not super

    setmetatable(self, Pill)
    return self
end

function Pill:draw(scale)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.circle("fill", self.x * scale, self.y * scale, scale / 20 * 2)
end

return Pill
