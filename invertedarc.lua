local invarc = {}

invarc.memo = {}

function invarc.draw(mode, x, y, r, theta, segments)
    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.rotate(theta)
    love.graphics.scale(r)

    local v = invarc.memo[segments]
    if v == nil then
        v = { 0, 0, 1, 0 }
        for i = 1, segments do
            local th = (i / segments) * (math.pi / 2)
            table.insert(v, 1 - math.sin(th))
            table.insert(v, 1 - math.cos(th))
        end
        v = love.math.triangulate(v)
        invarc.memo[segments] = v
    end

    for _, tri in ipairs(v) do
        love.graphics.polygon(mode, tri)
    end

    love.graphics.pop()
end

return invarc
