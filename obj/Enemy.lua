local GameObject = require 'engine.GameObject'
local SimpleCollider = require 'engine.SimpleCollider'
local Sprite = require 'engine.Sprite'
local Timer = require 'lib.timer'
local utils = require 'engine.utils'

local Enemy = GameObject:extend()

function Enemy:new(area, x, y, opts)
    Enemy.super.new(self, 'Enemy', area, x, y, opts)
    opts = opts or {}

    self.sprite = nil
    self.vector = { x = nil, y = nil }
    self.timer = Timer()

    local speeds = {0.16, 0.18, 0.20}
    local speed_idx = math.floor(utils.random(1, 4))
    self.speed = speeds[speed_idx]

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
    if not self.dead then
        Enemy.super.update(self, dt)
        self.collider:update()
        self.sprite:update(dt, self.x, self.y)

        if self.vector.x then
            self.collider.x = self.collider.x + (self.speed * self.vector.x)
            self.collider.y = self.collider.y + (self.speed * self.vector.y)
        end
    end
end

function Enemy:draw()
    self.sprite:draw()
end

function Enemy:updateVector(x, y)
    self.vector = utils.getUnitVector(self.collider.x, self.collider.y, x, y)
end

return Enemy
