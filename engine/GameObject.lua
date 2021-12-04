local Object = require 'lib.classic'

local GameObject = Object:extend()

function GameObject:new(class, area, x, y, opts)
    if opts then
        for k, v in pairs(opts) do
            self[k] = v
        end
    end

    self.class = class
    self.area = area
    self.x, self.y = x, y
    self.dead = false
    self.moving_props = {}

    -- optional props
    self.timer = nil
    self.collider = nil
end

function GameObject:update(dt)
    if self.timer then self.timer:update(dt) end

    if self.collider.update then
        self.collider:update()
    end

    -- update x,y coordinates based on collider
    self.x, self.y = self.collider:getPosition()
end

function GameObject:draw()
    -- no op
end

function GameObject:destroy()
    self.dead = true
    self.area = nil
    self.moving_props = nil

    if self.timer then
        self.timer:destroy()
        self.timer = nil
    end

    if self.collider then
        self.collider:destroy()
        self.collider = nil
    end
end

function GameObject:kill()
    self.dead = true
end

return GameObject