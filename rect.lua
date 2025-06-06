local rect = {}

rect.X = 0
rect.Y = 0
rect.W = 0
rect.H = 0

function rect.load()
    rect.X, rect.Y, rect.W, rect.H = 20, 20, 60, 20
end

function rect.update(dt)
    rect.W = rect.W + 1
    rect.H = rect.H + 1
end

function rect.draw()
    -- In versions prior to 11.0, color component values are (0, 102, 102)
    love.graphics.setColor(0, 0.4, 0.4)
    love.graphics.rectangle("fill", rect.X, rect.Y, rect.W, rect.H)
end

return rect
