Projectile = GameObject:extend()

function Projectile:new(area, x, y, opts)
    Projectile.super.new(self, area, x, y, opts)

    if self.attack ~= 'Flame' then playGameShoot1() end

    if current_room.player.size_multiplier > 1 then self.s = (opts.s or 2.5)*(current_room.player.projectile_size_multiplier + (current_room.player.size_multiplier - 1)/1.5)
    else self.s = (opts.s or 2.5)*current_room.player.projectile_size_multiplier end
    self.v = (opts.v or 200)*current_room.player.pspd_multiplier.value
    self.vx, self.vy = self.v*math.cos(self.r), self.v*math.sin(self.r)
    self.w, self.h = self.s, self.s

    self.color = opts.color or attacks[self.attack].color
    self.shape = HC.circle(self.x, self.y, self.s)
    self.shape.id = self.id
    self.shape.object = self
    self.shape.tag = 'Projectile'
    self.damage = 100
    self.shield = current_room.player.chances.shield_projectile_chance:next()
    self.pierce = current_room.player.projectile_pierce

    -- Attack setup
    if self.attack == 'Rapid' then
        self.graphics_types = {'rgb_shift'}

    elseif self.attack == 'Spread' then
        self.graphics_types = {'rgb_shift'}

    elseif self.attack == 'Homing' then
        self.damage = 150
        self.timer:every(0.02, function()
            local r = Vector.angle(self.vx, self.vy)
            self.area.room.trail_particles:add(self.x - 1.0*self.s*math.cos(r), self.y - 1.0*self.s*math.sin(r), random(1, 3), self.color, random(0.1, 0.15))
        end)
        self.v = self.v*current_room.player.homing_speed_multiplier
        self.vx, self.vy = self.v*math.cos(self.r), self.v*math.sin(self.r)
        local target_offscreen = true
        local run = 0
        while target_offscreen and run < 20 do
            self.target = table.random(self.area.enemies)
            if target then target_offscreen = (self.target.x > gw) or (self.target.x < 0) end
            run = run + 1
        end
        self.timer:every(1, function() if self.target and self.target.dead then self.target = table.random(self.area.enemies) end end)

    elseif self.attack == 'Blast' then
        self.damage = 75
        self.color = table.random(negative_colors)
        if self.shield and current_room.player.blast_shield then
            self.timer:tween(6*random(0.4, 0.6)*current_room.player.projectile_duration_multiplier, self, {v = 0}, 'linear', function() 
                if current_room.player.projectiles_explode_on_expiration and not self.dont_explode then 
                    self.area:addGameObject('Explosion', self.x, self.y, {color = self.color, w = random(24, 28), from_explode_on_expiration = true}) 
                end
                self:die() 
            end)
        else
            self.timer:tween(random(0.4, 0.6)*current_room.player.projectile_duration_multiplier, self, {v = 0}, 'linear', function() 
                if current_room.player.projectiles_explode_on_expiration and not self.dont_explode then 
                    self.area:addGameObject('Explosion', self.x, self.y, {color = self.color, w = random(24, 28), from_explode_on_expiration = true}) 
                end
                self:die() 
            end)
        end

    elseif self.attack == 'Spin' then
        if current_room.player.fixed_spin_direction then self.rv = random(math.pi, 2*math.pi)
        else self.rv = table.random({random(-2*math.pi, -math.pi), random(math.pi, 2*math.pi)}) end
        self.timer:after(random(2.4, 3.2)*current_room.player.projectile_duration_multiplier, function() 
            if current_room.player.projectiles_explode_on_expiration and not self.dont_explode then 
                self.area:addGameObject('Explosion', self.x, self.y, {color = self.color, from_explode_on_expiration = true}) 
            end
            self:die() 
            if current_room.player.chances.spin_projectile_on_expiration_chance:next() then
                self.area:addGameObject('Projectile', self.x, self.y, {color = self.color, r = self.r, attack = 'Spin'})
            end
        end)
        self.timer:every(0.02, function()
            self.area.room.projectile_trails:add(self.x, self.y, Vector.angle(self.vx, self.vy), self.s, self.color)
        end)

    elseif self.attack == 'Flame' then
        playGameFlame()
        self.damage = 60
        self.timer:tween(random(0.6, 1.0)*current_room.player.projectile_duration_multiplier, self, {v = 0}, 'in-out-cubic', function() 
            if current_room.player.projectiles_explode_on_expiration and not self.dont_explode then 
                self.area:addGameObject('Explosion', self.x, self.y, {color = self.color, w = random(24, 28), from_explode_on_expiration = true}) 
            end
            self:die() 
        end)
        self.timer:every(0.05, function()
            self.area.room.projectile_trails:add(self.x, self.y, Vector.angle(self.vx, self.vy), self.s, self.color)
        end)

    elseif self.attack == '2Split' then
        self.timer:every(0.02, function()
            local r = Vector.angle(self.vx, self.vy)
            self.area.room.trail_particles:add(self.x - 1.0*self.s*math.cos(r), self.y - 1.0*self.s*math.sin(r), random(1, 3), self.color, random(0.1, 0.15))
        end)

    elseif self.attack == '4Split' then
        self.timer:every(0.02, function()
            local r = Vector.angle(self.vx, self.vy)
            self.area.room.trail_particles:add(self.x - 1.0*self.s*math.cos(r), self.y - 1.0*self.s*math.sin(r), random(1, 3), self.color, random(0.1, 0.15))
        end)

    elseif self.attack == 'Explode' then
        self.damage = 200
        self.timer:every(0.02, function()
            local r = Vector.angle(self.vx, self.vy)
            self.area.room.trail_particles:add(self.x - 1.0*self.s*math.cos(r), self.y - 1.0*self.s*math.sin(r), random(1, 3), self.color, random(0.1, 0.15))
        end)
    end

    if self.mine then
        self.rv = table.random({random(-12*math.pi, -10*math.pi), random(10*math.pi, 12*math.pi)})
        self.timer:after(random(8, 12)*current_room.player.projectile_duration_multiplier, function()
            self.area:addGameObject('Explosion', self.x, self.y, {color = self.color})
            self:die()
        end)
    end

    if current_room.player.projectile_ninety_degree_change then
		self.timer:after(0.2, function()
      		self.ninety_degree_direction = table.random({-1, 1})
        	self.r = self.r + self.ninety_degree_direction*math.pi/2
            self.timer:every('ninety_degree_first', 0.25/current_room.player.projectile_angle_change_frequency_multiplier, function()
                self.r = self.r - self.ninety_degree_direction*math.pi/2
                self.timer:after('ninety_degree_second', 0.1/current_room.player.projectile_angle_change_frequency_multiplier, function()
                    self.r = self.r - self.ninety_degree_direction*math.pi/2
                    self.ninety_degree_direction = -1*self.ninety_degree_direction
                end)
            end)
      	end)
    end

    if current_room.player.projectile_random_degree_change then
		self.timer:after(0.2, function()
            self.r = self.r + table.random({-1, 1})*math.pi/6
            self.timer:every('forty_five_degree', 0.25/current_room.player.projectile_angle_change_frequency_multiplier, function()
                self.r = self.r + random(-math.pi/2, math.pi/2)
            end)
      	end)
    end

    if current_room.player.wavy_projectiles then
        local direction = table.random({-1, 1})
        self.timer:tween(0.25, self, {r = self.r + current_room.player.projectile_waviness_multiplier*direction*math.pi/8}, 'linear', function()
            self.timer:tween(0.25, self, {r = self.r - current_room.player.projectile_waviness_multiplier*direction*math.pi/4}, 'linear')
        end)
        self.timer:every(0.75, function()
            self.timer:tween(0.25, self, {r = self.r + current_room.player.projectile_waviness_multiplier*direction*math.pi/4}, 'linear', function()
                self.timer:tween(0.5, self, {r = self.r - current_room.player.projectile_waviness_multiplier*direction*math.pi/4}, 'linear')
            end)
        end)
    end

    if current_room.player.fast_slow then
        local initial_v = self.v
        self.timer:tween('fast_slow_first', 0.2, self, {v = 2*initial_v*current_room.player.projectile_acceleration_multiplier}, 'in-out-cubic', function()
            self.timer:tween('fast_slow_second', 0.3, self, {v = current_room.player.projectile_deceleration_multiplier*initial_v/2}, 'linear')
        end)
    end

    if current_room.player.slow_fast then
        local initial_v = self.v
        self.timer:tween('slow_fast_first', 0.2, self, {v = current_room.player.projectile_deceleration_multiplier*initial_v/2}, 'in-out-cubic', function()
            self.timer:tween('slow_fast_second', 0.3, self, {v = 2*initial_v*current_room.player.projectile_acceleration_multiplier}, 'linear')
        end)
    end

    self.damage = self.damage*(self.damage_multiplier or 1)
    self.damage = self.damage*(current_room.player.damage_multiplier or 1)

    if self.shield then
        self.damage = self.damage*(current_room.player.shield_projectile_damage_multiplier)
        self.orbit_distance = random(32, 64)
        self.orbit_speed = random(-6, 6)
        self.orbit_offset = random(0, 2*math.pi)
        self.timer:after(6*current_room.player.projectile_duration_multiplier, function() 
            if current_room.player.projectiles_explode_on_expiration and not self.dont_explode then 
                self.area:addGameObject('Explosion', self.x, self.y, {color = self.color, w = random(24, 28), from_explode_on_expiration = true}) 
            end
            self:die() 
        end)
        self.invisible = true
        self.timer:after(0.05, function() self.invisible = false end)
    end

    self.previous_x, self.previous_y = self.shape:center()

    if self.attack == 'Homing' or self.attack == '2Split' or self.attack == '4Split' or self.attack == 'Explode' then
        self.mesh_left = love.graphics.newMesh({{-2*self.s, 0}, {0, -1.5*self.s}, {0, 1.5*self.s}}, 'fan', 'static')
        self.mesh_right = love.graphics.newMesh({{0, -1.5*self.s}, {0, 1.5*self.s}, {1.5*self.s, 0}}, 'fan', 'static')
    else
        local h = self.s - self.s/4
        self.mesh_left = love.graphics.newMesh({{-2*self.s, -h/2}, {0, -h/2}, {0, h/2}, {-2*self.s, h/2}}, 'fan', 'static')
        self.mesh_right = love.graphics.newMesh({{0, -h/2}, {2*self.s, -h/2}, {2*self.s, h/2}, {0, h/2}}, 'fan', 'static')
    end

    self.timer:after(20*current_room.player.projectile_duration_multiplier, function() 
        self:die()
    end)
end

function Projectile:update(dt)
    Projectile.super.update(self, dt)

    -- Collision
    if self.bounce and self.bounce > 1 then
        if self.x < 0 then
            self.r = math.pi - self.r
            self.bounce = self.bounce - 1
        end
        if self.y < 0 then
            self.r = 2*math.pi - self.r
            self.bounce = self.bounce - 1
        end
        if self.x > gw then
            self.r = math.pi - self.r
            self.bounce = self.bounce - 1
        end
        if self.y > gh then
            self.r = 2*math.pi - self.r
            self.bounce = self.bounce - 1
        end
    else
        if self.x < 0 then self:die({wall_split_angle = 0}) end
        if self.y < 0 then self:die({wall_split_angle = math.pi/2}) end
        if self.x > gw then self:die({wall_split_angle = -math.pi}) end
        if self.y > gh then self:die({wall_split_angle = -math.pi/2}) end
    end

    -- Spin or Mine
    if self.attack == 'Spin' or self.mine then self.r = self.r + self.rv*dt end

    -- Homing
    if self.attack == 'Homing' then
        -- Move towards target
        if self.target then
            local projectile_heading_x, projectile_heading_y = Vector.normalize(self.vx, self.vy)
            local angle = math.atan2(self.target.y - self.y, self.target.x - self.x)
            local to_target_heading_x, to_target_heading_y = Vector.normalize(math.cos(angle), math.sin(angle))
            local final_heading_x, final_heading_y = Vector.normalize(projectile_heading_x + 0.1*current_room.player.pspd_multiplier.value*to_target_heading_x, 
            projectile_heading_y + 0.1*current_room.player.pspd_multiplier.value*to_target_heading_y)
            self.vx, self.vy = self.v*final_heading_x, self.v*final_heading_y
        end

    -- Normal movement
    else self.vx, self.vy = self.v*math.cos(self.r), self.v*math.sin(self.r) end

    -- Shield
    if self.shield then
        local player = current_room.player
        self.shape:moveTo(player.x + self.orbit_distance*math.cos(self.orbit_speed*time + self.orbit_offset), player.y + self.orbit_distance*math.sin(self.orbit_speed*time + self.orbit_offset))
        local x, y = self.shape:center()
        local dx, dy = x - self.previous_x, y - self.previous_y
        self.r = Vector.angle(dx, dy)
    end

    --[[
    for _, shape in ipairs(self:enter('Enemy')) do
        local object = shape.object
        if object then
            object:hit(self.damage, self.x, self.y, self.r)
            if object.hp <= 0 then current_room.player:onKill(object) end
            if self.pierce > 0 then 
                self.pierce = self.pierce - 1
                if self.attack == 'Explode' then self.area:addGameObject('Explosion', self.x, self.y, {color = self.color}) end
            else self:die() end
        end
    end
    ]]--

    -- Move
    self.previous_x, self.previous_y = self.shape:center()
    self.shape:move(self.vx*dt, self.vy*dt)
    self.shape:setRotation(self.r)
    self.x, self.y = self.shape:center()
end

function Projectile:draw()
    if self.invisible then return end
    pushRotate(self.x, self.y, Vector.angle(self.vx, self.vy)) 
    if self.attack == 'Homing' or self.attack == '2Split' or self.attack == '4Split' or self.attack == 'Explode' then
        love.graphics.setColor(self.color)
        love.graphics.draw(self.mesh_left, self.x, self.y)
        love.graphics.setColor(default_color)
        love.graphics.draw(self.mesh_right, self.x, self.y)
    else
        love.graphics.setColor(self.color)
        if self.attack == 'Spread' then love.graphics.setColor(table.random(all_colors)) end
        if self.attack == 'Bounce' then love.graphics.setColor(table.random(default_colors)) end
        love.graphics.draw(self.mesh_left, self.x, self.y)
        love.graphics.setColor(default_color)
        if self.attack == 'Flame' then love.graphics.setColor(self.color) end
        love.graphics.draw(self.mesh_right, self.x, self.y)
        love.graphics.setLineWidth(1)
    end
    love.graphics.pop()
end

function Projectile:destroy()
    Projectile.super.destroy(self)
end

function Projectile:die(opts)
    local opts = opts or {}
    self.dead = true
    if self.attack == 'Spread' then self.area:addGameObject('ProjectileDeathEffect', self.x, self.y, {color = table.random(all_colors), w = 3*self.s})
    else self.area:addGameObject('ProjectileDeathEffect', self.x, self.y, {color = self.color or default_color, w = 3*self.s}) end

    if self.attack == '2Split' and opts.wall_split_angle then -- Wall split
        local split_split = current_room.player.chances.split_projectiles_split_chance:next()
        if self.split_split then split_split = false end
        local r = opts.wall_split_angle
        self.area:addGameObject('Projectile', self.x + 10*math.cos(r - math.pi/4), self.y + 10*math.sin(r - math.pi/4), 
        {r = r - math.pi/4, attack = split_split and '2Split' or 'Neutral', color = self.color, split_split = split_split})
        self.area:addGameObject('Projectile', self.x + 10*math.cos(r + math.pi/4), self.y + 10*math.sin(r + math.pi/4), 
        {r = r + math.pi/4, attack = split_split and '2Split' or 'Neutral', color = self.color, split_split = split_split})
    elseif self.attack == '2Split' and not opts.wall_split_angle then -- Enemy split
        local split_split = current_room.player.chances.split_projectiles_split_chance:next()
        if self.split_split then split_split = false end
        self.area:addGameObject('Projectile', self.x + 10*math.cos(self.r - math.pi/4), self.y + 10*math.sin(self.r - math.pi/4), 
        {r = self.r - math.pi/4, attack = split_split and '2Split' or 'Neutral', color = self.color, split_split = split_split})
        self.area:addGameObject('Projectile', self.x + 10*math.cos(self.r + math.pi/4), self.y + 10*math.sin(self.r + math.pi/4), 
        {r = self.r + math.pi/4, attack = split_split and '2Split' or 'Neutral', color = self.color, split_split = split_split})
    end

    if self.attack == '4Split' then
        local split_split = current_room.player.chances.split_projectiles_split_chance:next()
        if self.split_split then split_split = false end
        local angles = {math.pi/4, 3*math.pi/4, -math.pi/4, -3*math.pi/4}
        for i, angle in ipairs(angles) do self.area:addGameObject('Projectile', self.x + 10*math.cos(angle), self.y + 10*math.sin(angle), 
        {r = angle, attack = split_split and '4Split' or 'Neutral', color = self.color, split_split = split_split}) end
    end

    if self.attack == 'Explode' then
        self.area:addGameObject('Explosion', self.x, self.y, {color = self.color})
    end
end
