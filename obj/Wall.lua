local GameObject = require 'engine.GameObject'
local SimpleCollider = require 'engine.SimpleCollider'

local Wall = GameObject:extend()

function Wall:new(area, x, y, opts)
    Wall.super.new(self, 'Wall', area, x, y, opts)
    opts = opts or {}

    self.collider = SimpleCollider(self.x, self.y, opts.width, opts.height, {
        collision_class = opts.collision_class or 'Wall'
    })
end

function Wall:update(dt)
    Wall.super.update(self, dt)
    self.collider:update()
end

function Wall:draw()
end

return Wall
