local phys = {}

phys.DIRECTIONS = {
    1, 0,
    0, 1,
    -1, 0,
    0, -1,
}

function phys.collideCircleMaze(x, y, radius, maze)
    -- calculate rect boundaries
    local min_y = y - radius
    local max_y = y + radius
    local min_x = x - radius
    local max_x = x + radius

    -- check if any portions of the player rectangle are colliding
    local collides = false
    for y = math.floor(min_y / radius) + 1, math.ceil(max_y / radius) do
        for x = math.floor(min_x / radius) + 1, math.ceil(max_x / radius) do
            if maze:get(x, y) then
                collides = true
            end
        end
    end

    --print(" ", min_x, min_y, max_x, max_y)
    --print("!", math.floor(min_x / 8), math.floor(min_y / 8), math.ceil(max_x / 8), math.ceil(max_y / 8))

    return collides
end

function phys.distance(ax, ay, bx, by)
    return math.sqrt((ax - bx) ^ 2 + (ay - by) ^ 2)
end

return phys
