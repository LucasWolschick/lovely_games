local Consts = require("consts")

ball = {
    x = Consts.WIDTH/2,
    y = Consts.HEIGHT/2,
    r = Consts.BALL_RADIUS,
    vx = Consts.BALL_SPEED,
    vy = Consts.BALL_SPEED,
}

lpaddle = {
    x = 20,
    y = (Consts.HEIGHT - Consts.PADDLE_HEIGHT)/2,
    width = Consts.PADDLE_WIDTH,
    height = Consts.PADDLE_HEIGHT,
}

rpaddle = {
    x = Consts.WIDTH-20-Consts.PADDLE_WIDTH/2,
    y = (Consts.HEIGHT - Consts.PADDLE_HEIGHT)/2,
    width = Consts.PADDLE_WIDTH,
    height = Consts.PADDLE_HEIGHT
}

state = "score"
ticker = Consts.SCORE_TIME
last_scorer = "l"
score_l = 0
score_r = 0

function clamp(x, min, max)
    if x > max then
        return max
    elseif x < min then
        return min
    else
        return x
    end
end

function collides(ball, paddle)
    local ax0 = ball.x - ball.r
    local ax1 = ball.x + ball.r
    local ay0 = ball.y - ball.r
    local ay1 = ball.y + ball.r

    local bx0 = paddle.x
    local bx1 = paddle.x + paddle.width
    local by0 = paddle.y
    local by1 = paddle.y + paddle.height

    return not ((ax1 < bx0 or ax0 > bx1) or (ay1 < by0 or ay0 > by1))
end

function doGameTick(dt)
    -- update left paddle
    if love.keyboard.isDown("down") then
        lpaddle.y = lpaddle.y + Consts.PADDLE_SPEED * dt
    end

    if love.keyboard.isDown("up") then
        lpaddle.y = lpaddle.y - Consts.PADDLE_SPEED * dt
    end

    lpaddle.y = clamp(lpaddle.y, 0, Consts.HEIGHT - Consts.PADDLE_HEIGHT)

    -- process right paddle
    if true or ball.vx > 0 then
        local control = 0

        -- determine ball position when it eventually reaches the paddle X
        local t = (rpaddle.x - (ball.x + ball.r)) / ball.vx
        local dsy = t*ball.vy
        local ty = (ball.y - ball.r) + dsy
        local bound = Consts.HEIGHT - 2*ball.r
        local sy = ty % bound
        local wrapps = math.floor(ty / bound)
        if wrapps % 2 == 1 then
            sy = Consts.HEIGHT - 2*ball.r - sy
        end

        sy = sy + ball.r

        if sy < rpaddle.y + Consts.BALL_RADIUS*2 then
            control = -1
        elseif sy > rpaddle.y + Consts.PADDLE_HEIGHT - Consts.BALL_RADIUS*2 then
            control = 1
        end
        
        rpaddle.y = rpaddle.y + control*Consts.PADDLE_SPEED*dt
        rpaddle.y = clamp(rpaddle.y, 0, Consts.HEIGHT - Consts.PADDLE_HEIGHT)
    end

    -- update ball
    ball.x = ball.x + ball.vx * dt
    ball.y = ball.y + ball.vy * dt

    if ball.y > Consts.HEIGHT - Consts.BALL_RADIUS then
        ball.y = Consts.HEIGHT - Consts.BALL_RADIUS
        ball.vy = -ball.vy
    end

    if ball.y < Consts.BALL_RADIUS then
        ball.y = Consts.BALL_RADIUS
        ball.vy = -ball.vy
    end

    if ball.vx > 0 and collides(ball, rpaddle) then
        -- determine the angle
        local p = (ball.y - rpaddle.y)/rpaddle.height
        local angle = (clamp(p, 0, 1) - 0.5)*2 * math.pi/3
        ball.vx = -Consts.BALL_SPEED
        ball.vy = math.tan(angle)*Consts.BALL_SPEED
    elseif ball.vx < 0 and collides(ball, lpaddle) then
        local p = (ball.y - lpaddle.y)/lpaddle.height
        local angle = (clamp(p, 0, 1) - 0.5)*2 * math.pi/3
        ball.vx = Consts.BALL_SPEED
        ball.vy = math.tan(angle)*Consts.BALL_SPEED
    end

    if ball.x > Consts.WIDTH + ball.r then
        state = "score"
        last_scorer = "l"
        score_l = score_l + 1
        ticker = Consts.SCORE_TIME
    elseif ball.x < -ball.r then
        state = "score"
        last_scorer = "r"
        score_r = score_r + 1
        ticker = Consts.SCORE_TIME
    end
end

function doScoreTick(dt)
    ball.x = Consts.WIDTH/2
    ball.y = Consts.HEIGHT/2
    ball.vx = Consts.BALL_SPEED
    -- update left paddle
    if love.keyboard.isDown("down") then
        lpaddle.y = lpaddle.y + Consts.PADDLE_SPEED * dt
    end

    if love.keyboard.isDown("up") then
        lpaddle.y = lpaddle.y - Consts.PADDLE_SPEED * dt
    end

    lpaddle.y = clamp(lpaddle.y, 0, Consts.HEIGHT - Consts.PADDLE_HEIGHT)
    if last_scorer == "r" then
        ball.vx = -ball.vx
    end
    ball.vy = Consts.BALL_SPEED*2*(math.random(1)-0.5)
end

function love.draw()
    love.graphics.clear()
    
    -- ball rendering
    love.graphics.rectangle("fill", ball.x - ball.r, ball.y - ball.r, ball.r*2, ball.r*2)

    -- paddle rendering
    love.graphics.rectangle("fill", lpaddle.x, lpaddle.y, lpaddle.width, lpaddle.height)
    love.graphics.rectangle("fill", rpaddle.x, rpaddle.y, rpaddle.width, rpaddle.height)

    -- score rendering
    love.graphics.print(""..score_l, Consts.WIDTH/2-40, 40)
    love.graphics.print(""..score_r, Consts.WIDTH/2+30, 40)
end

local accum = 0
function love.update(dt)
    accum = accum + dt
    while accum > 1/60 do
        accum = accum - 1/60
        if state == "game" then
            doGameTick(1/60)
        elseif state == "score" then
            doScoreTick(1/60)
            ticker = ticker - 1/60
            if ticker < 0 then
                ticker = 0
                state = "game"
            end
        end
    end
end