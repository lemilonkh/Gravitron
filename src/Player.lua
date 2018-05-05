local Player = class "Player"
local physics = require "src.physics"
local vector = require "libs.hump.vector"

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

return Player