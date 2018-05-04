local vector = require 'libs.hump.vector'

settings = {
    pixelsPerMeter = 35,
    movementSpeed = 15,
    planetCount = 5,
    objectCount = 20,
    playerSize = 15,
<<<<<<< HEAD
    defaultBulletCountDown = 0
=======
    maxGravityDistance = 3 -- factor for radius of maximum gravity excertion
>>>>>>> 0c750f8f0d69183b4a858e7408e2a520c9ca65cf
}

function love.load()
    isRunning = true
    love.physics.setMeter(settings.pixelsPerMeter)
    world = love.physics.newWorld(0, 0, true)
    planets = {} -- static colliders
    objects = {} -- dynamic objects
    player = {}

    player.collision = makeBox(150, 150, settings.playerSize, settings.playerSize, true)

    -- bullet attack
    player.bullets = {}
    bulletCountDown = settings.defaultBulletCountDown
    player.fire = function(self)
        if bulletCountDown > 0 then return end
        bullet = {}
        bullet.x, bullet.y = player.collision:getWorldCenter()
        bullet.notFired = true
        bullet.collision = makeCircle(bullet.x, bullet.y, settings.playerSize/2, true)
        table.insert(player.bullets, bullet)
        bulletCountDown = settings.defaultBulletCountDown
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

<<<<<<< HEAD
    bulletCountDown = bulletCountDown - dt
    if bulletCountDown < 0 then 
        bulletCountDown = 0
    end

    x, y = 0, 0
=======
    local x, y = 0, 0
>>>>>>> 0c750f8f0d69183b4a858e7408e2a520c9ca65cf
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

    -- TODO: make bullet shoot in the opposite direction the player is going (not working yet)
    for _, bullet in ipairs(player.bullets) do
        if bullet.NotFired then
            bullet.collision:applyLinearImpulse(x * 100 *dt, y * 100 * dt)
        end
        bullet.notFired = false
        --TODO: Delete Bullets that are not in frame anymore
    end

    world:update(dt)
    applyGravityForces()
end

function applyGravityForces()
    for _, object in ipairs(objects) do
        local objectBody = object.collision
        local bodyPosition = vector(objectBody:getWorldCenter())
		
		for _, planet in ipairs(planets) do
            local planetBody = planet.collision
			local shape = planetBody:getFixtures()[1]:getShape()
			local radius = shape:getRadius()
			local planetPosition = vector(planetBody:getWorldCenter())

			local bodyToPlanet = bodyPosition - planetPosition
			local distanceToPlanet = bodyToPlanet:len()

			if distanceToPlanet <= radius * settings.maxGravityDistance then
                local force = -bodyToPlanet:clone()
				
				local sum = math.abs(force.x) + math.abs(force.y)
				force = force * (1 / sum * radius / distanceToPlanet) * 2
				objectBody:applyForce(force.x, force.y, bodyPosition.x, bodyPosition.y)
			end
		end
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
        player.fire()
    end
end

function love.draw()
    love.graphics.setColor(1, 1, 1, 1)

    -- draw static planets
    for _, planet in ipairs(planets) do
        local planetRadius = planet.collision:getFixtures()[1]:getShape():getRadius()
        love.graphics.circle('fill', planet.collision:getX(), planet.collision:getY(), planetRadius)
    end

    -- draw dynamic objects
    for _, object in ipairs(objects) do
        local objectRadius = object.collision:getFixtures()[1]:getShape():getRadius()
        love.graphics.circle('fill', object.collision:getX(), object.collision:getY(), objectRadius)
    end

    -- draw bullets
    for _, bullet in ipairs(player.bullets) do
        love.graphics.setColor(1, 0, 0, 1)
        --love.graphics.circle("fill", bullet.x, bullet.y, settings.playerSize/2)
        local bulletRadius = bullet.collision:getFixtures()[1]:getShape():getRadius()
        love.graphics.circle('fill', bullet.collision:getX(), bullet.collision:getY(), bulletRadius)
    end

    -- draw player
    love.graphics.setColor(0, 0, 1, 1)
    love.graphics.polygon('line', player.collision:getWorldPoints(player.collision:getFixtures()[1]:getShape():getPoints()))

end
