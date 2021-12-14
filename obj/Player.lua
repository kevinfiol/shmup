local GameObject = require 'engine.GameObject'
local SimpleCollider = require 'engine.SimpleCollider'
local baton = require 'lib.baton'
local sodapop = require 'lib.sodapop'

local Player = GameObject:extend()

function Player:new(area, x, y, opts)
    Player.super.new(self, 'Player', area, x, y, opts)
    opts = opts or {}

    self.speed = 1.6
    self.input = nil
    self.sprite = nil
    self.is_walking = false

    self.collider = SimpleCollider(self.x, self.y, 8, 9, {
        debug = false,
        collision_class = opts.collision_class,
        events = {
            Player =  function (collider, side)
                print('collided with ' .. collider.collision_class .. ' on ' .. side)
            end
        }
    })

    self:setSprite({
        image = love.graphics.newImage('assets/tbone.png'),
        width = 16,
        height = 16
    })

    self.sprite.flipX = opts.flipX or false

    if opts.control then
        self.input = baton.new({
            controls = {
                left = { 'key:left', 'key:a' },
                right = { 'key:right', 'key:d' },
                up = { 'key:up', 'key:w' },
                down = { 'key:down', 'key:s' }
            }
        })
    end
end

function Player:update(dt)
    Player.super.update(self, dt)
    -- have to call this before self:move
    self.collider:update()

    if self.input then
        self.input:update()
        self:move(dt)
    end

    self.sprite:update(dt)
end

function Player:draw()
    -- self.collider:draw()
    self.sprite:draw()
end

function Player:move(dt)
    if self.input:down('right') then
        if self.sprite.flipX then
            self.sprite.flipX = false
        end

        if not self.is_walking then
            self.is_walking = true
            self.sprite:switch('walk')
        end

        self.collider.x = self.x + self.speed
    elseif self.input:down('left') then
        if not self.sprite.flipX then
            self.sprite.flipX = true
        end

        if not self.is_walking then
            self.is_walking = true
            self.sprite:switch('walk')
        end

        self.collider.x = self.x - self.speed
    end

    if self.input:down('up') then
        if not self.is_walking then
            self.is_walking = true
            self.sprite:switch('walk')
        end

        self.collider.y = self.y - self.speed
    elseif self.input:down('down') then
        if not self.is_walking then
            self.is_walking = true
            self.sprite:switch('walk')
        end

        self.collider.y = self.y + self.speed
    end

    -- stop walking
    local stopped_walking = self.input:released('right')
        or self.input:released('left')
        or self.input:released('up')
        or self.input:released('down')
        and not (
            self.input:down('right')
            or self.input:down('left')
            or self.input:down('up')
            or self.input:down('down')
        )

    if stopped_walking then
        self.is_walking = false
        self.sprite:switch('idle')
    end
end

function Player:setSprite(sprite_config)
    local width_half = sprite_config.width / 2
    local height_half = sprite_config.height / 2

    self.sprite = sodapop.newAnimatedSprite(
        self.x + width_half,
        self.y + height_half
    )

    self.sprite:setAnchor(function()
        return self.x + width_half - 4, self.y + height_half - 7
    end)

    self.sprite:addAnimation('idle', {
        image = sprite_config.image,
        frameWidth = sprite_config.width,
        frameHeight = sprite_config.height,
        frames = { {1, 1, 4, 1, 0.1} }
    })

    self.sprite:addAnimation('walk', {
        image = sprite_config.image,
        frameWidth = sprite_config.width,
        frameHeight = sprite_config.height,
        frames = {
            {8, 1, 11, 1, 0.1}
        }
    })
end

return Player
