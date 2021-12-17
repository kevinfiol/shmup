local vars = require 'vars'
local cartographer = require 'lib.cartographer'
local Object = require 'lib.classic'
local Area = require 'engine.Area'
local Player = require 'obj.Player'
local Walls = require 'elements.Walls'
local Clouds = require 'elements.Clouds'
local lume = require 'lib.lume'

local Stage = Object:extend()

function Stage:new()
    self.player = nil
    self.area = nil
    self.canvas = nil
    self.tiled_map = nil
    self.bg = nil
    self.walls = nil
    self.mouse = { x = 0, y = 0 }

    self.cursor = love.mouse.newCursor('assets/crosshair.png', 16 / vars.sx, 16 / vars.sy)
    love.mouse.setCursor(self.cursor)

    -- audio
    self.music = love.audio.newSource('assets/audio/theme.ogg', 'stream')
    self.music:setLooping(true)
    self.music:setVolume(0.5)
    self.music:play()

    -- init area
    self.area = Area(Stage)
    self.canvas = love.graphics.newCanvas(vars.gw, vars.gh)

    -- tilemaps
    self.bg = Clouds()
    self.tiled_map = cartographer.load('assets/map1.lua')
    self.walls = Walls(self.area, self.tiled_map)
    local start = self.tiled_map.layers.start.objects[1]

    -- load player
    self.player = Player(self.area, start.x, start.y, { control = true, collision_class = 'Player' })
    self.area:addGameObjects({ self.player })
end

function Stage:update(dt)
    if self.area then self.area:update(dt) end
    if self.timer then self.timer:update(dt) end
    if self.player then
        for _, object in ipairs(self.walls.objs) do
            self.player.collider:resolveCollision(object.collider)

            local live_bullets = {}
            for _, bullet in ipairs(self.player.bullets) do
                if bullet and not bullet.dead then
                    bullet.collider:resolveCollision(object.collider)
                    table.insert(live_bullets, bullet)
                end
            end
            self.player.bullets = live_bullets
        end
    end
end

function Stage:draw()
    if self.area then
        love.graphics.setCanvas(self.canvas)
        love.graphics.clear()
        -- draw begin

        camera:attach(0, 0, vars.gw, vars.gh)
        self.bg:draw()
        self.tiled_map.layers.fg:draw()
        self.area:draw()
        camera:detach()

        -- draw end
        love.graphics.setCanvas()
        -- love.graphics.setColor(255, 255, 255, 255)
        -- love.graphics.setBlendMode('alpha', 'premultiplied')
        love.graphics.draw(self.canvas, 0, 0, 0, vars.sx, vars.sy)
        -- love.graphics.setBlendMode('alpha')
    end
end

function Stage:destroy()
    self.canvas:release()
    self.canvas = nil

    self.bg:destroy()
    self.bg = nil

    self.area:destroy()
    self.area = nil

    self.walls:destroy()
    self.walls = nil
end

return Stage