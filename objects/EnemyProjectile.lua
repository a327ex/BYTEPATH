EnemyProjectile = GameObject:extend()

function EnemyProjectile:new(area, x, y, opts)
    EnemyProjectile.super.new(self, area, x, y, opts)

    self.s = opts.s or 2.5
    self.v = opts.v or 200
    self.w, self.h = self.s, self.s

    self.shape = HC.circle(self.x, self.y, self.s)
    self.shape.id = self.id
    self.shape.object = self
    self.shape.tag = 'EnemyProjectile'

    self.vx, self.vy = self.v*math.cos(self.r), self.v*math.sin(self.r)
    self.previous_x, self.previous_y = self.x, self.y

    self.damage = 10
    self.hp = opts.hp or 1

    if self.mine then
        self.rv = table.random({random(-12*math.pi, -10*math.pi), random(10*math.pi, 12*math.pi)})
        self.timer:tween(random(12, 14), self, {rv = random(self.rv/12, self.rv/10)}, 'linear', function() self:die() end)
    end

    if self.shield then
        self.orbitting = true
        self.orbit_distance = random(32, 48)
        self.orbit_offset = random(0, 2*math.pi)
        self.orbit_speed = random(-6, 6)
    end

    if self.homing then self.timer:after(random(0.4, 0.8), function() self.homing = false end) end
    if self.orbitter then self.invulnerable = true end
    if self.trailer then 
        self.homing = true
        self.homing_force = 0.02
    end

    if self.fast_slow then
        local initial_v = self.v
        self.timer:tween('fast_slow_first', 0.2, self, {v = 2*initial_v}, 'in-out-cubic', function()
            self.timer:tween('fast_slow_second', 0.3, self, {v = initial_v/2}, 'linear')
        end)
    end

    if self.projectile_ninety_degree_change then
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
end

function EnemyProjectile:update(dt)
    EnemyProjectile.super.update(self, dt)

    if self.orbitter then
        self.invulnerable = false
        if self.x <= 0 then self.invulnerable = true end
        if self.y <= 0 then self.invulnerable = true end
        if self.x >= gw then self.invulnerable = true end
        if self.y >= gh then self.invulnerable = true end
    end

    if self.mine then self.r = self.r + self.rv*dt end
    if self.shield and self.orbitting then
        self.shape:moveTo(self.orbitter.x + self.orbit_distance*math.cos(self.orbit_speed*time + self.orbit_offset), self.orbitter.y + self.orbit_distance*math.sin(self.orbit_speed*time + self.orbit_offset))
    end

    if self.homing then
        self.target = current_room.player
        if self.target and self.target.dead then self.target = nil end
        if self.target then
            local projectile_heading_x, projectile_heading_y = Vector.normalize(self.vx, self.vy)
            local angle = math.atan2(self.target.y - self.y, self.target.x - self.x)
            local to_target_heading_x, to_target_heading_y = Vector.normalize(math.cos(angle), math.sin(angle))
            local final_heading_x, final_heading_y = Vector.normalize(projectile_heading_x + 0.1*current_room.player.pspd_multiplier.value*to_target_heading_x, 
            projectile_heading_y + 0.1*current_room.player.pspd_multiplier.value*to_target_heading_y)
            self.vx, self.vy = self.v*final_heading_x, self.v*final_heading_y
            self.r = Vector.angle(self.vx, self.vy)
        else self.vx, self.vy = self.v*math.cos(self.r), self.v*math.sin(self.r) end
    else self.vx, self.vy = self.v*math.cos(self.r), self.v*math.sin(self.r) end

    self.r = Vector.angle(self.vx, self.vy)
    self.shape:setRotation(self.r)

    if self.shield or self.orbitting then
        local x, y = self.shape:center()
        local dx, dy = x - self.previous_x, y - self.previous_y
        self.r = Vector.angle(dx, dy)
    end

    for _, shape in ipairs(self:enter('Player')) do
        local object = shape.object
        if object then
            object:hit(self.damage, 'Projectile')
            self:die()
        end
    end

    for _, shape in ipairs(self:enter('Projectile')) do
        local object = shape.object
        if object then
            self:hit()
            if object.pierce > 0 then object.pierce = object.pierce - 1
            else object:die() end
        end
    end

    if self.x < 0 then self:die() end
    if self.y < 0 then self:die() end
    if self.x > gw then self:die() end
    if self.y > gh then self:die() end

    self.previous_x, self.previous_y = self.shape:center()
    self.shape:move(self.vx*dt, self.vy*dt)
    self.shape:setRotation(self.r)
    self.x, self.y = self.shape:center()
end

function EnemyProjectile:draw()
    love.graphics.setColor(hp_color)
    pushRotate(self.x, self.y, self.r)
    local w, h = 2*self.s, self.s - self.s/4
    love.graphics.rectangle('fill', self.x - w, self.y - h, 2*w, h)
    if self.hp == 2 then love.graphics.rectangle('line', self.x - 2*w, self.y - 2*h, 4*w, 3*h) end
    love.graphics.pop()
    love.graphics.setColor(default_color)
end

function EnemyProjectile:destroy()
    EnemyProjectile.super.destroy(self)
end

function EnemyProjectile:hit()
    self.hp = self.hp - 1
    if self.hp <= 0 then self:die() end
end

function EnemyProjectile:die()
    if self.invulnerable then return end
    self.dead = true
    self.area:addGameObject('ProjectileDeathEffect', self.x, self.y, {color = hp_color, w = 3*self.s})
end

function EnemyProjectile:setHoming()
    if self.dead then return end
    self.v = 100
    self.shield = false
    self.orbitting = false
    self.orbitter = false
    self.homing = true
    self.timer:after(random(0.8, 1.0), function() self.homing = false end)
end
