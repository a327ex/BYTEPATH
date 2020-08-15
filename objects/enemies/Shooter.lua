Shooter = GameObject:extend()

function Shooter:new(area, x, y, opts)
    Shooter.super.new(self, area, x, y, opts)

    local direction = table.random({-1, 1})
    self.x = gw/2 + direction*(gw/2 + 48)
    self.y = random(16, gh - 16)

    self.w, self.h = 12, 6

    self.shape = HC.polygon(self.w, 0, -self.w/2, self.h, -self.w, 0, -self.w/2, -self.h)
    self.shape.id = self.id
    self.shape:moveTo(self.x, self.y)
    self.shape.object = self
    self.shape.tag = 'Enemy'

    self.v = -direction*random(20, 40)
    self.r = direction == 1 and math.pi or 0
    self.vx, self.vy = self.v*math.cos(self.r), self.v*math.sin(self.r)

    self.hp = 100*current_room.director.enemy_hp_multiplier

    self.timer:every(random(3, 5), function()
        self.area:addGameObject('PreAttackEffect', self.x + 1.4*self.w*math.cos(self.r), self.y + 1.4*self.w*math.sin(self.r), 
        {shooter = self, color = hp_color, duration = 1})
        self.timer:after(1, function()
            self.area:addGameObject('EnemyProjectile', self.x + 1.4*self.w*math.cos(self.r), self.y + 1.4*self.w*math.sin(self.r), 
            {r = self.r, v = random(80, 100), s = 3.5, homing = true})
        end)
    end)
end

function Shooter:update(dt)
    Shooter.super.update(self, dt)

    self:enemyProjectileCollisions()

    self.shape:move(self.vx*dt, 0)
    self.x, self.y = self.shape:center()
end

function Shooter:draw()
    love.graphics.setColor(hp_color)
    if self.hit_flash then love.graphics.setColor(default_color) end
    self.shape:draw('line')
    love.graphics.setColor(default_color)
end

function Shooter:destroy()
    Shooter.super.destroy(self)
end

function Shooter:hit(damage)
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
