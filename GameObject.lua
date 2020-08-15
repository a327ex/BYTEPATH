GameObject = Object:extend()

function GameObject:new(area, x, y, opts)
    local opts = opts or {}
    if opts then for k, v in pairs(opts) do self[k] = v end end

    self.area = area
    self.x, self.y = x, y
    self.id = UUID()
    self.creation_time = love.timer.getTime()
    self.timer = Timer()
    self.dead = false
    self.depth = 50

    self.previous_collisions = {}
    self.current_collisions = {}
end

function GameObject:update(dt)
    if self.timer then self.timer:update(dt) end
    if self.shape then 
        self.previous_collisions = table.copy(self.current_collisions) 
        self.current_collisions = {}
    end
end

function GameObject:draw()

end

function GameObject:destroy()
    self.timer:destroy()
    if self.shape then HC.remove(self.shape) end
    self.shape = nil
end

function GameObject:enter(tag)
    local shapes = {}
    for shape in pairs(HC.neighbors(self.shape)) do
        if shape.tag == tag then
            if self.shape:collidesWith(shape) then
                self.current_collisions[shape.id] = true
                if not self.previous_collisions[shape.id] then table.insert(shapes, shape) end
            end
        end
    end
    return shapes
end

function GameObject:enemyProjectileCollisions()
    for _, shape in ipairs(self:enter('Projectile')) do
        local object = shape.object
        if object then
            self:hit(object.damage, object.x, object.y, object.r)
            if self.hp <= 0 then current_room.player:onKill(self) end
            if object.pierce > 0 then 
                object.pierce = object.pierce - 1
                if object.attack == 'Explode' then object.area:addGameObject('Explosion', object.x, object.y, {color = self.color}) end
            else object:die() end
        end
    end
end
