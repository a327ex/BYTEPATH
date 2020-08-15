Glitcher = GameObject:extend()

function Glitcher:new(area, x, y, opts)
    Glitcher.super.new(self, area, x, y, opts)

    self.graphics_types = {'rgb_shift'}

    self.direction = opts.direction or table.random({-1, 1})
    self.x = opts.x or (gw/2 + self.direction*(gw/2 + 48))
    self.y = opts.y or (random(16, gh - 16))

    self.w, self.h = 24, 24 
    self.shape = HC.polygon(self.w, -self.h, self.w, self.h, -self.w, self.h, -self.w, -self.h)
    self.shape:moveTo(self.x, self.y)
    self.shape.id = self.id
    self.shape.object = self
    self.shape.tag = 'Enemy'

    self.v = -self.direction*random(10, 20)
    self.vx = self.v

    self.max_hp = 1500*current_room.director.enemy_hp_multiplier
    self.hp = 1500*current_room.director.enemy_hp_multiplier

    self.timer:every(random(4, 6), function()
        self.timer:every(0.05, function()
            local x, y = 0, 0
            local direction = table.random({'left', 'right', 'up', 'down'})
            if direction == 'left' then x, y = self.x - self.w - 8, random(self.y - self.h/2, self.y + self.h/2)
            elseif direction == 'right' then x, y = self.x + self.w + 8, random(self.y - self.h/2, self.y + self.h/2)
            elseif direction == 'up' then x, y = random(self.x - self.w/2, self.x + self.w/2), self.y - self.h - 8
            elseif direction == 'down' then x, y = random(self.x - self.w/2, self.y + self.w/2), self.y + self.h + 8 end
            local angle = (direction == 'left' and math.pi) or (direction == 'right' and 0) or (direction == 'up' and -math.pi/2) or (direction == 'down' and math.pi/2)
            self.area:addGameObject('EnemyProjectile', x, y, {r = angle, projectile_ninety_degree_change = true})
            self.area:addGameObject('GlitcherShootEffect', x, y, {dx = x - self.x, dy = y - self.y, parent = self})
        end, 20)
    end)
end

function Glitcher:update(dt)
    Glitcher.super.update(self, dt)

    self:enemyProjectileCollisions()

    self.shape:move(self.vx*dt, 0)
    self.x, self.y = self.shape:center()
end

function Glitcher:draw()
    love.graphics.setColor(hp_color)
    if self.hit_flash then love.graphics.setColor(default_color) end
    love.graphics.rectangle('fill', self.x - self.w, self.y - self.h + (2*self.h - 2*self.h*(self.hp/self.max_hp)), 2*self.w, 2*self.h*(self.hp/self.max_hp))
    self.shape:draw('line')
    love.graphics.setColor(default_color)
end

function Glitcher:hit(damage)
    if self.dead then return end

    self.hp = self.hp - (damage or 100)
    if self.hp <= 0 then
        playGameEnemyDie()
        current_room.score = current_room.score + 100
        self.dead = true
        if not current_room.player.no_ammo_drop then self.area:addGameObject('Ammo', self.x, self.y) end
        self.area:addGameObject('EnemyDeathEffect', self.x, self.y, {color = hp_color, w = 3*self.w})
        current_room.player:removeSapper(self.id)
    else
        self.hit_flash = true
        self.timer:after('hit_flash', 0.2, function() self.hit_flash = false end)
    end
end
