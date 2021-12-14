local Object = require 'lib.classic'

local Clouds = Object:extend()

function Clouds:new()
    local bg_img = love.graphics.newImage('assets/bg.png')
    local bg_quad = love.graphics.newQuad(0, 0, 64, 64, bg_img:getDimensions())

    local tile_width = 64
    local bg_width = 9
    local bg_height = 5
    local bg_batch = love.graphics.newSpriteBatch(bg_img, bg_width * bg_height)

    self.bg = {
        tile = { img = bg_img, height = tile_width, width = tile_width },
        offset = { x = 0, y = 0 },
        quad = bg_quad,
        batch = bg_batch,
        x = 0,
        y = 0,
        width = bg_width, -- in tiles
        height = bg_height, -- in tiles
        pixel_width = bg_width * tile_width,
        pixel_height = bg_height * tile_width,
    }
end

function Clouds:draw()
    local half_tile_width = self.bg.tile.width / 2
    local increment = -(half_tile_width / (self.bg.tile.width)) * 1

    if self.bg.x == -(self.bg.pixel_width) then
        self.bg.x = 0
    end

    self.bg.x = self.bg.x + increment
    self.bg.batch:clear()
    local bg_double_width = self.bg.width * 2 -- let's draw the bg twice, one next to the other

    for i = 1, bg_double_width do
        for j = 1, self.bg.height do
            local x = (64 * i) - 64 + self.bg.offset.x + self.bg.x
            local y = (64 * j) - 64 + self.bg.offset.y + self.bg.y
            self.bg.batch:add(self.bg.quad, x, y)
        end
    end

    self.bg.batch:flush()
    love.graphics.draw(self.bg.batch)
end

function Clouds:destroy()
    self.bg = nil
end

return Clouds
