local Powerup = class 'Powerup'
local physics = require 'src.physics'

function Powerup:init(x, y, type)
    self.x, self.y = x, y
    self.isAlive = true
    self.sprite = love.graphics.newImage('sprites/' .. type .. '.png')
    self.radius = self.sprite:getWidth()
    self.type = type
    self.collision = physics.makeCircle(self.x, self.y, self.radius, true)
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
end

function Powerup:draw()
    if not self.isAlive then return end

    love.graphics.draw(
        self.sprite,
        self.x, self.y,
        self.collision:getAngle(),
        1, 1,
        self.radius, self.radius
    )
end

return Powerup