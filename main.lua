local snake = require("snake")

function love.load()
    snake.initialize()
end

function love.update(dt)
    snake.update(dt)
end

function love.draw()
    snake.draw()
end
