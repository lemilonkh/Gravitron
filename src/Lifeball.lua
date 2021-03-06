local Lifeball = class 'Lifeball'
local physics = require 'src.physics'

function Lifeball:init(spriteName, x, y)
    self.isAlive = true
    self.sprite = love.graphics.newImage('sprites/' .. spriteName .. '_lifeball.png')
    self.width, self.height = self.sprite:getDimensions()
    self.radius = self.sprite:getWidth() / 2
    self.collision = physics.makeCircle(self.x, self.y, self.radius, true, self)
    self.collision:setUserData(self)
end

function Lifeball:onCollision(other)
    local userData = other:getUserData()
    if userData and userData:instanceOf(Player) then
        userData:activatePowerup(self)
        self:death()
    end
end

function Lifeball:death()
    self.isAlive = false
end

function Lifeball:draw(player, lifeballNum, angleOffset)
    if not self.isAlive then return end

    local alpha = ((2 * math.pi) / #player.lifeballs) * lifeballNum - 1 + angleOffset
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(
        self.sprite,
        player.collision:getX() + math.cos(alpha) * settings.lifeballDistance, 
        player.collision:getY() + math.sin(alpha) * settings.lifeballDistance,
        player.collision:getAngle(),
        0.5, 0.5,
        self.radius, self.radius
    )
end

return Lifeball