Projectile = GameObject:extend()

function Projectile:new(area, x, y, opts)
    Projectile.super.new(self, area, x, y, opts)

    self.s = opts.s or 2.5
    self.v = opts.v or 200

    self.color = attacks[self.attack].color

    self.collider = self.area.world:newCircleCollider(self.x, self.y, self.s)
    self.collider:setObject(self)
    self.collider:setCollisionClass('Projectile')
    self.collider:setLinearVelocity(self.v*math.cos(self.r), self.v*math.sin(self.r))

    self.damage = 100

    if self.attack == 'Homing' then
        self.timer:every(0.02, function()
            local r = Vector(self.collider:getLinearVelocity()):angle()
            self.area:addGameObject('TrailParticle', self.x - 1.0*self.s*math.cos(r), self.y - 1.0*self.s*math.sin(r), 
            {parent = self, r = random(1, 3), d = random(0.1, 0.15), color = skill_point_color}) 
        end)
    end

    if self.attack == 'Blast' then
        self.damage = 75
        self.color = table.random(negative_colors)
        self.timer:tween(random(0.4, 0.6), self, {v = 0}, 'linear', function() self:die() end)
    end

    if self.attack == 'Spin' then
        self.rv = table.random({random(-2*math.pi, -math.pi), random(math.pi, 2*math.pi)})
        self.timer:after(random(2.4, 3.2), function() self:die() end)
        self.timer:every(0.05, function()
            self.area:addGameObject('ProjectileTrail', self.x, self.y, {r = Vector(self.collider:getLinearVelocity()):angle(), color = self.color, s = self.s})
        end)
    end

    if self.mine then
        self.rv = table.random({random(-12*math.pi, -10*math.pi), random(10*math.pi, 12*math.pi)})
        self.timer:after(random(8, 12), function()
            -- Explosion
        end)
    end

    if current_room.player.projectile_ninety_degree_change then
		self.timer:after(0.2, function()
      		self.ninety_degree_direction = table.random({-1, 1})
        	self.r = self.r + self.ninety_degree_direction*math.pi/2
            self.timer:every('ninety_degree_first', 0.25, function()
                self.r = self.r - self.ninety_degree_direction*math.pi/2
                self.timer:after('ninety_degree_second', 0.1, function()
                    self.r = self.r - self.ninety_degree_direction*math.pi/2
                    self.ninety_degree_direction = -1*self.ninety_degree_direction
                end)
            end)
      	end)
    end

    if current_room.player.wavy_projectiles then
        local direction = table.random({-1, 1})
        self.timer:tween(0.25, self, {r = self.r + direction*math.pi/8}, 'linear', function()
            self.timer:tween(0.25, self, {r = self.r - direction*math.pi/4}, 'linear')
        end)
        self.timer:every(0.75, function()
            self.timer:tween(0.25, self, {r = self.r + direction*math.pi/4}, 'linear', function()
                self.timer:tween(0.5, self, {r = self.r - direction*math.pi/4}, 'linear')
            end)
        end)
    end

    if current_room.player.fast_slow then
        local initial_v = self.v
        self.timer:tween('fast_slow_first', 0.2, self, {v = 2*initial_v}, 'in-out-cubic', function()
            self.timer:tween('fast_slow_second', 0.3, self, {v = initial_v/2}, 'linear')
        end)
    end

    if current_room.player.slow_fast then
        local initial_v = self.v
        self.timer:tween('slow_fast_first', 0.2, self, {v = initial_v/2}, 'in-out-cubic', function()
            self.timer:tween('slow_fast_second', 0.3, self, {v = 2*initial_v}, 'linear')
        end)
    end

    if self.shield then
        self.orbit_distance = random(32, 64)
        self.orbit_speed = random(-6, 6)
        self.orbit_offset = random(0, 2*math.pi)
        self.timer:after(6, function() self:die() end)
    end

    self.previous_x, self.previous_y = self.collider:getPosition()
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
        if self.x < 0 then self:die() end
        if self.y < 0 then self:die() end
        if self.x > gw then self:die() end
        if self.y > gh then self:die() end
    end

    -- Spin or Mine
    if self.attack == 'Spin' or self.mine then self.r = self.r + self.rv*dt end

    -- Homing
    if self.attack == 'Homing' then
        -- Acquire new target
        if not self.target then
            local targets = self.area:getAllGameObjectsThat(function(e)
                for _, enemy in ipairs(enemies) do
                    if e:is(_G[enemy]) and (distance(e.x, e.y, self.x, self.y) < 400) then
                        return true
                    end
                end
            end)
            self.target = table.remove(targets, love.math.random(1, #targets))
        end
        if self.target and self.target.dead then self.target = nil end

        -- Move towards target
        if self.target then
            local projectile_heading = Vector(self.collider:getLinearVelocity()):normalized()
            local angle = math.atan2(self.target.y - self.y, self.target.x - self.x)
            local to_target_heading = Vector(math.cos(angle), math.sin(angle)):normalized()
            local final_heading = (projectile_heading + 0.1*to_target_heading):normalized()
            self.collider:setLinearVelocity(self.v*final_heading.x, self.v*final_heading.y)
        end

    -- Normal movement
    else self.collider:setLinearVelocity(self.v*math.cos(self.r), self.v*math.sin(self.r)) end

    -- Shield
    if self.shield then
        local player = current_room.player
        self.collider:setPosition(player.x + self.orbit_distance*math.cos(self.orbit_speed*time + self.orbit_offset), player.y + self.orbit_distance*math.sin(self.orbit_speed*time + self.orbit_offset))
        local x, y = self.collider:getPosition()
        local dx, dy = x - self.previous_x, y - self.previous_y
        self.r = Vector(dx, dy):angle()

        self.invisible = true
        self.timer:after(0.05, function() self.invisible = false end)

        self.timer:after(4, function() self:die() end)
    end

    if self.collider:enter('Enemy') then
        local collision_data = self.collider:getEnterCollisionData('Enemy')
        local object = collision_data.collider:getObject()

        if object then
            object:hit(self.damage)
            self:die()
            if object.hp <= 0 then current_room.player:onKill() end
        end
    end

    self.previous_x, self.previous_y = self.collider:getPosition()
end

function Projectile:draw()
    pushRotate(self.x, self.y, Vector(self.collider:getLinearVelocity()):angle()) 
    if self.attack == 'Homing' then
        love.graphics.setColor(self.color)
        love.graphics.polygon('fill', self.x - 2*self.s, self.y, self.x, self.y - 1.5*self.s, self.x, self.y + 1.5*self.s)
        love.graphics.setColor(default_color)
        love.graphics.polygon('fill', self.x, self.y - 1.5*self.s, self.x, self.y + 1.5*self.s, self.x + 1.5*self.s, self.y)
    else
        love.graphics.setLineWidth(self.s - self.s/4)
        love.graphics.setColor(self.color)
        if self.attack == 'Spread' then love.graphics.setColor(table.random(all_colors)) end
        if self.attack == 'Bounce' then love.graphics.setColor(table.random(default_colors)) end
        love.graphics.line(self.x - 2*self.s, self.y, self.x, self.y)
        love.graphics.setColor(default_color)
        love.graphics.line(self.x, self.y, self.x + 2*self.s, self.y)
        love.graphics.setLineWidth(1)
    end
    love.graphics.pop()
end

function Projectile:destroy()
    Projectile.super.destroy(self)
end

function Projectile:die()
    self.dead = true
    if self.attack == 'Spread' then self.area:addGameObject('ProjectileDeathEffect', self.x, self.y, {color = table.random(all_colors), w = 3*self.s})
    else self.area:addGameObject('ProjectileDeathEffect', self.x, self.y, {color = self.color or default_color, w = 3*self.s}) end
end
