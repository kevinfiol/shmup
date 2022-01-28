local vars = require 'vars'
local GameObject = require 'engine.GameObject'
local Sprite = require 'engine.Sprite'
local SimpleCollider = require 'engine.SimpleCollider'
local baton = require 'lib.baton'
local Timer = require 'lib.timer'
local Bullet = require 'obj.Bullet'
local utils = require 'engine.utils'

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
        collision_class = opts.collision_class,
        events = {
            Enemy = function ()
                self:kill()
            end
        }
    })

    self.sprite = Sprite(self.x, self.y, {
        image = love.graphics.newImage('assets/tbone.png'),
        animated = true,
        width = 16,
        height = 16,
        offset = { x = 4, y = 7 },
        initial = 'idle',
        animations = {
            idle = {
                frames = { {1, 1, 4, 1, 0.1} }
            },
            walk = {
                frames = { {8, 1, 11, 1, 0.1} }
            }
        }
    })

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

    self.sprite:update(dt, self.x, self.y)
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
                local unit_vector = utils.getUnitVector(pos_x, pos_y, x, y)

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
        if self.sprite.flip.x then
            self.sprite:flipX()
        end

        if not self.is_walking then
            self.is_walking = true
            self.sprite:switch('walk')
        end

        self.collider.x = self.x + self.speed
    elseif self.input:down('left') then
        if not self.sprite.flip.x then
            self.sprite:flipX()
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

return Player
