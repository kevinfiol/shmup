local GameObject = require 'engine.GameObject'
local SimpleCollider = require 'engine.SimpleCollider'
local sodapop = require 'lib.sodapop'

local Bullet = GameObject:extend()

function Bullet:new(area, x, y, opts)
    Bullet.super.new(self, 'Bullet', area, x, y, opts)
    opts = opts or {}

    self.speed = 4.6
    self.sprite = nil
    self.width = 8
    self.height = 8
    self.vector = opts.vector

    self.collider = SimpleCollider(self.x, self.y, self.width, self.height, {
        collision_class = 'Bullet',
        events = {
            Wall = function ()
                self:kill()
            end
        }
    })

    self:setSprite({
        image = love.graphics.newImage('assets/bullet.png'),
        width = self.width,
        height = self.height
    })
end

function Bullet:update(dt)
    Bullet.super.update(self, dt)
    self.collider:update()

    self.sprite:update(dt)

    if self.vector then
        self.collider.x = self.collider.x + (self.speed * self.vector.x)
        self.collider.y = self.collider.y + (self.speed * self.vector.y)
    end
end

function Bullet:draw()
    self.sprite:draw()
end

function Bullet:setSprite(config)
    local width_half = config.width / 2
    local height_half = config.height / 2

    self.sprite = sodapop.newSprite(config.image, self.x + (width_half), self.y + (height_half))
    self.sprite:setAnchor(function()
        return self.x + width_half, self.y + height_half
    end)
end

return Bullet
