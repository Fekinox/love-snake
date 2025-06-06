local snake = require("snake")
local invarc = require("invertedarc")

function love.load()
    snake.initialize()
end

function love.update(dt)
    snake.update(dt)
end

function love.draw()
    snake.draw()
    love.graphics.setColor(1, 1, 1)
    invarc.draw("fill", 20, 20, 20, love.timer.getTime(), 20)
end
