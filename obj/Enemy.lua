local GameObject = require 'engine.GameObject'
local SimpleCollider = require 'engine.SimpleCollider'
local Sprite = require 'engine.Sprite'

local Enemy = GameObject:extend()

function Enemy:new(area, x, y, opts)
    Enemy.super.new(self, 'Enemy', area, x, y, opts)
    opts = opts or {}

    self.sprite = nil
    self.speed = 1.2

    self.collider = SimpleCollider(self, self.x, self.y, 8, 9, {
        collision_class = opts.collision_class
    })

    self.sprite = Sprite(self.x, self.y, {
        image = love.graphics.newImage('assets/gacko.png'),
        animated = true,
        width = 16,
        height = 16,
        offset = { x = 4, y = 7 },
        initial = 'idle',
        animations = {
            idle = {
                frames = { { 1, 1, 1, 1, 1 } }
            }
        }
    })
end

function Enemy:update(dt)
    Enemy.super.update(self, dt)
    self.collider:update()
    self.sprite:update(dt, self.x, self.y)
end

function Enemy:draw()
    self.sprite:draw()
end

return Enemy
