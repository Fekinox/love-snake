local invarc = require("invertedarc")
local snake = {}

snake.boardW = 20
snake.boardH = 20

snake.gameStatus = "ended"

snake.snakeColorA = { 0, 1, 0 }
snake.snakeColorB = { 0, 0.5, 0 }
snake.appleColor = { 1, 0, 0 }
snake.gameOverColor = { 0.5, 0.5, 0.5 }

OFFSET = 4
CELL_WIDTH = 25

function snake.initialize()
    snake.seed = os.time()
    snake.rng = love.math.newRandomGenerator()
    snake.rng:setSeed(snake.seed)

    snake.snakeDir = { 0, 1 }
    snake.nextDir = nil
    snake.snakePositions = { { math.floor(snake.boardW / 2), math.floor(snake.boardH / 2) } }
    snake.length = 1
    snake.growth = 3

    snake.placeApple()

    snake.moveTimer = 0

    snake.gameStatus = "started"
end

function snake.placeApple()
    local dirty = true
    while dirty do
        snake.applePos = { snake.rng:random(1, snake.boardW), snake.rng:random(1, snake.boardH) }
        dirty = false
        for _, p in ipairs(snake.snakePositions) do
            if p[1] == snake.applePos[1] and p[2] == snake.applePos[2] then
                dirty = true
                break
            end
        end
    end
end

function snake.draw()
    love.graphics.push()
    love.graphics.translate(
        (love.graphics.getWidth() - CELL_WIDTH * (snake.boardW + 2)) / 2,
        (love.graphics.getHeight() - CELL_WIDTH * (snake.boardH + 2)) / 2)
    -- border
    love.graphics.setColor(snake.gameOverColor)
    love.graphics.rectangle("fill",
        0, 0,
        CELL_WIDTH, CELL_WIDTH * (snake.boardH + 2))
    love.graphics.rectangle("fill",
        (snake.boardW + 1) * CELL_WIDTH, 0,
        CELL_WIDTH, CELL_WIDTH * (snake.boardH + 2))
    love.graphics.rectangle("fill",
        CELL_WIDTH, 0,
        CELL_WIDTH * snake.boardW, CELL_WIDTH)
    love.graphics.rectangle("fill",
        CELL_WIDTH, (snake.boardH + 1) * CELL_WIDTH,
        CELL_WIDTH * snake.boardW, CELL_WIDTH)

    -- debug grid
    -- for i = 1, snake.boardW do
    --     love.graphics.line(i * CELL_WIDTH, CELL_WIDTH, i * CELL_WIDTH, (snake.boardH + 1) * CELL_WIDTH)
    -- end

    -- for i = 1, snake.boardH do
    --     love.graphics.line(CELL_WIDTH, i * CELL_WIDTH, (snake.boardW + 1) * CELL_WIDTH, i * CELL_WIDTH)
    -- end

    -- snake
    if snake.gameStatus == "started" then
        love.graphics.setColor(snake.snakeColorB)
    else
        love.graphics.setColor(snake.gameOverColor)
    end

    for i, p in ipairs(snake.snakePositions) do
        snake.drawSnakeSegment(snake.snakePositions[i - 1], p, snake.snakePositions[i + 1])
    end
    if snake.gameStatus == "started" then
        love.graphics.setColor(snake.snakeColorA)
    else
        love.graphics.setColor(snake.gameOverColor)
    end
    love.graphics.push()
    love.graphics.translate(0, -CELL_WIDTH * 0.25)
    for i, p in ipairs(snake.snakePositions) do
        snake.drawSnakeSegment(snake.snakePositions[i - 1], p, snake.snakePositions[i + 1])
    end
    love.graphics.pop()

    -- apple
    if snake.gameStatus == "started" then
        love.graphics.setColor(snake.appleColor)
    else
        love.graphics.setColor(snake.gameOverColor)
    end
    love.graphics.push()
    love.graphics.translate((snake.applePos[1] + 0.5) * CELL_WIDTH, (snake.applePos[2] + 0.5) * CELL_WIDTH)
    snake.drawSnakeO()
    love.graphics.pop()
    love.graphics.pop()
end

function snake.update(dt)
    if love.keyboard.isDown("r") then
        snake.initialize()
    end

    if snake.gameStatus == "started" then
        if love.keyboard.isDown("w") and snake.snakeDir[2] ~= 1 then
            snake.nextDir = { 0, -1 }
        end
        if love.keyboard.isDown("s") and snake.snakeDir[2] ~= -1 then
            snake.nextDir = { 0, 1 }
        end
        if love.keyboard.isDown("a") and snake.snakeDir[1] ~= 1 then
            snake.nextDir = { -1, 0 }
        end
        if love.keyboard.isDown("d") and snake.snakeDir[1] ~= -1 then
            snake.nextDir = { 1, 0 }
        end

        snake.moveTimer = snake.moveTimer + dt
        while snake.moveTimer > 0.2 do
            snake.moveSnake()
            snake.moveTimer = snake.moveTimer - 0.2
            if snake.gameStatus == "ended" then
                break
            end
        end
    end
end

function snake.moveSnake()
    if snake.nextDir ~= nil then
        snake.snakeDir = snake.nextDir
        snake.nextDir = nil
    end

    local h = snake.snakePositions[snake.length]
    local head = { h[1], h[2] }
    head[1] = head[1] + snake.snakeDir[1]
    head[2] = head[2] + snake.snakeDir[2]

    if head[1] < 1 or head[2] < 1 or head[1] > snake.boardW or head[2] > snake.boardH then
        snake.gameStatus = "ended"
        return
    end

    for _, p in ipairs(snake.snakePositions) do
        if head[1] == p[1] and head[2] == p[2] then
            snake.gameStatus = "ended"
            return
        end
    end

    if snake.applePos[1] == head[1] and snake.applePos[2] == head[2] then
        snake.placeApple()
        snake.growth = snake.growth + 3
    end
    if snake.growth > 0 then
        snake.length = snake.length + 1
        snake.growth = snake.growth - 1
    else
        table.remove(snake.snakePositions, 1)
    end
    table.insert(snake.snakePositions, head)
end

function snake.drawSnakeSegment(a, b, c)
    love.graphics.push()
    love.graphics.translate((b[1] + 0.5) * CELL_WIDTH, (b[2] + 0.5) * CELL_WIDTH)
    if a == nil and c == nil then
        snake.drawSnakeO()
        love.graphics.pop()
        return
    end

    if a == nil then
        a, c = c, a
    end

    local adx, ady = b[1] - a[1], b[2] - a[2]

    if c == nil then
        love.graphics.rotate(math.atan2(ady, adx))
        snake.drawSnakeH()
    else
        local bdx, bdy = c[1] - b[1], c[2] - b[2]
        if bdx == adx and bdy == ady then
            if bdx == 0 then
                love.graphics.rotate(math.pi / 2)
            end
            snake.drawSnakeS()
        else
            local th = math.atan2(ady, adx)
            if adx * bdy - ady * bdx < 0 then
                th = th + math.pi / 2
            end
            love.graphics.rotate(th)
            snake.drawSnakeL()
        end
    end

    love.graphics.pop()
end

function snake.drawSnakeL()
    love.graphics.rectangle("fill",
        -CELL_WIDTH / 2, OFFSET - CELL_WIDTH / 2,
        CELL_WIDTH - 1.5 * OFFSET, CELL_WIDTH - 2 * OFFSET)
    love.graphics.rectangle("fill",
        -CELL_WIDTH / 2 + OFFSET, 1.5 * OFFSET - CELL_WIDTH / 2,
        CELL_WIDTH - 2 * OFFSET, CELL_WIDTH - 1.5 * OFFSET)
    love.graphics.arc("fill",
        CELL_WIDTH / 2 - OFFSET * 1.5, OFFSET * 1.5 - CELL_WIDTH / 2, 0.5 * OFFSET,
        math.pi * 1.5, math.pi * 2, 10)
    invarc.draw("fill",
        OFFSET * 1 - CELL_WIDTH / 2, CELL_WIDTH / 2 - OFFSET * 1, 0.5 * OFFSET,
        math.pi / 2, 10)
end

function snake.drawSnakeS()
    love.graphics.rectangle("fill",
        -CELL_WIDTH / 2, OFFSET - CELL_WIDTH / 2,
        CELL_WIDTH, CELL_WIDTH - 2 * OFFSET)
end

function snake.drawSnakeH()
    love.graphics.rectangle("fill",
        -CELL_WIDTH / 2, OFFSET - CELL_WIDTH / 2,
        CELL_WIDTH - 1.5 * OFFSET, CELL_WIDTH - 2 * OFFSET)
    love.graphics.rectangle("fill",
        CELL_WIDTH / 2 - OFFSET * 1.5, OFFSET * 1.5 - CELL_WIDTH / 2,
        0.5 * OFFSET, CELL_WIDTH - 3 * OFFSET)
    love.graphics.arc("fill",
        CELL_WIDTH / 2 - OFFSET * 1.5, CELL_WIDTH / 2 - OFFSET * 1.5, 0.5 * OFFSET,
        0, math.pi * 0.5, 10)
    love.graphics.arc("fill",
        CELL_WIDTH / 2 - OFFSET * 1.5, OFFSET * 1.5 - CELL_WIDTH / 2, 0.5 * OFFSET,
        math.pi * 1.5, math.pi * 2, 10)
end

function snake.drawSnakeO()
    love.graphics.rectangle("fill",
        OFFSET * 1.5 - CELL_WIDTH / 2, OFFSET - CELL_WIDTH / 2,
        CELL_WIDTH - 3 * OFFSET, CELL_WIDTH - 2 * OFFSET)
    love.graphics.rectangle("fill",
        OFFSET - CELL_WIDTH / 2, OFFSET * 1.5 - CELL_WIDTH / 2,
        CELL_WIDTH - 2 * OFFSET, CELL_WIDTH - 3 * OFFSET)

    love.graphics.arc("fill",
        CELL_WIDTH / 2 - OFFSET * 1.5, CELL_WIDTH / 2 - OFFSET * 1.5, 0.5 * OFFSET,
        0, math.pi * 0.5, 10)
    love.graphics.arc("fill",
        OFFSET * 1.5 - CELL_WIDTH / 2, CELL_WIDTH / 2 - OFFSET * 1.5, 0.5 * OFFSET,
        math.pi * 0.5, math.pi, 10)
    love.graphics.arc("fill",
        OFFSET * 1.5 - CELL_WIDTH / 2, OFFSET * 1.5 - CELL_WIDTH / 2, 0.5 * OFFSET,
        math.pi, math.pi * 1.5, 10)
    love.graphics.arc("fill",
        CELL_WIDTH / 2 - OFFSET * 1.5, OFFSET * 1.5 - CELL_WIDTH / 2, 0.5 * OFFSET,
        math.pi * 1.5, math.pi * 2, 10)
end

return snake
