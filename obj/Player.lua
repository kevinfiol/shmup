local vars = require 'vars'
local GameObject = require 'engine.GameObject'
local SimpleCollider = require 'engine.SimpleCollider'
local baton = require 'lib.baton'
local sodapop = require 'lib.sodapop'
local Timer = require 'lib.timer'
local Bullet = require 'obj.Bullet'

local Player = GameObject:extend()

function Player:new(area, x, y, opts)
    Player.super.new(self, 'Player', area, x, y, opts)
    opts = opts or {}

    self.speed = 1.8
    self.input = nil
    self.sprite = nil
    self.is_walking = false
    self.is_shooting = false
    self.timer = Timer()
    self.sounds = {
        shoot = love.audio.newSource('assets/audio/shoot.wav', 'static')
    }

    self.collider = SimpleCollider(self, self.x, self.y, 8, 9, {
        debug = false,
        collision_class = opts.collision_class
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
                down = { 'key:down', 'key:s' },
                shoot = { 'mouse:1' }
            }
        })
    end

    self.bullets = {}
end

function Player:update(dt)
    Player.super.update(self, dt)
    self.timer:update(dt)
    -- have to call this before self:move
    self.collider:update()

    if self.input then
        self.input:update()
        self:move(dt)
        self:shoot(dt)
    end

    self.sprite:update(dt)
end

function Player:draw()
    -- self.collider:draw()
    self.sprite:draw()
end

function Player:shoot(dt)
    if self.input:down('shoot') then
        if not self.is_shooting then
            self.is_shooting = true

            local shoot_fn = function()
                if (self.sounds.shoot:isPlaying()) then
                    self.sounds.shoot:stop()
                end

                camera:shake(2, 0.4, 60, 'XY')
                self.sounds.shoot:play()
                local x, y = love.mouse.getPosition()
                x = x / vars.sx -- have to scale
                y = y / vars.sy -- have to scale
                local pos_x = self.collider.x
                local pos_y = self.collider.y

                local vector = { x = (x - pos_x), y = (y - pos_y) }
                local magnitude = math.sqrt((vector.x * vector.x) + (vector.y * vector.y))
                local unit_vector = { x = vector.x / magnitude, y = vector.y / magnitude }

                local bullet = Bullet(self.area, pos_x, pos_y, {
                    vector = unit_vector
                })

                table.insert(self.bullets, bullet)
                self.area:addGameObjects({ bullet })
            end

            shoot_fn()
            self.timer:every(0.36, shoot_fn, 'shoot_timer')
        end
    else
        if self.is_shooting then
            self.is_shooting = false
            self.timer:cancel('shoot_timer')
        end
    end
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
