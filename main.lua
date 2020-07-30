
-- https://github.com/vrld/hump/blob/master/class.lua
Class = require 'class'
-- https://github.com/Ulydev/push
push = require 'push'


WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

require 'Util'
require 'Map'



function love.load()
    
    math.randomseed(os.time())

    map = Map()

    smallFont = love.graphics.newFont('Daydream.ttf', 8)
    love.window.setTitle("Murat's Blue Alien Game")
    love.graphics.setDefaultFilter('nearest', 'nearest')
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = false,
        vsync = true
    })

    love.keyboard.keysPressed = {}
end

function love.update(dt)
    map:update(dt)

    love.keyboard.keysPressed = {}
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end
    love.keyboard.keysPressed[key] = true
end

function love.keyboard.wasPressed(key)
    return love.keyboard.keysPressed[key]
end

function love.draw()
    push:apply('start')
    love.graphics.translate(math.floor( -map.camX + 0.5), math.floor(-map.camY + 0.5))
    love.graphics.clear(108/255, 140/255, 255/255, 255/255)
    -- love.graphics.print('Hello World')
    map:render()
    push:apply('end')
end