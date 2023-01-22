PIECES = {
    "..#.\
     ..#.\
     ..#.\
     ..#.",
    
    "....\
     .##.\
     .##.\
     ....",

    "....\
     ..#.\
     .##.\
     .#..",
    
    "....\
     .#..\
     .##.\
     ..#.",
    
    ".#..\
     .#..\
     .##.\
     ....",
    
    "..#.\
     ..#.\
     .##.\
     ....",

     "..#.\
      .##.\
      ..#.\
      ...."
}

local Piece = {}
Piece.__index = Piece

function Piece.new(i, x, y, rot)
    local self = {}

    self._i = i
    self._x = x or 1
    self._y = y or 1
    self._rot = (rot and rot % 4) or 0

    return setmetatable(self, Piece)
end

function Piece.query(self, x, y)
    if x <= 0 or x > 4 then
        return false
    end

    if y <= 0 or y > 4 then
        return false
    end

    if self._rot == 0 then
        x, y = x, y        
    elseif self._rot == 1 then
        x, y = 5-y, x
    elseif self._rot == 2 then
        x, y = 5-x, 5-y
    elseif self._rot == 3 then
        x, y = y, 5-x
    end
    
    local idx = (y-1)*4 + x
    return PIECES[self._i]:sub(idx, idx) == "#"
end

function Piece.move(self, dx, dy)
    dx = dx or 0
    dy = dy or 0
    return Piece.new(self._i, self._x + dx, self._y + dy, self._rot)
end

function Piece.rotate(self, dr)
    dr = dr or 1
    return Piece.new(self._i, self._x, self._y, (self._rot + dr) % 4)
end

function Piece.color(self)
    return (self._i - 1) % 7 + 1
end

function Piece.x(self)
    return self._x
end

function Piece.y(self)
    return self._y
end

function Piece.rot(self)
    return self._rot
end

return Piece