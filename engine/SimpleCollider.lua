local Object = require 'lib.classic'
local lume = require 'lib.lume'
local collisions = require 'collisions'

local SimpleCollider = Object:extend()
local collide_groups = {}

function SimpleCollider:new(x, y, width, height, opts)
    opts = opts or {}
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.weight = opts.weight or 0
    self.collision_class = opts.collision_class or 'Ghost'
    self.events = opts.events or {}
    self.debug = opts.debug or false

    self.has_collided = false

    -- last position
    self.last = {
        x = self.x,
        y = self.y
    }
end

function SimpleCollider:update()
    self.last.x = self.x
    self.last.y = self.y
end

function SimpleCollider:draw()
    if self.debug then
        love.graphics.rectangle('line', self.x, self.y, self.width, self.height)
    end
end

function SimpleCollider:getPosition()
    return self.x, self.y
end

function SimpleCollider:resolveCollision(collider)
    if self:isTouching(collider) then
        local class_table = { self.collision_class, collider.collision_class }
        table.sort(class_table)
        local group = table.concat(class_table, ',')

        if collide_groups[group] == nil then
            collide_groups[group] =
                not (self.collision_class == 'Ghost' or collider.collision_class == 'Ghost')
                and lume.find(collisions[self.collision_class], collider.collision_class) == nil
                and lume.find(collisions[collider.collision_class], self.collision_class) == nil
        end

        local collide = collide_groups[group]
        local side = nil

        if self:wasVerticallyAligned(collider) then
            if self.x + self.width / 2 < collider.x + collider.width / 2 then
                -- right collision
                if collide then
                    self.x = self.x - (self.x + self.width - collider.x)
                end
            elseif self.x + self.width / 2 > collider.x + collider.width / 2 then
                -- left collision
                if collide then
                    -- print('left collide')
                    self.x = self.x + (collider.x + collider.width - self.x)
                end
            end

            -- after collision has been resolved (and maybe corrected) get side
            if self.x + self.width == collider.x then
                side = 'right'
            elseif self.x == collider.x + collider.width then
                side = 'left'
            end
        elseif self:wasHorizontallyAligned(collider) then
            if self.y + self.height / 2 < collider.y + collider.height / 2 then
                -- bottom collision
                if collide then
                    self.y = self.y - (self.y + self.height - collider.y)
                end
            elseif self.y + self.height / 2 > collider.y + collider.height / 2 then
                -- top collision
                if collide then
                    self.y = self.y + (collider.y + collider.height - self.y)
                end
            end

            if self.y + self.height == collider.y then
                side = 'bottom'
            elseif self.y == collider.y + collider.height then
                side = 'top'
            end
        end

        if not self.has_collided and side then
            self.has_collided = true
            if self.events[collider.collision_class] then
                self.events[collider.collision_class](collider, side)
            end
        end
    elseif self.has_collided then
        self.has_collided = false
    end
end

function SimpleCollider:isTouching(collider)
    return self.x + self.width >= collider.x
        and self.x <= collider.x + collider.width
        and self.y + self.height >= collider.y
        and self.y <= collider.y + collider.height
end

function SimpleCollider:wasVerticallyAligned(collider)
    return self.last.y < collider.last.y + collider.height
        and self.last.y + self.height > collider.last.y
end

function SimpleCollider:wasHorizontallyAligned(collider)
    return self.last.x < collider.last.x + collider.width
        and self.last.x + self.width > collider.last.x
end

return SimpleCollider