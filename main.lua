function love.load()
    isRunning = true
    x, y = 100, 100
end

function love.update(dt)
    if not isRunning then return end

    x = x + 10 * dt
    y = y + 10 * dt
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    elseif key == "f" then
        love.window.setFullscreen(not love.window.getFullscreen())
    elseif key == "r" then
        love.load() -- reload game
    elseif key == "p" then
        isRunning = not isRunning
    end
end

function love.draw()
    love.graphics.circle('line', x, y, 50)
end
