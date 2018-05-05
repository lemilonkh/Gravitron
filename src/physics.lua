local physics = {}

function physics.makeCircle(x, y, r, isDynamic)
    local bodyType = isDynamic and 'dynamic' or 'static'
    local body = love.physics.newBody(world, x, y, bodyType)
    local shape = love.physics.newCircleShape(r)
    local fixture = love.physics.newFixture(body, shape, 1)
    fixture:setDensity(5)
    fixture:setFriction(1)
    fixture:setRestitution(0)

    return body
end

function physics.makeBox(x, y, w, h, isDynamic)
    local bodyType = isDynamic and 'dynamic' or 'static'
    local body = love.physics.newBody(world, x, y, bodyType)
    local shape = love.physics.newRectangleShape(w, h)
    local fixture = love.physics.newFixture(body, shape, 1)
    fixture:setDensity(20)
    fixture:setFriction(1)
    fixture:setRestitution(0)

    return body
end

function physics.makeTriangle(x, y, w, h, isDynamic)
    local bodyType = isDynamic and 'dynamic' or 'static'
    local body = love.physics.newBody(world, x, y, bodyType)
    local shape = love.physics.newPolygonShape(-w/2, 0, w/2, -h/2, w/2, h/2)
    local fixture = love.physics.newFixture(body, shape, 1)
    fixture:setDensity(20)
    fixture:setFriction(1)
    fixture:setRestitution(0)

    return body
end

function physics.applyGravityForces(players, objects, planets)
    for _, object in ipairs(objects) do
        for _, planet in ipairs(planets) do
            physics.applyGravity(object.collision, planet.collision)
        end
    end

    for _, player in ipairs(players) do
        for _, planet in ipairs(planets) do
            physics.applyGravity(player.collision, planet.collision)
        end
    end
end

function physics.applyGravity(body, planet)
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

return physics