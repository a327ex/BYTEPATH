Reflecteer = GameObject:extend()

function Reflecteer:new(area, x, y, opts)
    Reflecteer.super.new(self, area, x, y, opts)

    local direction = table.random({-1, 1})
    self.x = gw/2 + direction*(gw/2 + 48)
    self.y = random(16, gh - 16)
    
    self.w, self.h = 16, 16
    self.shape = HC.circle(self.x, self.y, self.w)
    self.shape.id = self.id
    self.shape.object = self
    self.shape.tag = 'Enemy'

    self.v = random(20, 40)
    self.r = direction == 1 and math.pi or 0
    self.vx, self.vy = self.v*math.cos(self.r), self.v*math.sin(self.r)

    self.hp = 250*current_room.director.enemy_hp_multiplier
    self.invulnerable = false
    self.timer:every(2, function() self.invulnerable = not self.invulnerable end)
end

function Reflecteer:update(dt)
    Reflecteer.super.update(self, dt)

    self:enemyProjectileCollisions()

    self.target = current_room.player
    if self.target and self.target.dead then self.target = nil end
    if self.target then
        local projectile_heading_x, projectile_heading_y = Vector.normalize(self.vx, self.vy)
        local angle = math.atan2(self.target.y - self.y, self.target.x - self.x)
        local to_target_heading_x, to_target_heading_y = Vector.normalize(math.cos(angle), math.sin(angle))
        local final_heading_x, final_heading_y = Vector.normalize(projectile_heading_x + 0.1*current_room.player.pspd_multiplier.value*to_target_heading_x, 
        projectile_heading_y + 0.1*current_room.player.pspd_multiplier.value*to_target_heading_y)
        self.vx, self.vy = self.v*final_heading_x, self.v*final_heading_y
    else self.vx, self.vy = self.v*math.cos(self.r), self.v*math.sin(self.r) end

    self.shape:move(self.vx*dt, self.vy*dt)
    self.r = Vector.angle(self.vx, self.vy)
    self.x, self.y = self.shape:center()
end

function Reflecteer:draw()
    love.graphics.setColor(hp_color)
    if self.invulnerable then love.graphics.setColor(default_color) end
    if self.hit_flash then love.graphics.setColor(default_color) end
    self.shape:draw('line')
end

function Reflecteer:hit(damage, x, y, r)
    if self.dead then return end

    if self.invulnerable then
        self.area:addGameObject('EnemyProjectile', x, y, {r = -math.pi + (r or 0)})
        self.area:addGameObject('TrailerShootEffect', x, y)
    else
        self.hp = self.hp - (damage or 100)
        if self.hp <= 0 then
            playGameEnemyDie()
            current_room.score = current_room.score + 250
            self.dead = true
            if not current_room.player.no_ammo_drop then self.area:addGameObject('Ammo', self.x, self.y) end
            self.area:addGameObject('EnemyDeathEffect', self.x, self.y, {color = hp_color, w = 2.5*self.w})
        else
            self.hit_flash = true
            self.timer:after('hit_flash', 0.2, function() self.hit_flash = false end)
        end
    end
end
