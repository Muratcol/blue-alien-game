
require 'Util'
require 'Player'

Map = Class{}

TILE_BRICK = 1
TILE_EMPTY = 4

CLOUD_LEFT = 6
CLOUD_RIGHT = 7

BUSH_LEFT = 2
BUSH_RIGHT = 3

MUSHROOM_TOP = 10
MUSHROOM_BOTTOM = 11

JUMP_BLOCK = 5
JUMP_BLOCK_HIT = 9
local SCROLL_SPEED = 62

function Map:init()
    self.spritesheet = love.graphics.newImage('graphics/spritesheet.png')
    self.music = love.audio.newSource('sounds/music.wav', 'static')
    self.tileWidth = 16
    self.tileHeight = 16
    self.mapWidth = 30
    self.mapHeight = 28
    self.tiles = {}
    -- Player(self) means send,ng map object to Player:init(map)
    self.player = Player(self)

    -- Camera offsets
    self.camX  = 0
    self.camY = -3

    self.tileSprites = generateQuads(self.spritesheet, self.tileWidth, self.tileHeight)

    self.mapWidthPixels = self.mapWidth * self.tileWidth
    self.mapHeightPixels = self.mapHeight * self.tileHeight

    -- for loops first arg start, second arg end point and third arg is iteration. default + 1
 -- first, fill map with empty tiles
    for y = 1, self.mapHeight do
        for x = 1, self.mapWidth do
            
            -- support for multiple sheets per tile; storing tiles as tables 
            self:setTile(x, y, TILE_EMPTY)
        end
    end

    -- Begin generating the terrain using vertical scan lines
    local x = 1
    while x < self.mapWidth do

        -- 2% change to generate a cloud
        -- make sure we're 2 tiles from edge at least
        if x < self.mapWidth - 2 then
            if math.random(10) == 1 then
                -- choose a random vertical sport above where blocks/pipes generate
                local cloudStart = math.random(self.mapHeight / 2 - 6)

                self:setTile(x, cloudStart, CLOUD_LEFT)
                self:setTile(x + 1, cloudStart, CLOUD_RIGHT)
            end
        end

        -- 5% chance to generate a mushroom
        if math.random(20) == 1 then
            -- left side of pipe
            self:setTile(x, self.mapHeight / 2 - 2, MUSHROOM_TOP)
            self:setTile(x, self.mapHeight / 2 - 1, MUSHROOM_BOTTOM)

            -- creates column of tiles going to bottom of map
            for y = self.mapHeight / 2, self.mapHeight do
                self:setTile(x, y, TILE_BRICK)
            end
            -- next vertical scan line
            x = x + 1
        
        -- 10% chance to generate bush, being sure to generate away from edge
        elseif math.random(10) == 1 and x < self.mapWidth - 3 then
            local bushLevel = self.mapHeight / 2 - 1

            -- place bush component and then column of bricks
            self:setTile(x, bushLevel, BUSH_LEFT)
            for y = self.mapHeight / 2, self.mapHeight do
                self:setTile(x, y, TILE_BRICK)
            end
            x = x + 1

            self:setTile(x, bushLevel, BUSH_RIGHT)
            for y = self.mapHeight / 2, self.mapHeight do
                self:setTile(x, y, TILE_BRICK)
            end
            x = x + 1
        
        -- 10% chance to not generate anything, creating a gap
        elseif math.random(10) ~= 1 then

            -- creates column of tiles going to bottom of map
            for y = self.mapHeight / 2, self.mapHeight do
                self:setTile(x, y, TILE_BRICK)
            end

            -- chance to create a block for Alien to hit
            if math.random(15) == 1 then
                self:setTile(x, self.mapHeight / 2 - 4, JUMP_BLOCK)
            end

            -- next vertical scan line
            x = x + 1
        else
            -- increment X so we skip two scan lines, creating a 2-tile gap
            x = x + 2
        end
    end

    -- start background music
    self.music:setLooping(true)
    self.music:setVolume(0.25)
    self.music:play()
end


-- filling the map with empty tiles
function Map:setTile(x, y, id)
    self.tiles[(y - 1) * self.mapWidth + x] = id
end

-- returns an integer value for the tile at a given x-y coordinate
function Map:getTile(x, y)
    return self.tiles[(y - 1) * self.mapWidth + x]
end

function Map:tileAt(x, y)
    return {
        x = math.floor(x / self.tileWidth) + 1,
        y = math.floor(y / self.tileHeight) + 1,
        id = self:getTile(math.floor(x / self.tileWidth) + 1, math.floor(y / self.tileHeight) + 1)
    }
end

-- Return whether a given tile is collidable
function Map:collides(tile)
    -- define our collidable tiles
    local collidables = {
        TILE_BRICK, JUMP_BLOCK, JUMP_BLOCK_HIT,
        MUSHROOM_TOP, MUSHROOM_BOTTOM
    }

    -- iterate and return true if our tile type matches
    for _, v in ipairs(collidables) do
        if tile.id == v then
            return true
        end
    end

    return false
end


function Map:update(dt)
    self.camX = math.max(0, 
        math.min(self.player.x - VIRTUAL_WIDTH / 2,
            math.min(self.mapWidthPixels - VIRTUAL_WIDTH, self.player.x)))

    self.player:update(dt)
end

function Map:render()
    for y = 1, self.mapHeight do 
        for x = 1, self.mapWidth do
            -- love.graphics.draw(texture, quad, x, y)
            love.graphics.draw(self.spritesheet, self.tileSprites[self:getTile(x, y)],
                (x - 1) * self.tileWidth, (y - 1) * self.tileHeight)
        end
    end

    self.player:render()
end