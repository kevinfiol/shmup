local vars = require 'vars'
local cartographer = require 'lib.cartographer'
local Object = require 'lib.classic'
local Area = require 'engine.Area'
local Player = require 'obj.Player'
local Walls = require 'elements.Walls'
local Clouds = require 'elements.Clouds'
local Cursor = require 'elements.Cursor'

local Stage = Object:extend()

function Stage:new()
    self.cursor = nil
    self.player = nil
    self.area = nil
    self.canvas = nil
    self.tiled_map = nil
    self.bg = nil
    self.walls = nil
    self.mouse = { x = 0, y = 0 }

    -- init area
    self.area = Area(Stage)
    self.canvas = love.graphics.newCanvas(vars.gw, vars.gh)
    self.cursor = Cursor(self.mouse.x, self.mouse.y)
    love.mouse.setVisible(false)
    -- love.mouse.newCursor

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
    if self.cursor then
        local mouse_x, mouse_y = love.mouse.getPosition()
        self.mouse.x = mouse_x
        self.mouse.y = mouse_y
    end
    if self.area then self.area:update(dt) end
    if self.timer then self.timer:update(dt) end
    if self.player then
        for _, object in ipairs(self.walls.objs) do
            self.player.collider:resolveCollision(object.collider)
        end
    end
end

function Stage:draw()
    if self.area then
        love.graphics.setCanvas(self.canvas)
        love.graphics.clear()
        -- draw begin

        self.bg:draw()
        self.tiled_map.layers.fg:draw()
        self.area:draw()
        self.cursor:draw(self.mouse.x / vars.sx, self.mouse.y / vars.sy)

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