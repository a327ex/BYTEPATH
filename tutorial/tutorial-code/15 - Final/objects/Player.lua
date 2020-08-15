Player = GameObject:extend()

function Player:new(area, x, y, opts)
    Player.super.new(self, area, x, y, opts)

    self.x, self.y = x, y
    self.w, self.h = 12, 12
    self.collider = self.area.world:newCircleCollider(self.x, self.y, self.w)
    self.collider:setObject(self)
    self.collider:setCollisionClass('Player')

    -- Movement
    self.r = -math.pi/2
    self.rv = 1.66*math.pi
    self.v = 0
    self.base_max_v = 100
    self.max_v = self.base_max_v
    self.a = 100

    -- Cycle
    self.cycle_timer = 0
    self.cycle_cooldown = 5

    -- Boost
    self.max_boost = 100
    self.boost = self.max_boost
    self.boosting = false
    self.can_boost = true
    self.boost_timer = 0
    self.boost_cooldown = 2

    -- HP
    self.max_hp = 100
    self.hp = self.max_hp

    -- Ammo
    self.max_ammo = 100
    self.ammo = self.max_ammo

    -- Attacks
    self.shoot_timer = 0
    self.shoot_cooldown = 0.24
    self:setAttack('Neutral')

    -- Ship visuals
    self.ship = 'Fighter'
    self.polygons = {}
    if self.ship == 'Fighter' then
        self.polygons[1] = {
            self.w, 0,
            self.w/2, -self.w/2,
            -self.w/2, -self.w/2,
            -self.w, 0,
            -self.w/2, self.w/2,
            self.w/2, self.w/2,
        }

        self.polygons[2] = {
            self.w/2, -self.w/2,
            0, -self.w,
            -self.w - self.w/2, -self.w,
            -3*self.w/4, -self.w/4,
            -self.w/2, -self.w/2,
        }

        self.polygons[3] = {
            self.w/2, self.w/2,
            -self.w/2, self.w/2,
            -3*self.w/4, self.w/4,
            -self.w - self.w/2, self.w,
            0, self.w,
        }

    elseif self.ship == 'Crusader' then
        self.polygons[1] = {
            self.w, 0,
            self.w/2, self.w/2,
            -self.w/4, self.w/2,
            -self.w/2, self.w/4,
            -self.w/2, -self.w/4,
            -self.w/4, -self.w/2,
            self.w/2, -self.w/2,
        }

        self.polygons[2] = {
            self.w/2, self.w/2,
            self.w/2, self.w,
            -self.w/2, self.w,
            -self.w, self.w/2,
            -self.w, 0,
            -self.w/2, 0,
            -self.w/2, self.w/4,
            -self.w/4, self.w/2,
        }

        self.polygons[3] = {
            self.w/2, -self.w/2,
            self.w/2, -self.w,
            -self.w/2, -self.w,
            -self.w, -self.w/2,
            -self.w, 0,
            -self.w/2, 0,
            -self.w/2, -self.w/4,
            -self.w/4, -self.w/2,
        }

    elseif self.ship == 'Rogue' then
        self.polygons[1] = {
            self.w, 0,
            0, -self.w/2,
            -self.w, 0,
            0, self.w/2,
        }

        self.polygons[2] = {
            self.w/2, -self.w/4,
            self.w/4, -3*self.w/4,
            -self.w - self.w/2, -2*self.w,
            -self.w/2, -self.w/4,
            0, -self.w/2,
        }

        self.polygons[3] = {
            self.w/2, self.w/4,
            0, self.w/2,
            -self.w/2, self.w/4,
            -self.w - self.w/2, 2*self.w,
            self.w/4, 3*self.w/4,
        }

    elseif self.ship == 'Bit Hunter' then
        self.polygons[1] = {
            self.w, 0,
            self.w/2, -self.w/2,
            -self.w, -self.w/2,
            -self.w/2, 0,
            -self.w, self.w/2,
            self.w/2, self.w/2,
        }

    elseif self.ship == 'Sentinel' then
        self.polygons[1] = {
            self.w, 0,
            0, -self.w,
            -3*self.w/4, -3*self.w/4,
            -self.w, 0,
            -3*self.w/4, 3*self.w/4,
            0, self.w,
        }

    elseif self.ship == 'Striker' then
        self.polygons[1] = {
            self.w, 0,
            self.w/2, -self.w/2,
            -self.w/2, -self.w/2,
            -self.w, 0,
            -self.w/2, self.w/2,
            self.w/2, self.w/2,
        }

        self.polygons[2] = {
            0, self.w/2,
            -self.w/4, self.w,
            0, self.w + self.w/2,
            self.w, self.w,
            0, 2*self.w,
            -self.w/2, self.w + self.w/2,
            -self.w, 0,
            -self.w/2, self.w/2,
        }

        self.polygons[3] = {
            0, -self.w/2,
            -self.w/4, -self.w,
            0, -self.w - self.w/2,
            self.w, -self.w,
            0, -2*self.w,
            -self.w/2, -self.w - self.w/2,
            -self.w, 0,
            -self.w/2, -self.w/2,
        }

    elseif self.ship == 'Nuclear' then
        self.polygons[1] = {
            self.w, -self.w/4,
            self.w, self.w/4,
            self.w - self.w/4, self.w/2,
            -self.w + self.w/4, self.w/2,
            -self.w, self.w/4,
            -self.w, -self.w/4,
            -self.w + self.w/4, -self.w/2,
            self.w - self.w/4, -self.w/2,
        }

    elseif self.ship == 'Cycler' then
        self.polygons[1] = {
            self.w, 0,
            0, self.w,
            -self.w, 0,
            0, -self.w,
        }

    elseif self.ship == 'Wisp' then
        self.polygons[1] = {
            self.w, -self.w/4,
            self.w, self.w/4,
            self.w/4, self.w,
            -self.w/4, self.w,
            -self.w, self.w/4,
            -self.w, -self.w/4,
            -self.w/4, -self.w,
            self.w/4, -self.w,
        }
    end

    -- Boost trail
    self.trail_color = skill_point_color 
    self.timer:every(0.01, function() 
        if self.ship == 'Fighter' then
            self.area:addGameObject('TrailParticle', 
            self.x - 1.0*self.w*math.cos(self.r) + 0.2*self.w*math.cos(self.r - math.pi/2), 
            self.y - 1.0*self.w*math.sin(self.r) + 0.2*self.w*math.sin(self.r - math.pi/2), 
            {parent = self, r = random(2, 4), d = random(0.15, 0.25), color = self.trail_color}) 
            self.area:addGameObject('TrailParticle', 
            self.x - 1.0*self.w*math.cos(self.r) + 0.2*self.w*math.cos(self.r + math.pi/2), 
            self.y - 1.0*self.w*math.sin(self.r) + 0.2*self.w*math.sin(self.r + math.pi/2), 
            {parent = self, r = random(2, 4), d = random(0.15, 0.25), color = self.trail_color}) 

        elseif self.ship == 'Crusader' then
            self.area:addGameObject('TrailParticle', 
            self.x - 1.2*self.w*math.cos(self.r) + 0.2*self.w*math.cos(self.r - math.pi/2), 
            self.y - 1.2*self.w*math.sin(self.r) + 0.2*self.w*math.sin(self.r - math.pi/2), 
            {parent = self, r = random(2, 4), d = random(0.15, 0.25), color = self.trail_color}) 
            self.area:addGameObject('TrailParticle', 
            self.x - 1.2*self.w*math.cos(self.r) + 0.2*self.w*math.cos(self.r + math.pi/2), 
            self.y - 1.2*self.w*math.sin(self.r) + 0.2*self.w*math.sin(self.r + math.pi/2), 
            {parent = self, r = random(2, 4), d = random(0.15, 0.25), color = self.trail_color}) 

        elseif self.ship == 'Bit Hunter' then
            self.area:addGameObject('TrailParticle', 
            self.x - 0.8*self.w*math.cos(self.r), self.y - 0.8*self.w*math.sin(self.r), 
            {parent = self, r = random(2, 4), d = random(0.1, 0.2), color = self.trail_color}) 

        elseif self.ship == 'Rogue' then
            self.area:addGameObject('TrailParticle', 
            self.x - 0.7*self.w*math.cos(self.r) + 0.4*self.w*math.cos(self.r - math.pi/2), 
            self.y - 0.7*self.w*math.sin(self.r) + 0.4*self.w*math.sin(self.r - math.pi/2), 
            {parent = self, r = random(2, 4), d = random(0.15, 0.25), color = self.trail_color}) 
            self.area:addGameObject('TrailParticle', 
            self.x - 0.7*self.w*math.cos(self.r) + 0.4*self.w*math.cos(self.r + math.pi/2), 
            self.y - 0.7*self.w*math.sin(self.r) + 0.4*self.w*math.sin(self.r + math.pi/2), 
            {parent = self, r = random(2, 4), d = random(0.15, 0.25), color = self.trail_color}) 

        elseif self.ship == 'Sentinel' then
            self.area:addGameObject('TrailParticle', 
            self.x - 1.0*self.w*math.cos(self.r) + 0.2*self.w*math.cos(self.r - math.pi/2), 
            self.y - 1.0*self.w*math.sin(self.r) + 0.2*self.w*math.sin(self.r - math.pi/2), 
            {parent = self, r = random(2, 4), d = random(0.15, 0.25), color = self.trail_color}) 
            self.area:addGameObject('TrailParticle', 
            self.x - 1.0*self.w*math.cos(self.r) + 0.2*self.w*math.cos(self.r + math.pi/2), 
            self.y - 1.0*self.w*math.sin(self.r) + 0.2*self.w*math.sin(self.r + math.pi/2), 
            {parent = self, r = random(2, 4), d = random(0.15, 0.25), color = self.trail_color}) 

        elseif self.ship == 'Striker' then
            self.area:addGameObject('TrailParticle', 
            self.x - 1.0*self.w*math.cos(self.r) + 0.2*self.w*math.cos(self.r - math.pi/2), 
            self.y - 1.0*self.w*math.sin(self.r) + 0.2*self.w*math.sin(self.r - math.pi/2), 
            {parent = self, r = random(2, 4), d = random(0.15, 0.25), color = self.trail_color}) 
            self.area:addGameObject('TrailParticle', 
            self.x - 1.0*self.w*math.cos(self.r) + 0.2*self.w*math.cos(self.r + math.pi/2), 
            self.y - 1.0*self.w*math.sin(self.r) + 0.2*self.w*math.sin(self.r + math.pi/2), 
            {parent = self, r = random(2, 4), d = random(0.15, 0.25), color = self.trail_color}) 

        elseif self.ship == 'Nuclear' then
            self.area:addGameObject('TrailParticle', 
            self.x - 1*self.w*math.cos(self.r), self.y - 1*self.w*math.sin(self.r), 
            {parent = self, r = random(2, 4), d = random(0.1, 0.2), color = self.trail_color}) 

        elseif self.ship == 'Cycler' then
            self.area:addGameObject('TrailParticle', 
            self.x - 1*self.w*math.cos(self.r), self.y - 1*self.w*math.sin(self.r), 
            {parent = self, r = random(2, 4), d = random(0.1, 0.2), color = self.trail_color}) 

            self.area:addGameObject('TrailParticle', 
            self.x - 0.8*self.w*math.cos(self.r) + 0.2*self.w*math.cos(self.r - math.pi/2), 
            self.y - 0.8*self.w*math.sin(self.r) + 0.2*self.w*math.sin(self.r - math.pi/2), 
            {parent = self, r = random(2, 4), d = random(0.15, 0.25), color = self.trail_color}) 

            self.area:addGameObject('TrailParticle', 
            self.x - 0.8*self.w*math.cos(self.r) + 0.2*self.w*math.cos(self.r + math.pi/2), 
            self.y - 0.8*self.w*math.sin(self.r) + 0.2*self.w*math.sin(self.r + math.pi/2), 
            {parent = self, r = random(2, 4), d = random(0.15, 0.25), color = self.trail_color}) 

        elseif self.ship == 'Wisp' then
            self.area:addGameObject('TrailParticle', 
            self.x - 1*self.w*math.cos(self.r), self.y - 1*self.w*math.sin(self.r), 
            {parent = self, r = random(2, 4), d = random(0.1, 0.15), color = self.trail_color}) 
        end
    end)

    -- ES
    self.energy_shield_recharge_cooldown = 2
    self.energy_shield_recharge_amount = 1

    -- Flats
    self.flat_hp = 0
    self.ammo_gain = 0

    -- Multipliers
    self.hp_multiplier = 1
    self.aspd_multiplier = Stat(1)
    self.luck_multiplier = 1
    self.hp_spawn_chance_multiplier = 1
    self.enemy_spawn_rate_multiplier = 1

    -- Chances
    self.launch_homing_projectile_on_ammo_pickup_chance = 0
    self.spawn_sp_on_cycle_chance = 0
    self.barrage_on_kill_chance = 0 
    self.gain_aspd_boost_on_kill_chance = 0
    self.launch_homing_projectile_while_boosting_chance = 0
    self.shield_projectile_chance = 0
    self.added_chance_to_all_on_kill_events = 0

    -- Booleans
    self.increased_luck_while_boosting = false
    self.projectile_ninety_degree_change = false
    self.wavy_projectiles = false
    self.fast_slow = false
    self.slow_fast = false
    self.energy_shield = false

    -- Conversions
    self.ammo_to_aspd = 0

    -- treeToPlayer(self)
    self:setStats()
    self:generateChances()
end

function Player:setStats()
    -- HP
    self.max_hp = (self.max_hp + self.flat_hp)*self.hp_multiplier
    self.hp = self.max_hp

    if self.energy_shield then
        self.invulnerability_time_multiplier = self.invulnerability_time_multiplier/2
    end
end

function Player:generateChances()
	self.chances = {}
  	for k, v in pairs(self) do
    	if k:find('_chance') and type(v) == 'number' then
            if k:find('_on_kill') and v > 0 then
                self.chances[k] = chanceList({true, math.ceil(v+self.added_chance_to_all_on_kill_events)}, {false, 100-math.ceil(v+self.added_chance_to_all_on_kill_events)})
            else
                self.chances[k] = chanceList({true, math.ceil(v)}, {false, 100-math.ceil(v)})
            end
      	end
    end
end

function Player:update(dt)
    Player.super.update(self, dt)
    
    -- Stat boosts
    if self.inside_haste_area then self.aspd_multiplier:increase(100) end
    if self.aspd_boosting then self.aspd_multiplier:increase(100) end

    -- Conversions
    if self.ammo_to_aspd > 0 then self.aspd_multiplier:increase((self.ammo_to_aspd/100)*(self.max_ammo - 100)) end

    self.aspd_multiplier:update(dt)
    

    -- Collision
    if self.x < 0 then self:die() end
    if self.y < 0 then self:die() end
    if self.x > gw then self:die() end
    if self.y > gh then self:die() end

    if self.collider:enter('Collectable') then
        local collision_data = self.collider:getEnterCollisionData('Collectable')
        local object = collision_data.collider:getObject()

        if object:is(Ammo) then
            object:die()
            self:addAmmo(5)
            self:onAmmoPickup()

        elseif object:is(Boost) then
            object:die()

        elseif object:is(SkillPoint) then
            object:die()

        elseif object:is(Attack) then
            object:die()
            self:setAttack(object.attack)
        end
    end

    if self.collider:enter('Enemy') then
        local collision_data = self.collider:getEnterCollisionData('Enemy')
        local object = collision_data.collider:getObject()

        if object then 
            self:hit(30) 
        end
    end

    -- Cycle
    self.cycle_timer = self.cycle_timer + dt
    if self.cycle_timer > self.cycle_cooldown then
        self.cycle_timer = 0
        self:cycle()
    end

    -- Boost
    self.boost = math.min(self.boost + 10*dt, self.max_boost)
    self.boost_timer = self.boost_timer + dt
    if self.boost_timer > self.boost_cooldown then self.can_boost = true end
    self.max_v = self.base_max_v
    self.boosting = false
    if input:pressed('up') and self.boost > 1 and self.can_boost then self:onBoostStart() end
    if input:released('up') then self:onBoostEnd() end
    if input:down('up') and self.boost > 1 and self.can_boost then 
        self.boosting = true
        self.max_v = 1.5*self.base_max_v 
        self.boost = self.boost - 50*dt
        if self.boost <= 1 then
            self.boosting = false
            self.can_boost = false
            self.boost_timer = 0
            self:onBoostEnd()
        end
    end
    if input:pressed('down') and self.boost > 1 and self.can_boost then self:onBoostStart() end
    if input:released('down') then self:onBoostEnd() end
    if input:down('down') and self.boost > 1 and self.can_boost then 
        self.boosting = true
        self.max_v = 0.5*self.base_max_v 
        self.boost = self.boost - 50*dt
        if self.boost <= 1 then
            self.boosting = false
            self.can_boost = false
            self.boost_timer = 0
            self:onBoostEnd()
        end
    end
    self.trail_color = skill_point_color 
    if self.boosting then self.trail_color = boost_color end

    -- Shoot
    self.shoot_timer = self.shoot_timer + dt
    if self.shoot_timer > self.shoot_cooldown/self.aspd_multiplier.value then
        self.shoot_timer = 0
        self:shoot()
    end

    -- Movement
    if input:down('left') then self.r = self.r - self.rv*dt end
    if input:down('right') then self.r = self.r + self.rv*dt end
    self.v = math.min(self.v + self.a*dt, self.max_v)
    self.collider:setLinearVelocity(self.v*math.cos(self.r), self.v*math.sin(self.r))
end

function Player:draw()
    if self.invisible then return end

    pushRotate(self.x, self.y, self.r)
    love.graphics.setColor(default_color)
    for _, vertice_group in ipairs(self.polygons) do
        local points = fn.map(vertice_group, function(k, v) if k % 2 == 1 then return self.x + v + random(-1, 1) else return self.y + v + random(-1, 1) end end)
        love.graphics.polygon('line', points)
    end
    love.graphics.pop()
end

function Player:destroy()
    Player.super.destroy(self)
end

function Player:cycle()
    self.area:addGameObject('CycleEffect', self.x, self.y, {parent = self})
    self:onCycle()
end

function Player:shoot()
    local d = 1.2*self.w
    self.area:addGameObject('ShootEffect', self.x + d*math.cos(self.r), self.y + d*math.sin(self.r), {player = self, d = d})

    local mods = {
        shield = self.chances.shield_projectile_chance:next()
    }

    if self.attack == 'Neutral' then
        self.area:addGameObject('Projectile', self.x + 1.5*d*math.cos(self.r), self.y + 1.5*d*math.sin(self.r), table.merge({r = self.r, attack = self.attack}, mods))

    elseif self.attack == 'Double' then
        self.ammo = self.ammo - attacks[self.attack].ammo
        self.area:addGameObject('Projectile', self.x + 1.5*d*math.cos(self.r + math.pi/12), self.y + 1.5*d*math.sin(self.r + math.pi/12), table.merge({r = self.r + math.pi/12, attack = self.attack}, mods))
        self.area:addGameObject('Projectile', self.x + 1.5*d*math.cos(self.r - math.pi/12), self.y + 1.5*d*math.sin(self.r - math.pi/12), table.merge({r = self.r - math.pi/12, attack = self.attack}, mods))

    elseif self.attack == 'Triple' then
        self.ammo = self.ammo - attacks[self.attack].ammo
        self.area:addGameObject('Projectile', self.x + 1.5*d*math.cos(self.r), self.y + 1.5*d*math.sin(self.r), table.merge({r = self.r, attack = self.attack}, mods))
        self.area:addGameObject('Projectile', self.x + 1.5*d*math.cos(self.r + math.pi/12), self.y + 1.5*d*math.sin(self.r + math.pi/12), table.merge({r = self.r + math.pi/12, attack = self.attack}, mods))
        self.area:addGameObject('Projectile', self.x + 1.5*d*math.cos(self.r - math.pi/12), self.y + 1.5*d*math.sin(self.r - math.pi/12), table.merge({r = self.r - math.pi/12, attack = self.attack}, mods))

    elseif self.attack == 'Rapid' then
        self.ammo = self.ammo - attacks[self.attack].ammo
        self.area:addGameObject('Projectile', self.x + 1.5*d*math.cos(self.r), self.y + 1.5*d*math.sin(self.r), table.merge({r = self.r, attack = self.attack}, mods))

    elseif self.attack == 'Spread' then
        self.ammo = self.ammo - attacks[self.attack].ammo
        local random_angle = random(-math.pi/8, math.pi/8)
        self.area:addGameObject('Projectile', self.x + 1.5*d*math.cos(self.r + random_angle), self.y + 1.5*d*math.sin(self.r + random_angle), 
            table.merge({r = self.r + random_angle, attack = self.attack}, mods))

    elseif self.attack == 'Back' then
        self.ammo = self.ammo - attacks[self.attack].ammo
        self.area:addGameObject('Projectile', self.x + 1.5*d*math.cos(self.r), self.y + 1.5*d*math.sin(self.r), table.merge({r = self.r, attack = self.attack}, mods))
        self.area:addGameObject('Projectile', self.x + 1.5*d*math.cos(self.r - math.pi), self.y + 1.5*d*math.sin(self.r - math.pi), table.merge({r = self.r - math.pi, attack = self.attack}, mods))

    elseif self.attack == 'Side' then
        self.ammo = self.ammo - attacks[self.attack].ammo
        self.area:addGameObject('Projectile', self.x + 1.5*d*math.cos(self.r), self.y + 1.5*d*math.sin(self.r), table.merge({r = self.r, attack = self.attack}, mods))
        self.area:addGameObject('Projectile', self.x + 1.5*d*math.cos(self.r - math.pi/2), self.y + 1.5*d*math.sin(self.r - math.pi/2), table.merge({r = self.r - math.pi/2, attack = self.attack}, mods))
        self.area:addGameObject('Projectile', self.x + 1.5*d*math.cos(self.r + math.pi/2), self.y + 1.5*d*math.sin(self.r + math.pi/2), table.merge({r = self.r + math.pi/2, attack = self.attack}, mods))

    elseif self.attack == 'Homing' then
        self.ammo = self.ammo - attacks[self.attack].ammo
        self.area:addGameObject('Projectile', self.x + 1.5*d*math.cos(self.r), self.y + 1.5*d*math.sin(self.r), table.merge({r = self.r, attack = self.attack}, mods))

    elseif self.attack == 'Blast' then
        self.ammo = self.ammo - attacks[self.attack].ammo
        for i = 1, 12 do
            local random_angle = random(-math.pi/6, math.pi/6)
            self.area:addGameObject('Projectile', self.x + 1.5*d*math.cos(self.r + random_angle), self.y + 1.5*d*math.sin(self.r + random_angle), 
                table.merge({r = self.r + random_angle, attack = self.attack, v = random(500, 600)}, mods))
        end
        camera:shake(4, 60, 0.4)

    elseif self.attack == 'Spin' then
        self.ammo = self.ammo - attacks[self.attack].ammo
        self.area:addGameObject('Projectile', self.x + 1.5*d*math.cos(self.r), self.y + 1.5*d*math.sin(self.r), table.merge({r = self.r, attack = self.attack}, mods))

    elseif self.attack == 'Bounce' then
        self.ammo = self.ammo - attacks[self.attack].ammo
        self.area:addGameObject('Projectile', self.x + 1.5*d*math.cos(self.r), self.y + 1.5*d*math.sin(self.r), table.merge({r = self.r, attack = self.attack, bounce = 4}, mods))

    elseif self.attack == 'Lightning' then
        local x1, y1 = self.x + d*math.cos(self.r), self.y + d*math.sin(self.r)
        local cx, cy = x1 + 24*math.cos(self.r), y1 + 24*math.sin(self.r)

        -- Find closest enemy
        local nearby_enemies = self.area:getAllGameObjectsThat(function(e)
            for _, enemy in ipairs(enemies) do
                if e:is(_G[enemy]) and (distance(e.x, e.y, cx, cy) < 64) then
                    return true
                end
            end
        end)
        table.sort(nearby_enemies, function(a, b) return distance(a.x, a.y, cx, cy) < distance(b.x, b.y, cx, cy) end)
        local closest_enemy = nearby_enemies[1]

        -- Attack closest enemy
        if closest_enemy then
            self.ammo = self.ammo - attacks[self.attack].ammo
            closest_enemy:hit()
            local x2, y2 = closest_enemy.x, closest_enemy.y
            self.area:addGameObject('LightningLine', 0, 0, {x1 = x1, y1 = y1, x2 = x2, y2 = y2})
            for i = 1, love.math.random(4, 8) do self.area:addGameObject('ExplodeParticle', x1, y1, {color = table.random({default_color, boost_color})}) end
            for i = 1, love.math.random(4, 8) do self.area:addGameObject('ExplodeParticle', x2, y2, {color = table.random({default_color, boost_color})}) end
        end
    end

    if self.ammo <= 0 then 
        self:setAttack('Neutral')
        self.ammo = self.max_ammo
    end
end

function Player:setAttack(attack)
    self.attack = attack
    self.shoot_cooldown = attacks[attack].cooldown
    self.ammo = self.max_ammo
end

function Player:hit(damage)
    if self.invincible then return end
    damage = damage or 10

    if self.energy_shield then
        damage = damage*2
        self.timer:after('energy_shield_recharge_cooldown', self.energy_shield_recharge_cooldown, function()
            self.timer:every('energy_shield_recharge_amount', 0.25, function()
                self:addHP(self.energy_shield_recharge_amount)
            end)
        end)
    end

    for i = 1, love.math.random(4, 8) do self.area:addGameObject('ExplodeParticle', self.x, self.y) end
    self:removeHP(damage)

    if damage >= 30 then
        self.invincible = true
        self.timer:after('invincibility', 2, function() self.invincible = false end)
        for i = 1, 50 do self.timer:after((i-1)*0.04, function() self.invisible = not self.invisible end) end
        self.timer:after(51*0.04, function() self.invisible = false end)

        camera:shake(6, 60, 0.2)
        flash(3)
        slow(0.25, 0.5)
    else
        camera:shake(3, 60, 0.1)
        flash(2)
        slow(0.75, 0.25)
    end
end

function Player:die()
    self.dead = true 
    flash(4)
    camera:shake(6, 60, 0.4)
    slow(0.15, 1)
    for i = 1, love.math.random(8, 12) do self.area:addGameObject('ExplodeParticle', self.x, self.y) end

    current_room:finish()
end

function Player:addAmmo(amount)
    self.ammo = math.min(self.ammo + amount + self.ammo_gain, self.max_ammo)
    current_room.score = current_room.score + 50
end

function Player:addHP(amount)
    self.hp = math.min(self.hp + amount, self.max_hp)
end

function Player:removeHP(amount)
    self.hp = self.hp - (amount or 5)
    if self.hp <= 0 then
        self.hp = 0
        self:die()
    end
end

function Player:onAmmoPickup()
    if self.chances.launch_homing_projectile_on_ammo_pickup_chance:next() then
        local d = 1.2*self.w
        self.area:addGameObject('Projectile', self.x + d*math.cos(self.r), self.y + d*math.sin(self.r), {r = self.r, attack = 'Homing'})
        self.area:addGameObject('InfoText', self.x, self.y, {text = 'Homing Projectile!'})
    end
end

function Player:onCycle()
    if self.chances.spawn_sp_on_cycle_chance:next() then
        self.area:addGameObject('SkillPoint')
        self.area:addGameObject('InfoText', self.x, self.y, {text = 'SP Spawn!', color = skill_point_color})
    end
end

function Player:onKill()
    if self.chances.barrage_on_kill_chance:next() then
        for i = 1, 8 do
            self.timer:after((i-1)*0.05, function()
                local random_angle = random(-math.pi/8, math.pi/8)
                local d = 2.2*self.w
                self.area:addGameObject('Projectile', self.x + d*math.cos(self.r + random_angle), self.y + d*math.sin(self.r + random_angle), {r = self.r + random_angle, attack = self.attack})
            end)
        end
        self.area:addGameObject('InfoText', self.x, self.y, {text = 'Barrage!!!'})
    end

    if self.chances.gain_aspd_boost_on_kill_chance:next() then
        self.aspd_boosting = true
        self.timer:after(4, function() self.aspd_boosting = false end)
        self.area:addGameObject('InfoText', self.x, self.y, {text = 'ASPD Boost!', color = ammo_color})
    end
end

function Player:onBoostStart()
    self.timer:every('launch_homing_projectile_while_boosting_chance', 0.2, function()
        if self.chances.launch_homing_projectile_while_boosting_chance:next() then
            local d = 1.2*self.w
            self.area:addGameObject('Projectile', self.x + d*math.cos(self.r), self.y + d*math.sin(self.r), {r = self.r, attack = 'Homing'})
            self.area:addGameObject('InfoText', self.x, self.y, {text = 'Homing Projectile!'})
        end
    end)

    if self.increased_luck_while_boosting then 
        self.luck_boosting = true 
        self.luck_multiplier = self.luck_multiplier*2
        self:generateChances()
    end
end

function Player:onBoostEnd()
    self.timer:cancel('launch_homing_projectile_while_boosting_chance')

    if self.increased_luck_while_boosting then 
        self.luck_boosting = false 
        self.luck_multiplier = self.luck_multiplier/2
        self:generateChances()
    end
end
