local function deepCopy(t)
    if type(t) == "table" then
        local nt = {}
        for k, v in pairs(t) do
            nt[k] = deepCopy(v)
        end
        setmetatable(nt, getmetatable(t))
        return nt
    else
        return t
    end
end

local Board = {}
Board.__index = Board

function Board.new(width, height)
    local self = {}

    self._data = {}
    self._width = width
    self._height = height
    for y=1, height do
        self._data[y] = {}
        for x=1, width do
            self._data[y][x] = false
        end
    end

    return setmetatable(self, Board)
end

function Board.get(self, x, y)
    if x <= 0 or x > self._width or y <= 0 or y > self._height then
        return false
    end

    return self._data[y][x]
end

function Board.set(self, x, y, val)
    if x <= 0 or x > self._width or y <= 0 or y > self._height then
        return
    end

    self._data[y][x] = val
end

function Board.fill_piece(self, piece)
    for x=1, 4 do
        for y=1, 4 do
            local bx, by = piece:x() + x - 1, piece:y() + y - 1
            if 1 <= bx and bx <= self._width and 1 <= by and by <= self._height then
                if piece:query(x, y) then
                    self:set(bx, by, piece:color())
                end
            end
        end
    end
end

function Board.piece_collides(self, piece)
    for x=1, 4 do
        for y=1, 4 do
            local bx, by = piece:x() + x - 1, piece:y() + y - 1
            
            if piece:query(x, y)
                and (not (1 <= bx and bx <= self._width and 1 <= by and by <= self._height)
                     or self:get(bx, by))
            then
                return true
            end
        end
    end
    return false
end

function Board.clone(self)
    return deepCopy(self)
end

function Board.width(self)
    return self._width
end

function Board.height(self)
    return self._height
end

return Board