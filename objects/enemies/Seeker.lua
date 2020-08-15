Seeker = GameObject:extend()

function Seeker:new(area, x, y, opts)
    Seeker.super.new(self, area, x, y, opts)

    local direction = table.random({-1, 1})
    self.x = gw/2 + direction*(gw/2 + 48)
    self.y = random(16, gh - 16)

    self.w, self.h = 16, 8
    self.shape = HC.polygon(self.w, 0, self.w/2, self.h, -self.w/2, self.h, -self.w, 0, -self.w/2, -self.h, self.w/2, -self.h)
    self.shape:moveTo(self.x, self.y)
    self.shape.id = self.id
    self.shape.object = self
    self.shape.tag = 'Enemy'

    self.v = -direction*random(20, 40)
    self.r = direction == 1 and math.pi or 0
    self.vx, self.vy = self.v*math.cos(self.r), self.v*math.sin(self.r)
    self.dr = random(-10, 10)

    self.hp = 200*current_room.director.enemy_hp_multiplier

    self.timer:every(random(1, 2), function()
        self.timer:after(1, function()
            self.area:addGameObject('EnemyProjectile', self.x + 1.4*self.w*math.cos(self.r - math.pi), self.y + 1.4*self.w*math.sin(self.r - math.pi), 
            {r = self.r - math.pi, v = random(80, 100), s = 3.5, mine = true})
        end)
    end)
end

function Seeker:update(dt)
    Seeker.super.update(self, dt)

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

    self.r = Vector.angle(self.vx, self.vy)
    self.shape:move(self.vx*dt, self.vy*dt)
    self.shape:setRotation(self.r)
    self.x, self.y = self.shape:center()
end

function Seeker:draw()
    love.graphics.setColor(hp_color)
    if self.hit_flash then love.graphics.setColor(default_color) end
    self.shape:draw('line')
    love.graphics.setColor(default_color)
end

function Seeker:destroy()
    Seeker.super.destroy(self)
end

function Seeker:hit(damage)
    if self.dead then return end

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
