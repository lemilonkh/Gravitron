local vector = require 'libs.hump.vector'

image_earth = love.graphics.newImage( 'images/earth.png' )
image_mars = love.graphics.newImage( 'images/mars.png' )
image_neptun = love.graphics.newImage( 'images/neptun.png' )
image_venus = love.graphics.newImage( 'images/venus.png' )
image_sun = love.graphics.newImage( 'images/sun.png' )
images_planets = {image_earth, image_mars, image_neptun, image_venus, image_sun}

settings = {
    pixelsPerMeter = 35,
    movementSpeed = 15,
    planetCount = 5,
    objectCount = 20,
    maxGravityDistance = 3 -- factor for radius of maximum gravity excertion
}

function love.load()
    isRunning = true
    love.physics.setMeter(settings.pixelsPerMeter)
    world = love.physics.newWorld(0, 0, true)
    planets = {} -- static colliders
    objects = {} -- dynamic objects
    player = {}

    player.sprite = love.graphics.newImage('sprites/delta_ship.png')
    local playerWidth, playerHeight = player.sprite:getPixelDimensions()
    player.collision = makeTriangle(150, 150, playerWidth, playerHeight, true)

    -- bullet attack
    player.bullets = {}
    player.fire = function(self)
        local bullet = {}
        bullet.x, bullet.y = player.collision:getWorldCenter()
        bullet.collision = makeCircle(bullet.x, bullet.y, settings.playerSize/2, true)
        table.insert(player.bullets, bullet)
        local direction = vector(player.collision:getLinearVelocity()):normalized() * 100
        bullet.collision:applyLinearImpulse(direction.x, direction.y)
    end
    
    for i = 1, settings.planetCount do
        addPlanet(love.math.random() * love.graphics.getWidth(), love.math.random() * love.graphics.getHeight(), i * 10)
    end

    for i = 1, settings.objectCount do
        addObject(love.math.random() * love.graphics.getWidth(), love.math.random() * love.graphics.getHeight(), 10)
    end
end

function addPlanet(x, y, r)
	local planet = {}
	planet.collision = makeCircle(x, y, r, false)
        planet.x=x --TODO
        planet.y=y
	planet.r=r
        table.insert(planets, planet)
end

function addObject(x, y, r)
    local object = {}
    object.collision = makeCircle(x, y, r, true)
    table.insert(objects, object)
end

function makeCircle(x, y, r, isDynamic)
    local bodyType = isDynamic and 'dynamic' or 'static'
    local body = love.physics.newBody(world, x, y, bodyType)
	local shape = love.physics.newCircleShape(r)
	local fixture = love.physics.newFixture(body, shape, 1)
    fixture:setDensity(5)
    fixture:setFriction(1)
    fixture:setRestitution(0)
    
    return body
end

function makeBox(x, y, w, h, isDynamic)
    local bodyType = isDynamic and 'dynamic' or 'static'
    local body = love.physics.newBody(world, x, y, bodyType)
	local shape = love.physics.newRectangleShape(w, h)
	local fixture = love.physics.newFixture(body, shape, 1)
	fixture:setDensity(20)
	fixture:setFriction(1)
	fixture:setRestitution(0)
	
	return body
end

function makeTriangle(x, y, w, h, isDynamic)
    local bodyType = isDynamic and 'dynamic' or 'static'
    local body = love.physics.newBody(world, x, y, bodyType)
    local shape = love.physics.newPolygonShape(-w/2, 0, w/2, -h/2, w/2, h/2)
    local fixture = love.physics.newFixture(body, shape, 1)
    fixture:setDensity(20)
    fixture:setFriction(1)
    fixture:setRestitution(0)

    return body
end

function love.update(dt)
    if not isRunning then return end

    local x, y = 0, 0
    if love.keyboard.isDown("up") then
        y = -settings.movementSpeed
    end
    if love.keyboard.isDown("down") then
        y = settings.movementSpeed
    end
    if love.keyboard.isDown("left") then
        x = -settings.movementSpeed
    end
    if love.keyboard.isDown("right") then
        x = settings.movementSpeed
    end
    player.collision:applyLinearImpulse(x * dt, y * dt)

    world:update(dt)
    applyGravityForces()

    local playerPosition = vector(getPlayerPosition())
    local warpedPosition = playerPosition:clone()
    warpedPosition.x = math.abs(warpedPosition.x % love.graphics.getWidth())
    warpedPosition.y = math.abs(warpedPosition.y % love.graphics.getHeight())
    if playerPosition:dist(warpedPosition) > 0 then
        player.collision:setPosition(warpedPosition.x, warpedPosition.y)
    end
end

function applyGravityForces()
    for _, object in ipairs(objects) do
		for _, planet in ipairs(planets) do
            applyGravity(object.collision, planet.collision)
        end
    end

    for _, planet in ipairs(planets) do
        applyGravity(player.collision, planet.collision)
    end
end

function applyGravity(body, planet)
    local bodyPosition = vector(body:getWorldCenter())

    local shape = planet:getFixtures()[1]:getShape()
    local radius = shape:getRadius()
    local planetPosition = vector(planet:getWorldCenter())

    local bodyToPlanet = bodyPosition - planetPosition
    local distanceToPlanet = bodyToPlanet:len()

    if distanceToPlanet <= radius * settings.maxGravityDistance then
        local force = -bodyToPlanet:clone()

        local sum = math.abs(force.x) + math.abs(force.y)
        force = force * (1 / sum * radius / distanceToPlanet) * 2
        body:applyForce(force.x, force.y, bodyPosition.x, bodyPosition.y)
    end
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
    elseif key == "space" then
        player:fire()
    end
end

function drawCircle(body)
    local radius = body:getFixtures()[1]:getShape():getRadius()
    love.graphics.circle('fill', body:getX(), body:getY(), radius)
end

function getPlayerPoints()
    return player.collision:getWorldPoints(player.collision:getFixtures()[1]:getShape():getPoints())
end

function getPlayerPosition()
    return player.collision:getWorldCenter()
end

function love.draw()
    love.graphics.push()
    local scale = love.graphics.getDPIScale()
    love.graphics.scale(scale)

    love.graphics.setColor(1, 1, 1)

    -- draw static planets
    for i, planet in ipairs(planets) do
        --love.graphics.setColor(0.7, 0.2, 0.2)
        --drawCircle(planet.collision)
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(images_planets[i], planet.x - planet.r, planet.y - planet.r, 0, planet.r/52*2, planet.r/52*2, 0, 0, 0, 0 )
        --love.graphics.draw(image_earth, planet.x - planet.r, planet.y - planet.r)
        --TODO
    end

    -- draw dynamic objects
    for _, object in ipairs(objects) do
        love.graphics.setColor(0.2, 0.8, 0.7)
        drawCircle(object.collision)
    end



    -- draw bullets
    for _, bullet in ipairs(player.bullets) do
        love.graphics.setColor(1, 0, 0, 1)
        --love.graphics.circle("fill", bullet.x, bullet.y, settings.playerSize/2)
        local bulletRadius = bullet.collision:getFixtures()[1]:getShape():getRadius()
        love.graphics.circle('fill', bullet.collision:getX(), bullet.collision:getY(), bulletRadius)
    end

    -- draw player
    love.graphics.setColor(1, 1, 1)
    love.graphics.polygon('line', getPlayerPoints())
    local playerBody = player.collision
    love.graphics.draw(player.sprite, playerBody:getX(), playerBody:getY(), playerBody:getAngle(), 1, 1, player.sprite:getWidth()/2, player.sprite:getHeight()/2)

    love.graphics.pop()
end
