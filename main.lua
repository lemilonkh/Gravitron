function love.load()
    x, y = 100, 100
end

function love.update(dt)
    x = x + 10 * dt
    y = y + 10 * dt
end

function love.draw()
    love.graphics.circle('line', x, y, 50)
end
