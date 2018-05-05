local Player = class 'Player'
local physics = require 'src.physics'
local Lifeball = require 'src.Lifeball'
local util = require 'src.util'

function Player:init(spriteName, x, y, controls)
    self.x, self.y = x, y
    self.controls = controls
    self.sprite = love.graphics.newImage('sprites/' .. spriteName .. '.png')
    self.width, self.height = self.sprite:getDimensions()

    if spriteName == 'delta_ship' then
        self.collision = physics.makeTriangle(self.x, self.y, self.width, self.height, true, self)
    elseif spriteName == 'omega_ship' then
        self.collision = physics.makeDiamond(self.x, self.y, self.width, self.height, true, self)
    end

    self.lifeballs = {}
    for i = 1, settings.lifeballCount do
        table.insert(self.lifeballs, Lifeball(spriteName, self.x, self.y))
    end

    self.collision:setMass(0.5)
    self.collision:setLinearDamping(0.5)
    self.collision:setUserData(self)
    --TODO: Default ship, if none of the spriteName matches
    self.bullets = {}

    self.movementSpeed = settings.movementSpeed
    self.isGhost = false
    self.isShielded = false

    self.color = {1, 1, 1, 1}
    self.effectSprite = nil
    self.effectSprites = {
        shield = love.graphics.newImage('sprites/energy_shield.png'),
        glow = love.graphics.newImage('sprites/glow.png')
    }

    self.lifeballTimer = 0
end

function Player:fire()
    local bullet = {}
    bullet.x, bullet.y = self.collision:getWorldCenter()
    bullet.collision = physics.makeCircle(bullet.x, bullet.y, 10, true)
    table.insert(self.bullets, bullet)
    local direction = vector(self.collision:getLinearVelocity()):normalized() * 100
    bullet.collision:applyLinearImpulse(direction.x, direction.y)
    shotSounds[math.random(8)]:play()
end

function Player:onCollision(otherFixture)
    local other = otherFixture:getUserData()
    if not other then return end

    -- when two players collide, the slowest one takes the damage
    if other:instanceOf(Player) then
        local ownVelocity = vector(self.collision:getLinearVelocity()):len2()
        local otherVelocity = vector(other.collision:getLinearVelocity()):len2()

        if ownVelocity < otherVelocity then
            self:takeDamage()
        elseif otherVelocity > ownVelocity then
            other:takeDamage()
        else
            self:takeDamage()
            other:takeDamage()
        end
    end

    if other.isPlanet then
        self:takeDamage()
    end
end

function Player:activatePowerup(powerup)
    if powerup.type == 'lightning' then
        lightningSounds[math.random(3)]:play()
        self.movementSpeed = 2 * settings.movementSpeed
        self.effectSprite = self.effectSprites.glow
        self.effectColor = {0.8, 1, 0, 1}
        Timer.after(settings.powerupTime, function()
            self.movementSpeed = settings.movementSpeed
            self.effectSprite = nil
        end)
    elseif powerup.type == 'ghost' then
        ghostSounds[math.random(3)]:play()
        self.isGhost = true
        self.color = {1, 1, 1, 0.5}
        Timer.after(settings.powerupTime, function()
            self.isGhost = false
            self.color = {1, 1, 1, 1}
        end)
    elseif powerup.type == 'shield' then
        shieldSounds[math.random(3)]:play()
        self.isShielded = true
        self.effectSprite = self.effectSprites.shield
        self.effectColor = {0, 0.5, 0.8, 0.7}
        Timer.after(settings.powerupTime, function()
            self.isShielded = false
            self.effectSprite = nil
        end)
    end
end

function Player:takeDamage()
    util.removeValue(self.lifeballs, self.lifeballs[1])

    if #self.lifeballs <= 0 then
        self:death()
    end
end

function Player:death()
    print('Player died!')
end

function Player:update(dt)
    self.controls:update()

    local deltaAngle, deltaSpeed = self.controls:get('move')
    deltaAngle = deltaAngle * settings.turningSpeed * dt
    deltaSpeed = deltaSpeed * self.movementSpeed * dt

    local playerAngle = self.collision:getAngle() + deltaAngle
    self.collision:setAngle(playerAngle)

    -- reset angular velocity so the player doesn't have to fight it
    if math.abs(deltaAngle) > 0 then
        self.collision:setAngularVelocity(0)
    end

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
        self.collision:setPosition(warpedPosition.x, warpedPosition.y)
    end

    if self.controls:pressed('action') then
        self:fire()
    end

    self.lifeballTimer = self.lifeballTimer + dt
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
        love.graphics.setColor(0.8, 0.5, 0.2)
        local bulletRadius = bullet.collision:getFixtures()[1]:getShape():getRadius()
        love.graphics.circle('fill', bullet.collision:getX(), bullet.collision:getY(), bulletRadius)
    end

    -- draw powerup effects
    if self.effectSprite then
        love.graphics.setColor(self.effectColor or {1, 1, 1, 1})
        love.graphics.draw(
            self.effectSprite,
            self.collision:getX(), self.collision:getY(),
            self.collision:getAngle(),
            1, 1,
            self.effectSprite:getWidth() / 2, self.effectSprite:getHeight() / 2
        )
    end

    -- draw player
    love.graphics.setColor(self.color)
    love.graphics.draw(
        self.sprite,
        self.collision:getX(), self.collision:getY(),
        self.collision:getAngle(),
        1, 1,
        self.sprite:getWidth() / 2, self.sprite:getHeight() / 2
    )

    -- draw lifeballs
    local angleOffset = 2 * math.pi * ((self.lifeballTimer / settings.lifeballRotationDuration) % 1)
    for i, lifeball in ipairs (self.lifeballs) do
        lifeball:draw(self, i, angleOffset)
    end
end

return Player
