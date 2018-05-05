local Player = class 'Player'
local physics = require 'src.physics'

function Player:init(x, y, controls)
    self.x, self.y = x, y
    self.controls = controls
    self.sprite = love.graphics.newImage('sprites/delta_ship.png')
    self.width, self.height = self.sprite:getDimensions()
    self.collision = physics.makeTriangle(self.x, self.y, self.width, self.height, true)
    self.bullets = {}
end

function love.update(dt)
    input:update()

    local x, y = input:get 'move'
    playerShip:move(x*100, y*100)
    if input:pressed 'action' then
        playerShip:shoot()
    end
end

-- bullet attack
function Player:fire()
    local bullet = {}
    bullet.x, bullet.y = self.collision:getWorldCenter()
    bullet.collision = physics.makeCircle(bullet.x, bullet.y, 10, true)
    table.insert(self.bullets, bullet)
    local direction = vector(self.collision:getLinearVelocity()):normalized() * 100
    bullet.collision:applyLinearImpulse(direction.x, direction.y)
end

function Player:update(dt)
    self.controls:update()

    local deltaAngle, deltaSpeed = self.controls:get('move')
    deltaAngle = deltaAngle * settings.turningSpeed * dt
    deltaSpeed = deltaSpeed * settings.movementSpeed * dt

    local playerAngle = self.collision:getAngle() + deltaAngle
    self.collision:setAngle(playerAngle)

    local impulseX, impulseY = math.cos(playerAngle) * deltaSpeed, math.sin(playerAngle) * deltaSpeed
    self.collision:applyLinearImpulse(impulseX, impulseY)

    local position = vector(self:getPosition())
    local margin = 10
    local width, height = love.graphics.getDimensions()
    local warpedPosition = position:clone()
    if position.x < -margin then warpedPosition.x = width end
    if position.x > width + margin then warpedPosition.x = 0 end
    if position.y < -margin then warpedPosition.y = height end
    if position.y > height + margin then warpedPosition.y = 0 end

    if position:dist(warpedPosition) > 0 then
        player.collision:setPosition(warpedPosition.x, warpedPosition.y)
    end
end

function Player:getShapePoints()
    return self.collision:getWorldPoints(self.collision:getFixtures()[1]:getShape():getPoints())
end

function Player:getPosition()
    return self.collision:getWorldCenter()
end

function Player:draw()
    -- draw bullets
    for _, bullet in ipairs(self.bullets) do
        love.graphics.setColor(1, 0, 0, 1)
        --love.graphics.circle("fill", bullet.x, bullet.y, settings.playerSize/2)
        local bulletRadius = bullet.collision:getFixtures()[1]:getShape():getRadius()
        love.graphics.circle('fill', bullet.collision:getX(), bullet.collision:getY(), bulletRadius)
    end

    -- draw player
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(
        self.sprite,
        self.collision:getX(), self.collision:getY(),
        self.collision:getAngle(),
        1, 1,
        self.sprite:getWidth() / 2, self.sprite:getHeight() / 2
    )
end

return Player