local Object = require 'lib.classic'
local Wall = require 'obj.Wall'

local Cursor = Object:extend()

function Cursor:new(x, y)
    self.sprite = love.graphics.newImage('assets/crosshair.png')
    self.offset_x = self.sprite:getWidth() / 2
    self.offset_y = self.sprite:getHeight() / 2
end

function Cursor:update(dt)

end

function Cursor:draw(x, y)
    love.graphics.draw(self.sprite, x - self.offset_x, y - self.offset_y)
end

function Cursor:destroy()
    self.sprite = nil
end

return Cursor
