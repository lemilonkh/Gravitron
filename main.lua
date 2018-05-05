class = require 'libs.30log'
vector = require 'libs.hump.vector'
local Player = require 'src.Player'
local physics = require 'src.physics'
local controls = require 'src.controls'

settings = {
    pixelsPerMeter = 35,
    movementSpeed = 100, -- acceleration in px per second
    turningSpeed = math.pi / 2, -- rad per second
    planetCount = 10,
    objectCount = 20,
    maxGravityDistance = 3, -- factor for radius of maximum gravity excertion
    bulletSize = 20
}

function love.load()
    -- make sure math.random actually returns different values every time the game is started
    math.randomseed(os.time())

    -- make scaled up sprites pixel out nicely
    love.graphics.setDefaultFilter('nearest')

    local musicTrack = love.audio.newSource('sounds/Okatoka.mp3', 'static')
    crashSounds = {}
    for i = 1, 6 do
        local crashSound = love.audio.newSource('sounds/crash' .. i .. '.mp3', 'static')
        table.insert(crashSounds, crashSound)
    end
    musicTrack:setLooping(true)
    --musicTrack:play()

    local backgroundFiles = love.filesystem.getDirectoryItems('backgrounds')
    local randomBackgroundFile = backgroundFiles[math.random(#backgroundFiles)]
    backgroundImage = love.graphics.newImage('backgrounds/' .. randomBackgroundFile)

    isRunning = true
    love.physics.setMeter(settings.pixelsPerMeter)
    world = love.physics.newWorld(0, 0, true)
    planets = {} -- static colliders
    objects = {} -- dynamic objects
    world:setCallbacks(beginContact, endContact, preSolve, postSolve)

    players = {
        Player('delta_ship', 150, 150, controls[1]),
        Player('omega_ship', love.graphics.getHeight() - 150, love.graphics.getWidth() - 150, controls[2])
    }

    -- load planet sprites
    local planetNames = {'earth', 'mars', 'neptun', 'venus', 'sun'}
    planetSprites = {}
    for _, planetName in ipairs(planetNames) do
        local planetSprite = love.graphics.newImage('sprites/' .. planetName .. '.png')
        table.insert(planetSprites, planetSprite)
    end
    
    for i = 1, settings.planetCount do
        local radius = love.math.random(50, 100)
        addPlanet(love.math.random() * love.graphics.getWidth(), love.math.random() * love.graphics.getHeight(), radius)
    end

    for i = 1, settings.objectCount do
        addObject(love.math.random() * love.graphics.getWidth(), love.math.random() * love.graphics.getHeight(), 10)
    end
end

function beginContact(a, b, coll)
    local i = love.math.random( 6 )
    crashSounds[i]:play()
end
 
function endContact(a, b, coll)
 
end
 
function preSolve(a, b, coll)
 
end
 
function postSolve(a, b, coll, normalimpulse, tangentimpulse)
 
end

function addPlanet(x, y, r)
    local planet = {
        x = x,
        y = y,
        r = r,
        collision = physics.makeCircle(x, y, r, false)
    }
    table.insert(planets, planet)
end

function addObject(x, y, r)
    local object = {collision = physics.makeCircle(x, y, r, true)}
    table.insert(objects, object)
end

function love.update(dt)
    if not isRunning then return end

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
        love.graphics.setColor(0.2, 0.8, 0.7)
        drawCircle(object.collision)
    end

    for _, player in ipairs(players) do
        player:draw()
    end

    love.graphics.pop()
end
