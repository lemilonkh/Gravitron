local Powerup = class 'Powerup'
local physics = require 'src.physics'

function Powerup:init(x, y, type)
    self.x, self.y = x, y
    self.type = type
    self.isAlive = true
    self.sprite = love.graphics.newImage('sprites/' .. type .. '.png')
    self.radius = self.sprite:getWidth() / 2
    self.collision = physics.makeCircle(self.x, self.y, self.radius, true, self)
end

function Powerup:onCollision(other, collision)
    local userData = other:getUserData()
    if userData and userData:instanceOf(Player) then
        userData:activatePowerup(self)
        self:death()
    end
end

function Powerup:death()
    self.isAlive = false
    self.collision:destroy()
end

function Powerup:draw()
    if not self.isAlive then return end

    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(
        self.sprite,
        self.collision:getX(), self.collision:getY(),
        self.collision:getAngle(),
        1, 1,
        self.radius, self.radius
    )
end

return Powerup