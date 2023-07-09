local Entity = require("entity")
local physics = require("physics")

local Pacman = {}
Pacman.__index = Pacman
setmetatable(Pacman, Entity)

function Pacman.new(x, y, dir)
    local self = Entity.new()

    self.x = x
    self.y = y
    self.dir = dir

    self.dir_intent = dir
    self.dir_intent_timer = 0
    self.anim = 0

    setmetatable(self, Pacman)
    return self
end

function Pacman:update(ctx)
    if love.keyboard.isDown("left") then
        self.dir_intent = 3
        self.dir_intent_timer = 8
    end

    if love.keyboard.isDown("right") then
        self.dir_intent = 1
        self.dir_intent_timer = 8
    end

    if love.keyboard.isDown("up") then
        self.dir_intent = 4
        self.dir_intent_timer = 8
    end

    if love.keyboard.isDown("down") then
        self.dir_intent = 2
        self.dir_intent_timer = 8
    end

    if self.dir_intent_timer > 0 then
        -- attempt change
        local tx = self.x + physics.DIRECTIONS[self.dir_intent * 2 - 1]
        local ty = self.y + physics.DIRECTIONS[self.dir_intent * 2]

        -- move
        if not physics.collideCircleMaze(tx, ty, 8, ctx.maze) then
            self.dir = self.dir_intent
        end
    end

    self.dir_intent_timer = math.max(self.dir_intent_timer - 1, 0)

    local x, y = self.x, self.y
    Entity.update(self, ctx)
    if x ~= self.x or y ~= self.y then
        self.anim = (self.anim + 1) % 12
    end
end

function Pacman:draw(scale)
    love.graphics.setColor(1, 1, 0)
    local progress = self.anim / 12
    local amt = -math.abs(2 * progress - 1) + 1
    local theta = math.rad((self.dir - 1) * 90)
    love.graphics.arc(
        "fill",
        self.x / 8 * scale,
        self.y / 8 * scale,
        0.8 * scale,
        theta + amt * math.rad(45),
        theta + 2 * math.pi - amt * math.rad(45)
    )
    love.graphics.setColor(1, 1, 1)
end

return Pacman
