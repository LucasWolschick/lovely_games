local Consts = require("consts")
local Piece = require("piece")
local Board = require("board")

math.randomseed(os.time())
for i=1, 5 do math.random() end

COLORS = {
    {0, 1, 1},
    {1, 1, 0},
    {1, 0, 0},
    {0, 1, 0},
    {1, 0.5, 0},
    {0, 0, 1},
    {1, 0, 1},
    {0.5, 0.5, 0.5}
}

for i=1, #PIECES do
    PIECES[i] = string.gsub(PIECES[i], "%s", "")
end

board = Board.new(Consts.BOARD_WIDTH, Consts.BOARD_HEIGHT)
state = {
    fall_timer = 0,
    rotated = false,
    lines = 0,
    removing_timer = 0,
    removing = {},
    next_pieces = {},
    score = 0,
}
buf = nil

function table.find(haystack, needle)
    for k, v in pairs(haystack) do
        if v == needle then
            return k
        end
    end
    return nil
end

function table.shuffle(t)
    for i=#t, 2, -1 do
        local j = math.random(1, i)
        t[i], t[j] = t[j], t[i]
    end
end

function love.load()
    buf = love.graphics.newCanvas(Consts.CELL_SIZE*(board:width()+2+2+4), Consts.CELL_SIZE*(board:height()+1))
end

function doStep()
    -- set up next pieces
    if #state.next_pieces == 0 then
        -- fill table
        for i=1, 7 do
            for j=1, 2 do
                table.insert(state.next_pieces, i)
            end
        end
        -- shuffle
        table.shuffle(state.next_pieces)
    end

    if state.removing_timer > 0 then
        state.removing_timer = state.removing_timer - 1
        if state.removing_timer <= 0 then
            -- move lines above me 1 down
            local l = table.remove(state.removing, 1)
            while l do
                for ny = l, 1, -1 do
                    for x=1, board:width() do
                        board:set(x, ny, board:get(x, ny-1))
                    end
                end
                l = table.remove(state.removing, 1)
            end
            state.removing_timer = 0
        end
        return
    end

    if not piece then
        piece = Piece.new(math.random(7), math.floor(Consts.BOARD_WIDTH/2 - 2/2), 1, 0)
    end

    -- lateral movement
    if love.keyboard.isDown("right") then
        local mv_piece = piece:move(1, 0)
        if not board:piece_collides(mv_piece) then
            piece = mv_piece
        end
    end

    if love.keyboard.isDown("left") then
        local mv_piece = piece:move(-1, 0)
        if not board:piece_collides(mv_piece) then
            piece = mv_piece
        end
    end

    local function doRotate(direction)
        if not state.rotated then
            state.rotated = true
            local mv_piece = piece:rotate(direction)
            local offsets = {0, 1, -1, 2, -2, 3, -3}
            for _, offset in ipairs(offsets) do
                local p = mv_piece:move(offset, 0)
                if not board:piece_collides(p) then
                    piece = p
                    break
                end
            end
        end
    end

    -- rotation
    if love.keyboard.isDown("z") then
        doRotate(1)
    elseif love.keyboard.isDown("x") then
        doRotate(-1)
    else
        state.rotated = false
    end

    state.fall_timer = state.fall_timer + 1

    if love.keyboard.isDown("down") or state.fall_timer >= Consts.FALL_STEPS - math.floor(state.lines/20) then
        -- try fall piece
        local fallen_piece = piece:move(0, 1)
        if not board:piece_collides(fallen_piece) then
            piece = fallen_piece
        else
            -- freeze piece
            board:fill_piece(piece)
            state.removing = {}

            -- clear any filled lines
            for y = piece:y(), piece:y() + 3 do
                local filled = true
                for x = 1, board:width() do
                    if not board:get(x, y) then
                        filled = false
                        break
                    end
                end
                if filled then
                    state.lines = state.lines + 1
                    table.insert(state.removing, y)
                    state.removing_timer = state.removing_timer + Consts.FALL_STEPS/2
                end
            end

            state.score = state.score + (#state.removing)^2 * 10

            -- pick new piece
            piece = Piece.new(table.remove(state.next_pieces), math.floor(Consts.BOARD_WIDTH/2 - 2/2), 1, piece:rot())
        end

        state.fall_timer = 0
    end
end

local accum = 0
function love.update(dt)
    accum = accum + dt
    if accum > Consts.STEP_TIME then
        accum = accum - Consts.STEP_TIME
        doStep()
    end
end

function drawTile(x, y, color, size)
    local dark = {}
    local light = {}
    for i, c in ipairs(color) do
        dark[i] = c*0.9
        light[i] = c*1.1
    end
    
    -- rectangle bg
    love.graphics.setColor(dark)
    love.graphics.rectangle("fill", x*size + 2, (y-1)*size + 2, size - 1, size - 1, size*0.1, size*0.1)
    love.graphics.setColor(color)
    love.graphics.rectangle("fill", x*size + 0.1*size, (y-1)*size + 0.1*size, 0.8*size, 0.8*size, size*0.1, size*0.1)
end

function love.draw()
    -- draw game
    love.graphics.clear(0, 0, 0, 1)
    love.graphics.setCanvas(buf)
    love.graphics.clear(0, 0, 0, 1)
    do
        love.graphics.setColor(COLORS[#COLORS])

        -- walls
        for y=1, board:height()+1 do
            drawTile(0, y, COLORS[#COLORS], Consts.CELL_SIZE)
            drawTile(board:width()+1, y, COLORS[#COLORS], Consts.CELL_SIZE)
        end
        
        -- floor
        for x=1, board:width() do
            drawTile(x, board:height()+1, COLORS[#COLORS], Consts.CELL_SIZE)
        end

        -- board
        for y=1, board:height() do
            for x=1, board:width() do
                if board:get(x, y) then
                    local col = COLORS[board:get(x, y)]
                    if state.removing_timer > 0 and state.removing_timer % 4 >= 2 and table.find(state.removing, y) then
                        col = {1, 1, 1, 1}
                    end
                    drawTile(x, y, col, Consts.CELL_SIZE)
                end
            end
        end

        local function drawPiece(piece)
            for y=1, 4 do
                for x=1, 4 do
                    if piece:query(x, y) then
                        drawTile(piece:x() + x - 1, piece:y() + y - 1, COLORS[piece:color()], Consts.CELL_SIZE)
                    end
                end
            end
        end

        -- piece
        if piece and state.removing_timer <= 0 then
            drawPiece(piece)
        end

        -- next piece
        if #state.next_pieces > 0 then
            local p = Piece.new(state.next_pieces[#state.next_pieces], Consts.BOARD_WIDTH + 2, 2, 0)
            drawPiece(p)
        end

        love.graphics.setColor(1, 1, 1, 1)
        
        -- score
        love.graphics.print(("SCORE: %5d"):format(state.score), (Consts.BOARD_WIDTH + 3)*Consts.CELL_SIZE, Consts.CELL_SIZE*8)
    end
    love.graphics.setCanvas()

    -- draw buffer to screen
    love.graphics.draw(buf, (Consts.WIDTH - buf:getWidth())/2, (Consts.HEIGHT - buf:getHeight())/2)
end