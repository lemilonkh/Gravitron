class = require 'libs.30log'
vector = require 'libs.hump.vector'
Player = require 'src.Player'
Powerup = require 'src.Powerup'
Timer = require 'libs.hump.timer'
local physics = require 'src.physics'
local controls = require 'src.controls'

settings = {
    planetGridColumns = 6,
    planetGridRows = 4,
    planetProbability = 60, -- percent
    pixelsPerMeter = 35,
    movementSpeed = 100, -- acceleration in px per second
    turningSpeed = math.pi, -- rad per second
    planetCount = 10,
    objectCount = 20,
    maxGravityDistance = 3, -- factor for radius of maximum gravity excertion
    bulletSize = 20,
    lifeballCount = 5,
    lifeballDistance = 64, -- distance from player ship
    powerupTime = 5, -- seconds after pickup
    powerupSpawnInterval = 10, -- seconds between new powerups being spawned
    lifeballRotationDuration = 5
}

function love.load()
    isOver = false
        -- make sure math.random actually returns different values every time the game is started
    math.randomseed(os.time())

    -- make scaled up sprites pixel out nicely
    love.graphics.setDefaultFilter('nearest')

    local musicTrack = love.audio.newSource('sounds/LeMilonkh_Where_No_Man_Has_Gone_Before.ogg', 'stream')
    crashSounds = {}
    for i = 1, 6 do
        local crashSound = love.audio.newSource('sounds/crash' .. i .. '.mp3', 'static')
        table.insert(crashSounds, crashSound)
    end
    ghostSounds = {}
    for i = 1, 3 do
        local ghostSound = love.audio.newSource('sounds/ghost' .. i .. '.wav', 'static')
        table.insert(ghostSounds, ghostSound)
    end
    lightningSounds = {}
    for i = 1, 3 do
        local lightningSound = love.audio.newSource('sounds/lightning' .. i .. '.wav', 'static')
        table.insert(lightningSounds, lightningSound)
    end
    shieldSounds = {}
    for i = 1, 3 do
        local shieldSound = love.audio.newSource('sounds/shield' .. i .. '.wav', 'static')
        table.insert(shieldSounds, shieldSound)
    end
    shotSounds = {}
    for i = 1, 8 do
        local shotSound = love.audio.newSource('sounds/shot' .. i .. '.wav', 'static')
        table.insert(shotSounds, shotSound)
    end
    musicTrack:setLooping(true)
    musicTrack:play()

    local backgroundFiles = love.filesystem.getDirectoryItems('backgrounds')
    local randomBackgroundFile = backgroundFiles[love.math.random(#backgroundFiles)]
    backgroundImage = love.graphics.newImage('backgrounds/' .. randomBackgroundFile)

    isRunning = true
    planets = {} -- static colliders
    objects = {} -- dynamic objects

    -- setup Love's physics engine
    physics.init()

    players = {
        Player('delta_ship', 150, 150, controls[1]),
        Player('omega_ship', love.graphics.getHeight() - 150, love.graphics.getWidth() - 150, controls[2])
    }

    powerups = {}
    Timer.every(settings.powerupSpawnInterval, function()
        local types = {'lightning', 'shield', 'ghost' }
        local x, y = getRandomPosition()
        local powerup = Powerup(x, y, types[love.math.random(3)])
        table.insert(powerups, powerup)
    end)

    -- load planet sprites
    local planetNames = {'earth', 'mars', 'neptun', 'venus', 'sun'}
    planetSprites = {}
    for _, planetName in ipairs(planetNames) do
        local planetSprite = love.graphics.newImage('sprites/' .. planetName .. '.png')
        table.insert(planetSprites, planetSprite)
    end

    asteroidSprite = love.graphics.newImage('sprites/asteroid.png')

    -- distribute planets randomly in a grid pattern
    local planetGridColumnSize = love.graphics.getWidth() / settings.planetGridColumns
    local planetGridRowSize = love.graphics.getHeight() / settings.planetGridRows

    for x = 1, settings.planetGridColumns - 1 do
        for y = 1, settings.planetGridRows - 1 do
            if love.math.random(0, 100) < settings.planetProbability then
                local radius = love.math.random(50, 100)
                local posX = x * planetGridColumnSize + love.math.random(-planetGridColumnSize / 8, planetGridColumnSize / 8)
                local posY = y * planetGridRowSize + love.math.random(-planetGridRowSize / 8, planetGridRowSize / 8)
                addPlanet(posX, posY, radius)
            end
        end
    end

    for i = 1, settings.objectCount do
        local x, y = getRandomPosition()
        addObject(x, y, 10)
    end
end

function getRandomPosition()
    local x, y = love.math.random() * love.graphics.getWidth(), love.math.random() * love.graphics.getHeight()
    return x, y
end

local Planet = class "Planet"

function addPlanet(x, y, r)
    local planet = Planet()
    planet.x, planet.y, planet.r = x, y, r
    planet.isPlanet = true
    planet.collision = physics.makeCircle(x, y, r, false, planet)
    table.insert(planets, planet)
end

function addObject(x, y, r)
    local object = {collision = physics.makeCircle(x, y, r, true)}
    object.x, object.y, object.r = x, y, r
    table.insert(objects, object)
end

function love.update(dt)
    if not isRunning then return end

    Timer.update(dt)

    for i = 1, #players do
        players[i]:update(dt)
    end
    world:update(dt)
    physics.applyGravityForces(players, objects, planets)
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    elseif key == 'f' then
        love.window.setFullscreen(not love.window.getFullscreen())
    elseif key == 'r' then
        love.load() -- reload game
    elseif key == 'p' then
        isRunning = not isRunning
    end
end

function drawCircle(body)
    local radius = body:getFixtures()[1]:getShape():getRadius()
    love.graphics.circle('fill', body:getX(), body:getY(), radius)
end

function love.draw()
    if isOver then
        Player:death()
    end

    love.graphics.push()
    local scale = love.graphics.getDPIScale()
    love.graphics.scale(scale)

    love.graphics.setColor(1, 1, 1)

    -- draw background image
    local backgroundScale = (love.graphics.getWidth() / scale) / backgroundImage:getWidth()
    love.graphics.draw(backgroundImage, 0, 0, 0, backgroundScale, backgroundScale)

    -- draw static planets
    for i, planet in ipairs(planets) do
        --love.graphics.setColor(0.7, 0.2, 0.2)
        --drawCircle(planet.collision)
        love.graphics.setColor(1, 1, 1)
        local planetSprite = planetSprites[(i % #planetSprites) + 1]
        love.graphics.draw(planetSprite, planet.x - planet.r, planet.y - planet.r, 0, planet.r/52*2, planet.r/52*2)
    end

    -- draw dynamic objects
    for _, object in ipairs(objects) do
        love.graphics.setColor(1, 1, 1)
        --drawCircle(object.collision)
        love.graphics.draw(asteroidSprite, object.collision:getX(), object.collision:getY(), object.collision:getAngle(), object.r/52*2, object.r/52*2, object.r*2, object.r*2)

    end

    for _, powerup in ipairs(powerups) do
        powerup:draw()
    end

    for _, player in ipairs(players) do
        player:draw()

        if not player.isAlive then
            love.graphics.setColor(1, 1, 1)
            local font = love.graphics.newFont(400)
            love.graphics.setFont(font)
            love.graphics.printf("GAME OVER", 0, 0, love.graphics.getWidth(), 'center')
        end
    end

    love.graphics.pop()
end
