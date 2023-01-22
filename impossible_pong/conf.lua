local Consts = require("consts")

function love.conf(t)
    t.window.width = Consts.WIDTH
    t.window.height = Consts.HEIGHT
    t.window.usedpiscale = false
end