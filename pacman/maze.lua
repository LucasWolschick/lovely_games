local function file_to_maze(path)
    local result, msg = love.filesystem.read("string", path, nil)
    if not result then
        print("ERROR loading maze:", msg)
        os.exit(1)
    end

    local contents, sz = result, msg
    local m = {}

    -- find first newline
    local width = string.find(contents, "\n") - 1
    local _, height = string.gsub(contents, "\n", "\n")

    for y = 1, height do
        m[y] = {}
        for x = 1, width do
            local idx = (y - 1) * (width + 1) + x
            table.insert(m[y], contents:sub(idx, idx) == "#")
        end
    end

    return m, width, height
end

local Maze = {}
Maze.__index = Maze

function Maze.new()
    local self = {}

    self.m, self.width, self.height = file_to_maze("res/maze.txt")

    setmetatable(self, Maze)
    return self
end

function Maze:get(x, y)
    if 0 < x and x <= self.width and 0 < y and y <= self.height then
        return self.m[y][x]
    else
        return nil
    end
end

function Maze:draw(bx, by, scale)
    love.graphics.setColor(0, 0, 1)
    for y = 1, self.height do
        for x = 1, self.width do
            if self:get(x, y) then
                love.graphics.rectangle("fill", bx + (x - 1) * scale, by + (y - 1) * scale, scale, scale)
            end
        end
    end
    love.graphics.setColor(1, 1, 1)
end

return Maze
