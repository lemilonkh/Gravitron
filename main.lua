function love.load()
    love.physics.setMeter(35)
    world = love.physics.newWorld(0, 0, true)
    planets = {} -- static colliders
    objects = {} -- dynamic objects

    for i = 1, 5 do
        addPlanet(i * 100, i * 200, i * 50)
    end

    isRunning = true
    x, y = 100, 100
end

function addPlanet(x, y, r)
	local body = love.physics.newBody(world, x, y, "static")
	local shape = love.physics.newCircleShape(r)
	local fixture = love.physics.newFixture(body, shape, 1)
	fixture:setDensity(1)
	fixture:setRestitution(0)

    table.insert(planets, body)
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
    for _, planet in ipairs(planets) do
        local planetRadius = planet:getFixtures()[1]:getShape():getRadius()
        love.graphics.circle('fill', planet:getX(), planet:getY(), planetRadius)
    end
end
