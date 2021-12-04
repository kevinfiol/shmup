local vars = require 'vars'
local Object = require 'lib.classic'
local Area = require 'engine.Area'
local Player = require 'obj.Player'

local Stage = Object:extend()

function Stage:new()
    self.player = nil
    self.area = nil
    self.canvas = nil

    -- init area
    self.area = Area(Stage)
    self.canvas = love.graphics.newCanvas(vars.gw, vars.gh)

    -- load player
    self.player = Player(self.area, 10, 10, { control = true, collision_class = 'Player' })
    self.enemy = Player(self.area, 30, 30, { collision_class = 'Player' })
    self.area:addGameObjects({ self.player, self.enemy })
end

function Stage:update(dt)
    if self.area then self.area:update(dt) end
    if self.timer then self.timer:update(dt) end
    if self.player then
        self.player.collider:resolveCollision(self.enemy.collider)
    end
end

function Stage:draw()
    if self.area then
        love.graphics.setCanvas(self.canvas)
        love.graphics.clear()
        -- draw begin
        self.area:draw()
        -- draw end
        love.graphics.setCanvas()
        -- love.graphics.setColor(255, 255, 255, 255)
        -- love.graphics.setBlendMode('alpha', 'premultiplied')
        love.graphics.draw(self.canvas, 0, 0, 0, vars.sx, vars.sy)
        -- love.graphics.setBlendMode('alpha')
    end
end

return Stage