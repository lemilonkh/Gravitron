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

return physics