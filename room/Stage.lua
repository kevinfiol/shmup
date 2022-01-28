local vars = require 'vars'
local cartographer = require 'lib.cartographer'
local Object = require 'lib.classic'
local Area = require 'engine.Area'
local Player = require 'obj.Player'
local Enemy = require 'obj.Enemy'
local Walls = require 'elements.Walls'
local Clouds = require 'elements.Clouds'
local lume = require 'lib.lume'
local Timer = require 'lib.timer'
local utils = require 'engine.utils'

local baton = require 'lib.baton'

local Stage = Object:extend()

function Stage:new()
    self.player = nil
    self.area = nil
    self.canvas = nil
    self.tiled_map = nil
    self.bg = nil
    self.walls = nil
    self.mouse = { x = 0, y = 0 }
    self.timer = Timer()
    self.bounds = {}
    self.spawn_timer = Timer()
    self.spawn_rate = 3
    self.spawn_cluster_max = 2
    self.spawn_enemy_max = 5

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
    local limits = self.tiled_map.layers.limits.objects
    inspect(limits)

    self.bounds = {
        x = { min = limits[1].x, max = limits[2].x - 50 },
        y = { min = limits[1].y, max = limits[2].y - 50 }
    }

    -- load player
    self.player = Player(self.area, start.x, start.y, { control = true, collision_class = 'Player' })

    self.enemies = {}

    self.area:addGameObjects({ self.player })

    self.timer:every(0.4, function ()
        for _, enemy in ipairs(self.enemies) do
            if enemy and enemy.collider then
                if self.player and not self.player.dead then
                    enemy:updateVector(self.player.collider.x, self.player.collider.y)
                else
                    enemy.vector.x, enemy.vector.y = nil, nil
                end
            end
        end
    end)

    local round = 0
    self.spawn_timer:every(self.spawn_rate, function ()
        if self.player.dead then
            self.spawn_timer:destroy()
        end
        for i = 1, self.spawn_cluster_max do
            local quantity = utils.random(5, self.spawn_enemy_max + 1)
            self:spawnEnemyCluster(quantity)
        end

        round = round + 1
        if round > 5 then
            self.spawn_cluster_max = self.spawn_cluster_max + 1
            self.spawn_enemy_max = self.spawn_enemy_max + 1
            -- self.spawn_rate = math.max(2, math.min(self.spawn_rate, self.spawn_rate - 0.25)) -- could use lume.clamp here
            round = 1
        end
    end)

    self.input = baton.new({
        controls = {
            spawn = { 'key:p' }
        }
    })
end

function Stage:update(dt)
    -- if self.input then
    --     self.input:update()
    --     self:spawnEnemyCluster()
    -- end

    if self.area then self.area:update(dt) end
    if self.timer then self.timer:update(dt) end
    if self.spawn_timer then self.spawn_timer:update(dt) end
    if self.player then
        for _, object in ipairs(self.walls.objs) do
            if self.player and self.player.collider then
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

        for _, enemy in ipairs(self.enemies) do
            if enemy and enemy.collider and self.player and self.player.collider then
                self.player.collider:resolveCollision(enemy.collider)

                for _, bullet in ipairs(self.player.bullets) do
                    bullet.collider:resolveCollision(enemy.collider)
                end
            end
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

function Stage:spawnEnemyCluster(quantity)
    local cluster_x = utils.random(self.bounds.x.min, self.bounds.x.max)
    local cluster_y = utils.random(self.bounds.y.min, self.bounds.y.max)

    local new_enemies = {}

    for i = 1,quantity do
        local x = utils.random(cluster_x, cluster_x + 50 - (7))
        local y = utils.random(cluster_y, cluster_y + 50 - (7))

        table.insert(new_enemies,
            Enemy(self.area, x, y, {
                collision_class = 'Enemy'
            })
        )

        lume.push(self.enemies, unpack(new_enemies))
        self.area:addGameObjects(new_enemies)
    end
end

return Stage