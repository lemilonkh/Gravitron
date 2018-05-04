settings = {
    pixelsPerMeter = 35,
    movementSpeed = 35,
    planetCount = 5,
    objectCount = 20
}

function love.load()
    isRunning = true
    love.physics.setMeter(settings.pixelsPerMeter)
    world = love.physics.newWorld(0, 0, true)
    planets = {} -- static colliders
    objects = {} -- dynamic objects
    player = makeBox(150, 150, 15, 15, true)

    for i = 1, settings.planetCount do
        addPlanet(i * 100, i * 100, i * 10)
    end

    for i = 1, settings.objectCount do
        addObject(i * 20, i * 20, 5)
    end
end

function addPlanet(x, y, r)
	local planet = makeCircle(x, y, r, false)
    table.insert(planets, planet)
end

function addObject(x, y, r)
    local object = makeCircle(x, y, r, true)
    table.insert(planets, object)
end

function makeCircle(x, y, r, isDynamic)
    local bodyType = isDynamic and 'dynamic' or 'static'
    local body = love.physics.newBody(world, x, y, bodyType)
	local shape = love.physics.newCircleShape(r)
	local fixture = love.physics.newFixture(body, shape, 1)
    fixture:setDensity(1)
    fixture:setFriction(1)
    fixture:setRestitution(0)
    
    return body
end

function makeBox(x, y, w, h, isDynamic)
    local bodyType = isDynamic and 'dynamic' or 'static'
    local body = love.physics.newBody(world, x, y, bodyType)
	local shape = love.physics.newRectangleShape(w, h)
	local fixture = love.physics.newFixture(body, shape, 1)
	fixture:setDensity(1)
	fixture:setFriction(1)
	fixture:setRestitution(0)
	
	return body
end

function love.update(dt)
    if not isRunning then return end

    world:update(dt)
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

    for _, object in ipairs(objects) do
        local objectRadius = object:getFixtures()[1]:getShape():getRadius()
        love.graphics.circle('fill', object:getX(), object:getY(), objectRadius)
    end

    -- draw player
    love.graphics.polygon('line', player:getWorldPoints(player:getFixtures()[1]:getShape():getPoints()))
end
