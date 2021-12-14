local Object = require 'lib.classic'
local Wall = require 'obj.Wall'

local Walls = Object:extend()

function Walls:new(area, tiled_map)
    self.objs = {}

    if tiled_map.layers and tiled_map.layers.collidables then
        local walls = tiled_map.layers.collidables

        for _, object in ipairs(walls.objects) do
            table.insert(
                self.objs,
                Wall(area, object.x, object.y, {
                    width = object.width,
                    height = object.height,
                    collision_class = 'Wall'
                })
            )
        end

        area:addGameObjects(self.objs)
    end
end

function Walls:destroy()
    self.objs = nil
end

return Walls
