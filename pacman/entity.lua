local physics = require("physics")

local Entity = {}
Entity.__index = {}

function Entity.new()
    local self = {}

    self.x = 0
    self.y = 0
    self.dir = 0
    self.radius = 8

    setmetatable(self, Entity)
    return self
end

function Entity:update(ctx)
    -- attempt movement
    local tx = self.x + physics.DIRECTIONS[self.dir * 2 - 1]
    local ty = self.y + physics.DIRECTIONS[self.dir * 2]

    -- move
    if not physics.collideCircleMaze(tx, ty, self.radius, ctx.maze) then
        self.x = tx
        self.y = ty
    end

    -- wrap
    if self.x < 0 then
        self.x = ctx.maze.width * 8 + self.x
    elseif self.x > ctx.maze.width * 8 then
        self.x = self.x - ctx.maze.width * 8
    end
end

function Entity:draw()
    error("Unimplemented")
end

return Entity
