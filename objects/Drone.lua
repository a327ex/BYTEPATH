Drone = GameObject:extend()

function Drone:new(area, x, y, opts)
    Drone.super.new(self, area, x, y, opts)

    self.x, self.y = self.player.x + 20*math.cos(self.player.r + self.rd), self.player.y + 20*math.sin(self.player.r + self.rd)
    self.w, self.h = 8, 8

    self.shoot_timer = 0
    self.shoot_cooldown = 0.24
end

function Drone:update(dt)
    Drone.super.update(self, dt)
    self.x, self.y = self.player.x + 20*math.cos(self.player.r + self.rd), self.player.y + 20*math.sin(self.player.r + self.rd)
    self.r = self.player.r
    self.shoot_cooldown = self.player.shoot_cooldown

    self.shoot_timer = self.shoot_timer + dt
    if self.shoot_timer > self.shoot_cooldown/(self.player.aspd_multiplier.value + 0.5) then
        self.shoot_timer = 0
        self:shoot()
    end
end

function Drone:draw()
    pushRotate(self.x, self.y, self.player.r)
    love.graphics.setColor(default_color)
    draft:rhombus(self.x, self.y, self.w, self.h, 'line')
    love.graphics.pop()
end

function Drone:shoot()
    self.area:addGameObject('ShootEffect', self.x + 4*math.cos(self.r), self.y + 4*math.sin(self.r), {parent = self, d = 4})
    self.attack = self.player.attack

    if self.attack == 'Neutral' then
        self.area:addGameObject('Projectile', self.x + 8*math.cos(self.r), self.y + 8*math.sin(self.r), {r = self.r, attack = self.attack, damage_multiplier = 0.5})

    elseif self.attack == 'Double' then
        self.area:addGameObject('Projectile', self.x + 8*math.cos(self.r + math.pi/12), self.y + 8*math.sin(self.r + math.pi/12), {r = self.r + math.pi/12, attack = self.attack, damage_multiplier = 0.5})
        self.area:addGameObject('Projectile', self.x + 8*math.cos(self.r - math.pi/12), self.y + 8*math.sin(self.r - math.pi/12), {r = self.r - math.pi/12, attack = self.attack, damage_multiplier = 0.5})

    elseif self.attack == 'Triple' then
        self.area:addGameObject('Projectile', self.x + 8*math.cos(self.r), self.y + 8*math.sin(self.r), {r = self.r, attack = self.attack, damage_multiplier = 0.5})
        self.area:addGameObject('Projectile', self.x + 8*math.cos(self.r + math.pi/12), self.y + 8*math.sin(self.r + math.pi/12), {r = self.r + math.pi/12, attack = self.attack, damage_multiplier = 0.5})
        self.area:addGameObject('Projectile', self.x + 8*math.cos(self.r - math.pi/12), self.y + 8*math.sin(self.r - math.pi/12), {r = self.r - math.pi/12, attack = self.attack, damage_multiplier = 0.5})

    elseif self.attack == 'Rapid' then
        self.area:addGameObject('Projectile', self.x + 8*math.cos(self.r), self.y + 8*math.sin(self.r), {r = self.r, attack = self.attack, damage_multiplier = 0.5})

    elseif self.attack == 'Spread' then
        local random_angle = random(-math.pi/8, math.pi/8)
        self.area:addGameObject('Projectile', self.x + 8*math.cos(self.r + random_angle), self.y + 8*math.sin(self.r + random_angle), {r = self.r + random_angle, attack = self.attack, damage_multiplier = 0.5})

    elseif self.attack == 'Back' then
        self.area:addGameObject('Projectile', self.x + 8*math.cos(self.r), self.y + 8*math.sin(self.r), {r = self.r, attack = self.attack, damage_multiplier = 0.5})
        self.area:addGameObject('Projectile', self.x + 8*math.cos(self.r - math.pi), self.y + 8*math.sin(self.r - math.pi), {r = self.r - math.pi, attack = self.attack, damage_multiplier = 0.5})

    elseif self.attack == 'Side' then
        self.area:addGameObject('Projectile', self.x + 8*math.cos(self.r), self.y + 8*math.sin(self.r), {r = self.r, attack = self.attack, damage_multiplier = 0.5})
        self.area:addGameObject('Projectile', self.x + 8*math.cos(self.r - math.pi/2), self.y + 8*math.sin(self.r - math.pi/2), {r = self.r - math.pi/2, attack = self.attack, damage_multiplier = 0.5})
        self.area:addGameObject('Projectile', self.x + 8*math.cos(self.r + math.pi/2), self.y + 8*math.sin(self.r + math.pi/2), {r = self.r + math.pi/2, attack = self.attack, damage_multiplier = 0.5})

    elseif self.attack == 'Homing' then
        self.area:addGameObject('Projectile', self.x + 8*math.cos(self.r), self.y + 8*math.sin(self.r), {r = self.r, attack = self.attack, damage_multiplier = 0.5})

    elseif self.attack == 'Blast' then
        for i = 1, 12+self.player.additional_blast_projectile do
            local random_angle = random(-math.pi/6, math.pi/6)
            self.area:addGameObject('Projectile', self.x + 8*math.cos(self.r + random_angle), self.y + 8*math.sin(self.r + random_angle), 
            {r = self.r + random_angle, attack = self.attack, damage_multiplier = 0.5, v = random(500, 600)})
        end

    elseif self.attack == 'Spin' then
        self.area:addGameObject('Projectile', self.x + 8*math.cos(self.r), self.y + 8*math.sin(self.r), {r = self.r, attack = self.attack, damage_multiplier = 0.5})

    elseif self.attack == 'Bounce' then
        self.area:addGameObject('Projectile', self.x + 8*math.cos(self.r), self.y + 8*math.sin(self.r), {r = self.r, attack = self.attack, damage_multiplier = 0.5, bounce = 4 + self.player.additional_bounce})

    elseif self.attack == 'Lightning' then
        local x1, y1 = self.x + 8*math.cos(self.r), self.y + 8*math.sin(self.r)
        local cx, cy = x1 + 24*math.cos(self.r), y1 + 24*math.sin(self.r)
        local enemy_amount_to_attack = 1 + self.player.additional_lightning_bolt

        -- Find closest enemy
        local nearby_enemies = self.area:getAllGameObjectsThat(function(e)
            for _, enemy in ipairs(enemies) do
                if self.player.lightning_targets_projectiles then
                    if (e:is(_G[enemy]) or e:is(EnemyProjectile)) and (distance(e.x, e.y, cx, cy) < 64*self.player.lightning_trigger_distance_multiplier) then
                        return true
                    end
                else
                    if e:is(_G[enemy]) and (distance(e.x, e.y, cx, cy) < 64*self.player.lightning_trigger_distance_multiplier) then
                        return true
                    end
                end
            end
        end)
        table.sort(nearby_enemies, function(a, b) return distance(a.x, a.y, cx, cy) < distance(b.x, b.y, cx, cy) end)
        local closest_enemies = fn.first(nearby_enemies, enemy_amount_to_attack)

        -- Attack closest enemies
        for i, closest_enemy in ipairs(closest_enemies) do
            self.timer:after((i-1)*0.05, function()
                if closest_enemy then
                    closest_enemy:hit(10)
                    local x2, y2 = closest_enemy.x, closest_enemy.y
                    self.area:addGameObject('LightningLine', 0, 0, {x1 = x1, y1 = y1, x2 = x2, y2 = y2})
                    for i = 1, love.math.random(4, 8) do self.area.room.explode_particles:add(x1, y1, nil, nil, table.random({default_color, boost_color})) end
                    for i = 1, love.math.random(4, 8) do self.area.room.explode_particles:add(x2, y2, nil, nil, table.random({default_color, boost_color})) end
                end
            end)
        end

    elseif self.attack == 'Flame' then
        local random_angle = random(-math.pi/16, math.pi/16)
        self.area:addGameObject('Projectile', self.x + 8*math.cos(self.r + random_angle), self.y + 8*math.sin(self.r + random_angle), 
        {r = self.r + random_angle, attack = self.attack, damage_multiplier = 0.5, s = 2})

    elseif self.attack == '2Split' then
        self.area:addGameObject('Projectile', self.x + 8*math.cos(self.r), self.y + 8*math.sin(self.r), {r = self.r, attack = self.attack, damage_multiplier = 0.5})

    elseif self.attack == '4Split' then
        self.area:addGameObject('Projectile', self.x + 8*math.cos(self.r), self.y + 8*math.sin(self.r), {r = self.r, attack = self.attack, damage_multiplier = 0.5, s = 3})

    elseif self.attack == 'Explode' then
        self.area:addGameObject('Projectile', self.x + 8*math.cos(self.r), self.y + 8*math.sin(self.r), {r = self.r, attack = self.attack, damage_multiplier = 0.5, s = 3})

    elseif self.attack == 'Laser' then
        local x1 = self.x + 8*math.cos(self.r)
        local y1 = self.y + 8*math.sin(self.r)
        local x2 = self.x + 1024*math.cos(self.r)
        local y2 = self.y + 1024*math.sin(self.r)

        self.area:addGameObject('ProjectileDeathEffect', x1, y1, {w = 6*self.player.laser_width_multiplier, attack = self.attack, damage_multiplier = 0.5, color = hp_color, r = self.r + math.pi/4})
        local wm = 1*self.player.laser_width_multiplier
        local x1n, y1n, x2n, y2n = x1 + wm*16*math.cos(self.r - math.pi/2), y1 + wm*16*math.sin(self.r - math.pi/2), x1 + wm*16*math.cos(self.r + math.pi/2), y1 + wm*16*math.sin(self.r + math.pi/2)
        local x3n, y3n, x4n, y4n = x2 + wm*16*math.cos(self.r - math.pi/2), y2 + wm*16*math.sin(self.r - math.pi/2), x2 + wm*16*math.cos(self.r + math.pi/2), y2 + wm*16*math.sin(self.r + math.pi/2)
        self.area:addGameObject('LaserLine', 0, 0, {x1 = x1, y1 = y1, x2 = x2, y2 = y2, angle = self.r, wm = wm})
        local objects = self.area:queryPolygonArea({x1n, y1n, x2n, y2n, x3n, y3n, x4n, y4n}, {'EnemyProjectile', enemies})
        for _, object in ipairs(objects) do object:hit(100) end
    end
end
