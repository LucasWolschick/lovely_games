local Entity = require("entity")
local physics = require("physics")

local Monster = {}
Monster.__index = Monster
setmetatable(Monster, Entity)

Monster.BLINKY = 1
Monster.INKY = 2
Monster.PINKY = 3
Monster.CLYDE = 4

Monster.CHASE = "chase"
Monster.SCATTER = "scatter"
Monster.AFRAID = "afraid"
Monster.EATEN = "eaten"

function Monster.new(x, y, dir, ai)
    local self = Entity.new()

    self.x = x
    self.y = y
    self.dir = dir

    self.ai = ai
    self.mode = Monster.SCATTER

    setmetatable(self, Monster)
    return self
end

function Monster:update(ctx)
    if self.mode == Monster.SCATTER or self.mode == Monster.CHASE then
        local m = ctx.timers(ctx.frame / 60)
        if m ~= self.mode then
            self.dir = (self.dir - 1 + 2) % 4 + 1
            self.mode = m
        end
    end

    local directions = {}

    -- find target position
    local tx, ty = 0, 0
    if self.ai == Monster.BLINKY then
        if self.mode == Monster.SCATTER then
            -- target is upper right corner
            tx = ctx.maze.width * 8
            ty = 0
        elseif self.mode == Monster.CHASE then
            -- target is player pos
            tx = ctx.pacman.x
            ty = ctx.pacman.y
        end
    elseif self.ai == Monster.INKY then
        if self.mode == Monster.SCATTER then
            -- target is lower right corner
            tx = ctx.maze.width * 8
            ty = ctx.maze.height * 8
        elseif self.mode == Monster.CHASE then
            -- It = Inky target
            -- Bp = Blinky position
            -- Pt = Pinky target
            -- It = Bp + (Bp - Pt) * 2

            local bpx, bpy = ctx.monsters[Monster.BLINKY].x, ctx.monsters[Monster.BLINKY].y
            local ptx = ctx.pacman.x + physics.DIRECTIONS[2 * ctx.pacman.dir] * 16
            local pty = ctx.pacman.y + physics.DIRECTIONS[2 * ctx.pacman.dir - 1] * 16
            local dx, dy = (ptx - bpx) * 2, (pty - bpy) * 2

            tx, ty = bpx + dx, bpy + dy
        end
    elseif self.ai == Monster.PINKY then
        if self.mode == Monster.SCATTER then
            -- target is upper left corner
            tx = 0
            ty = 0
        elseif self.mode == Monster.CHASE then
            -- target is two pac-dots in front of pacman
            tx = ctx.pacman.x + physics.DIRECTIONS[2 * ctx.pacman.dir] * 16
            ty = ctx.pacman.y + physics.DIRECTIONS[2 * ctx.pacman.dir - 1] * 16
        end
    elseif self.ai == Monster.CLYDE then
        if self.mode == Monster.SCATTER then
            -- target is upper left corner
            tx = 0
            ty = ctx.maze.height * 8
        elseif self.mode == Monster.CHASE then
            -- target is pacman except if near pacman, in which case is his corner
            local dist = physics.distance(ctx.pacman.x, ctx.pacman.y, self.x, self.y)
            if dist < 64 then
                -- flee
                tx = 0
                ty = ctx.maze.height * 8
            else
                -- zap
                tx = ctx.pacman.x
                ty = ctx.pacman.y
            end
        end
    end

    -- get possible directions
    for d = 1, 4 do
        if (self.dir + 2 - 1) % 4 + 1 ~= d then
            local dx, dy = physics.DIRECTIONS[d * 2 - 1], physics.DIRECTIONS[d * 2]

            -- attempt change
            local testx = self.x + dx
            local testy = self.y + dy

            -- move
            if not physics.collideCircleMaze(testx, testy, 8, ctx.maze) then
                table.insert(directions, { dir = d, x = testx, y = testy })
            end
        end
    end

    if #directions > 0 then
        local closest, closestDist = directions[1].dir, math.huge

        -- pick closest
        for _, dir in pairs(directions) do
            local dist = physics.distance(dir.x, dir.y, tx, ty)
            if dist < closestDist then
                closestDist = dist
                closest = dir.dir
            end
        end

        self.dir = closest
    end

    Entity.update(self, ctx)
end

function Monster:draw(r)
    local colors = {
        { 1, 0,         0, 1 }, -- blinky
        { 0, 1,         1, 1 }, -- inky
        { 1, 0,         1, 1 }, -- pinky
        { 1, 140 / 255, 0, 1 }, -- clyde
    }
    love.graphics.setColor(colors[self.ai])

    -- circly top
    local cx, cy = self.x / 8 * r, self.y / 8 * r
    local dx, dy = physics.DIRECTIONS[self.dir * 2 - 1], physics.DIRECTIONS[self.dir * 2]
    r = r * 0.8
    love.graphics.circle(
        "fill",
        cx,
        cy,
        r
    )
    -- rectangle
    love.graphics.rectangle("fill", cx - r, cy, r * 2, r)

    -- sclera
    love.graphics.setColor(1, 1, 1)
    love.graphics.circle("fill", cx + (-1 / 3 + dx * 1 / 3) * r, cy + (dy * 1 / 3) * r, 1 / 3 * r) -- l
    love.graphics.circle("fill", cx + (1 / 3 + dx * 1 / 3) * r, cy + (dy * 1 / 3) * r, 1 / 3 * r)  -- r

    -- pupils
    love.graphics.setColor(0, 0, 1)
    love.graphics.circle("fill", cx + (-1 / 3 + dx * 1 / 2) * r, cy + (dy * 1 / 2) * r, 1 / 4 * r) -- l
    love.graphics.circle("fill", cx + (1 / 3 + dx * 1 / 2) * r, cy + (dy * 1 / 2) * r, 1 / 4 * r)  -- r
end

return Monster
