local Player = class 'Player'
local physics = require 'src.physics'

function Player:init(x, y)
    self.sprite = love.graphics.newImage('sprites/delta_ship.png')
    self.width, self.height = self.sprite:getDimensions()
    self.collision = physics.makeTriangle(150, 150, self.width, self.height, true)
    self.bullets = {}
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
    local deltaAngle, deltaSpeed = 0, 0
    if love.keyboard.isDown('up') then
        deltaSpeed = -settings.movementSpeed
    end
    if love.keyboard.isDown('down') then
        deltaSpeed = settings.movementSpeed
    end
    if love.keyboard.isDown('left') then
        deltaAngle = -settings.turningSpeed
    end
    if love.keyboard.isDown('right') then
        deltaAngle = settings.turningSpeed
    end

    local playerAngle = self.collision:getAngle() + deltaAngle * dt
    self.collision:setAngle(playerAngle)

    local impulseX, impulseY = math.cos(playerAngle) * deltaSpeed * dt, math.sin(playerAngle) * deltaSpeed * dt
    self.collision:applyLinearImpulse(impulseX, impulseY)
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