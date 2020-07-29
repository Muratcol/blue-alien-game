
require 'Util'

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

local SCROLL_SPEED = 62

function Map:init()
    self.spritesheet = love.graphics.newImage('graphics/spritesheet.png')
    self.tileWidth = 16
    self.tileHeight = 16
    self.mapWidth = 30
    self.mapHeight = 28
    self.tiles = {}

    -- Camera offsets
    self.camX  = 0
    self.camY = -3

    self.tileSprites = generateQuads(self.spritesheet, self.tileWidth, self.tileHeight)

    self.mapWidthPixels = self.mapWidth * self.tileWidth
    self.mapHeightPixels = self.mapHeight * self.tileHeight

    -- for loops first arg start, second arg end point and third arg is iteration. default + 1
    for y = 1, self.mapHeight do
        for x = 1,  self.mapWidth do
            self:setTile(x, y, TILE_EMPTY)
        end
    end

    for y = self.mapHeight / 2, self.mapHeight do
        for x = 1, self.mapWidth do 
            self:setTile(x, y, TILE_BRICK)
        end
    end

    -- Begin generating the terrain using vertical scan lines
    local x = 1
    while x < self.mapWidth do

        -- 2% change to generate a cloud
        -- make sure we're 2 tiles from edge at least
        if x < self.mapWidth - 2 then
            if math.random(20) == 1 then
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
end


-- filling the map with empty tiles
function Map:setTile(x, y, tile)
    self.tiles[(y - 1) * self.mapWidth + x] = tile
end

function Map:getTile(x, y)
    return self.tiles[(y - 1) * self.mapWidth + x]
end


function Map:update(dt)
    if love.keyboard.isDown('w') then
        -- Up movement
        self.camY = math.max(0, math.floor(self.camY + -SCROLL_SPEED * dt))
    end

    if love.keyboard.isDown('s') then
        -- Down movement
        self.camY = math.min(self.mapHeightPixels - VIRTUAL_HEIGHT, math.floor(self.camY + SCROLL_SPEED * dt))
    end

    if love.keyboard.isDown('d') then
        -- Right movement
        self.camX = math.min(self.mapWidthPixels - VIRTUAL_WIDTH, math.floor(self.camX + SCROLL_SPEED * dt)) 
    end

    if love.keyboard.isDown('a') then
        -- Left movement
        self.camX = math.max(0, math.floor(self.camX + -SCROLL_SPEED * dt))
    end
    -- self.camX = self.camX + SCROLL_SPEED * dt
end

function Map:render()
    for y = 1, self.mapHeight do 
        for x = 1, self.mapWidth do
            -- love.graphics.draw(texture, quad, x, y)
            love.graphics.draw(self.spritesheet, self.tileSprites[self:getTile(x, y)],
                (x - 1) * self.tileWidth, (y - 1) * self.tileHeight)
        end
    end
end