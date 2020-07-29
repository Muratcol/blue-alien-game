Player = Class{}

require 'Animation'
MOVE_SPEED = 80

function Player:init(map)
    self.width = 16
    self.height = 20

    self.x = map.tileWidth * 10
    self.y = map.tileHeight * (map.mapHeight / 2 - 1) - self.height

    self.texture = love.graphics.newImage('graphics/blue_alien.png')
    self.frames = generateQuads(self.texture, 16, 20)

    self.state = 'idle'

    self.animations = {
        ['idle'] = Animation {
            texture = self.texture,
            frames = {
                self.frames[1]
            },
            interval = 1
        },
        ['walking'] = Animation {
            texture = self.texture,
            frames = {
                self.frames[9], self.frames[10], self.frames[11]
            },
            interval = 0.15
        }
    }

    self.animation = self.animations['idle']

    self.behaviours = {
        ['idle'] = function(dt)
            if love.keyboard.isDown('a') then
                self.x = self.x - MOVE_SPEED * dt
                self.animation = self.animations['walking']
            elseif love.keyboard.isDown('d') then          
                self.x = self.x + MOVE_SPEED * dt
                self.animation = self.animations['walking']
            else
                self.animation = self.animations['idle']
            end
        end,

        ['walking'] = function(dt)
            if love.keyboard.isDown('a') then
                self.x = self.x - MOVE_SPEED * dt
                self.animation = self.animations['walking']
            elseif love.keyboard.isDown('d') then
                self.x = self.x + MOVE_SPEED * dt
                self.animation = self.animations['walking']
            else
                self.animation = self.animations['idle']
            end
        end
    }
end

function Player:update(dt)

    self.behaviours[self.state](dt)
    self.animation:update(dt)

    
end

function Player:render()
    love.graphics.draw(self.texture, self.animation:getCurrentFrame(), math.floor(self.x), math.floor(self.y))
end