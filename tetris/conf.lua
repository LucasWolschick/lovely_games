local consts = require("consts")

function love.conf(conf)
    conf.window.width = consts.WIDTH
    conf.window.height = consts.HEIGHT
    conf.window.usedpiscale = false
end