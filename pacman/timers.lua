local Monster = require("monster")

local data = {
    { 7, 20, 7, 20, 5, 20,                      5 },
    { 7, 20, 7, 20, 5, 17 * 60 + 13 + 14 / 100, 1 / 100 },
    { 5, 20, 5, 20, 5, 17 * 60 + 17 + 14 / 100, 1 / 100 },
}

function timers(level)
    local d
    if level == 1 then
        d = data[1]
    elseif 2 <= level and level <= 4 then
        d = data[2]
    else
        d = data[3]
    end

    return function(t)
        local i = 1
        while i <= #d and t > 0 do
            t = t - d[i]
            i = i + 1
        end
        if i % 2 == 1 then
            return Monster.CHASE
        else
            return Monster.SCATTER
        end
    end
end

return timers
