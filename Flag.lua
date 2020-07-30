Flag = Class{}

require 'Animation'


function Flag:init(map)

    self.texture = love.graphics.newImage('graphics/spritesheet.png')

    self.frames = generateQuads(self.texture, 16, 16)

    self.width = 16
    self.height = 16

    self.x = map.tileWidth * 10 + (map.mapWidth / 2 + 741)
    self.y = map.tileHeight * (map.mapHeight / 2 - 8) - self.height

    self.map = map
    self.animations = {
        ['wave'] = Animation {
            texture = self.texture,
            frames = {
                self.frames[13], self.frames[14]
            },
            interval = 0.5
        }
    }

    self.animation = self.animations['wave']

end

function Flag:update(dt)
    -- self.behaviors['wave'](dt)
    self.animation:update(dt)
end

function Flag:render()
    -- love.graphics.draw(self.texture, self.animation:getCurrentFrame(),
    -- math.floor(map.mapWidth / 2 + 16), math.floor(map.mapHeight / 2 - 8),
    -- math.floor(self.x + self.width / 2), math.floor(self.y + self.height / 2),

    love.graphics.draw(self.texture, self.animation:getCurrentFrame(),
    math.floor(self.x + self.width / 2), math.floor(self.y + self.height / 2),
    0, 1, 1)
end