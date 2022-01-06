local GameObject = require 'engine.GameObject'
local SimpleCollider = require 'engine.SimpleCollider'
local sodapop = require 'lib.sodapop'

local Enemy = GameObject:extend()

function Enemy:new(area, x, y, opts)
    Enemy.super.new(self, 'Enemy', area, x, y, opts)
    opts = opts or {}

    self.sprite = nil
    self.speed = 1.2

    self.collider = SimpleCollider(self, self.x, self.y, 8, 9, {
        debug = false,
        collision_class = opts.collision_class
    })

    self:setSprite({
        image = love.graphics.newImage('assets/gacko.png'),
        width = 16,
        height = 16
    })

    self.sprite.flipX = opts.flipX or false
end

function Enemy:update(dt)
    Enemy.super.update(self, dt)
    self.collider:update()
    self.sprite:update(dt)
end

function Enemy:draw()
    self.sprite:draw()
end

function Enemy:setSprite(sprite_config)
    local w_half = sprite_config.width / 2
    local h_half = sprite_config.height / 2

    self.sprite = sodapop.newAnimatedSprite(
        self.x + w_half,
        self.y + h_half
    )

    self.sprite:setAnchor(function()
        return self.x + w_half - 4, self.y + h_half - 7
    end)

    self.sprite:addAnimation('idle', {
        image = sprite_config.image,
        frameWidth = sprite_config.width,
        frameHeight = sprite_config.height,
        frames = { { 1, 1, 1, 1, 1 } }
    })
end

return Enemy
