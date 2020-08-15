Trailer = GameObject:extend()

function Trailer:new(area, x, y, opts)
    Trailer.super.new(self, area, x, y, opts)

    local positions = {{gw + 32, gh + 32, -3*math.pi/4, -math.pi}, {gw + 32, - 32, 3*math.pi/4, math.pi}, {-32, -32, math.pi/4, 0}, {-32, gh + 32, -math.pi/4, 0}}
    local position = table.random(positions)
    self.x = position[1] 
    self.y = position[2]
    
    self.w, self.h = 12, 6
    self.shape = HC.polygon(self.w, 0, -self.w, self.h, -self.w, -self.h)
    self.shape.id = self.id
    self.shape:moveTo(self.x, self.y)
    self.shape.object = self
    self.shape.tag = 'Enemy'

    self.v = random(100, 140)
    self.r = position[3]
    self.vx, self.vy = self.v*math.cos(self.r), self.v*math.sin(self.r)

    self.hp = 100*current_room.director.enemy_hp_multiplier
    local r = random(1.6, 2.2)
    self.timer:after(r, function() self.timer:tween(random(0.5, 1.0), self, {r = position[4]}, 'in-out-cubic') end)
    self.timer:every(0.3, function() 
        self.area:addGameObject('TrailerShootEffect', self.x + 14*math.cos(self.r - math.pi), self.y + 14*math.sin(self.r - math.pi), {parent = self, d = 14})
        self.area:addGameObject('EnemyProjectile', self.x + 14*math.cos(self.r - math.pi), self.y + 14*math.sin(self.r - math.pi), 
        {trailer = true, homing = true, r = random(self.r - math.pi - math.pi/2, self.r - math.pi + math.pi/2)}) 
    end)
end

function Trailer:update(dt)
    Trailer.super.update(self, dt)

    self:enemyProjectileCollisions()

    self.vx, self.vy = self.v*math.cos(self.r), self.v*math.sin(self.r)
    self.shape:move(self.vx*dt, self.vy*dt)
    self.x, self.y = self.shape:center()
    self.shape:setRotation(self.r)
end

function Trailer:draw()
    love.graphics.setColor(hp_color)
    if self.hit_flash then love.graphics.setColor(default_color) end
    self.shape:draw('line')
    love.graphics.setColor(default_color)
end

function Trailer:hit(damage)
    if self.dead then return end

    self.hp = self.hp - (damage or 100)
    if self.hp <= 0 then
        playGameEnemyDie()
        current_room.score = current_room.score + 150
        self.dead = true
        if not current_room.player.no_ammo_drop then self.area:addGameObject('Ammo', self.x, self.y) end
        self.area:addGameObject('EnemyDeathEffect', self.x, self.y, {color = hp_color, w = 2.5*self.w})
    else
        self.hit_flash = true
        self.timer:after('hit_flash', 0.2, function() self.hit_flash = false end)
    end
end
