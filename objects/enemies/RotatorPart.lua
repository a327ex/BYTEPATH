RotatorPart = GameObject:extend()

function RotatorPart:new(area, x, y, opts)
    RotatorPart.super.new(self, area, x, y, opts)

    self.w, self.h = 8, 8
    self.collider = self.area.world:newPolygonCollider(createIrregularPolygon(8))
    self.collider:setPosition(self.x, self.y)
    self.collider:setObject(self)
    self.collider:setCollisionClass('Enemy')
    self.collider:setFixedRotation(false)
    self:setImmune(true)

    if self.center then
        self.v = -self.direction*random(30, 50)
        self.collider:setLinearVelocity(self.v, 0)
        self.collider:setAngularVelocity(self.direction*20)
        self:setImmune(false)
    end

    self.hp = 200*current_room.director.enemy_hp_multiplier
end

function RotatorPart:update(dt)
    RotatorPart.super.update(self, dt)

    if self.center then
        self.collider:setLinearVelocity(self.v, 0) 
        self.collider:setAngularVelocity(self.direction*20)
    end

    if not self.immune and not self.center then
        local vx, vy = self.collider:getLinearVelocity()
        if self.x < 0 then vx = -vx end
        if self.y < 0 then vy = -vy end
        if self.x > gw then vx = -vx end
        if self.y > gh then vy = -vy end
        self.collider:setLinearVelocity(vx, vy)
    end
end

function RotatorPart:draw()
    love.graphics.setColor(hp_color)
    if self.hit_flash then love.graphics.setColor(default_color) end
    if self.immune then love.graphics.setColor(default_color) end
    local points = {self.collider:getWorldPoints(self.collider.shapes.main:getPoints())}
    love.graphics.polygon('line', points)
    love.graphics.setColor(default_color)
end

function RotatorPart:setImmune(v)
    self.immune = v
end

function RotatorPart:hit(damage)
    if self.dead then return end
    if self.immune then return end

    self.hp = self.hp - (damage or 100)
    if self.hp <= 0 then
        playGameEnemyDie()
        current_room.score = current_room.score + 100
        self.dead = true
        if not current_room.player.no_ammo_drop then self.area:addGameObject('Ammo', self.x, self.y) end
        self.area:addGameObject('EnemyDeathEffect', self.x, self.y, {color = hp_color, w = 3*self.w})
        if self.rotator then self.rotator:unlink() end
    else
        self.hit_flash = true
        self.timer:after('hit_flash', 0.2, function() self.hit_flash = false end)
    end
end
