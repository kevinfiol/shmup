local sodapop = require 'lib.sodapop'
local lume = require 'lib.lume'
local Object = require 'lib.classic'

local Sprite = Object:extend()

function Sprite:new(x, y, config)
    self.x = x
    self.y = y
    self.soda_sprite = nil
    self.flip = { x = false, y = false }

    config.offset = config.offset or {}
    local new_fn = config.animated and sodapop.newAnimatedSprite or sodapop.newSprite
    local w_half = config.width / 2
    local h_half = config.height / 2

    self.soda_sprite = new_fn(self.x + w_half, self.y + h_half)
    self.soda_sprite:setAnchor(function()
        return self.x + w_half - (config.offset.x or 0),
            self.y + h_half - (config.offset.y or 0)
    end)

    self.soda_sprite.flipX = config.flipX or false
    self.soda_sprite.flipY = config.flipY or false
    self.flip.x = self.soda_sprite.flipX
    self.flip.y = self.soda_sprite.flipY

    if config.animations then
        for name, animation in pairs(config.animations) do
            self.soda_sprite:addAnimation(name, lume.extend({
                image = config.image,
                frameWidth = config.width,
                frameHeight = config.height,
                frames = {}
            }, animation))
        end

        self.soda_sprite:switch(config.initial)
    end
end

function Sprite:update(dt, x, y)
    self.x, self.y = x, y
    self.soda_sprite:update(dt)
end

function Sprite:draw()
    self.soda_sprite:draw()
end

function Sprite:flipX()
    self.soda_sprite.flipX = not self.soda_sprite.flipX
    self.flip.x = self.soda_sprite.flipX
end

function Sprite:flipY()
    self.soda_sprite.flipY = not self.soda_sprite.flipY
    self.flip.y = self.soda_sprite.flipY
end

function Sprite:switch(animation)
    self.soda_sprite:switch(animation)
end

return Sprite