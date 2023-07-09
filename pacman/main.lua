local Maze    = require("maze")
local Pacman  = require("pacman")
local Monster = require("monster")
local timers  = require("timers")

local state   = {}

function love.load()
    state.frame = 0
    state.maze = Maze.new()
    state.pacman = Pacman.new(16, 16, 1)
    state.monsters = {}
    for _, ai in ipairs({ Monster.BLINKY, Monster.INKY, Monster.PINKY, Monster.CLYDE }) do
        state.monsters[ai] = Monster.new(16, 16, 1, ai)
    end
    state.anim = 0 -- 0 thru 8
    state.timers = timers(1)
end

function love.update(dt)
    state.pacman:update(state)
    for _, ghost in pairs(state.monsters) do
        ghost:update(state)
    end
    state.frame = state.frame + 1
end

function love.draw()
    local scale = 20

    -- draw maze
    state.maze:draw(0, 0, scale)

    -- draw dots
    love.graphics.setColor(1, 1, 1, 1)
    for x = 2, state.maze.width, 1 do
        for y = 2, state.maze.height, 1 do
            -- make sure its clear
            if not (state.maze:get(x, y) or state.maze:get(x + 1, y)
                    or state.maze:get(x, y + 1) or state.maze:get(x + 1, y + 1)) then
                love.graphics.circle("fill", x * scale, y * scale, scale / 20 * 2)
            end
        end
    end

    -- draw pacman
    state.pacman:draw(scale)

    -- draw monster
    for _, monster in pairs(state.monsters) do
        monster:draw(scale)
    end
end
