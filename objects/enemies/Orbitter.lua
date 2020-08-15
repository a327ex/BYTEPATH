Orbitter = GameObject:extend()

function Orbitter:new(area, x, y, opts)
    Orbitter.super.new(self, area, x, y, opts)

    local direction = opts.direction or table.random({-1, 1})
    self.x = gw/2 + direction*(gw/2 + 64)
    self.y = random(16, gh - 16)

    self.w, self.h = 12, 12
    self.shape = HC.polygon(unpack(createIrregularPolygon(12)))
    self.shape:moveTo(self.x, self.y)
    self.shape.id = self.id
    self.shape.object = self
    self.shape.tag = 'Enemy'

    self.v = -direction*random(20, 40)
    self.vx = self.v
    self.dr = random(-10, 10)

    self.hp = 500*current_room.director.enemy_hp_multiplier

    self.projectiles = {}
    self.timer:after(0.5, function()
        if self.projectiles then
            for i = 1, love.math.random(4, 8) do
                table.insert(self.projectiles, self.area:addGameObject('EnemyProjectile', self.x - direction*40, self.y, {orbitter = self, shield = true, r = random(0, 2*math.pi), hp = 2}))
            end
        end
    end)
end

function Orbitter:update(dt)
    Orbitter.super.update(self, dt)

    self:enemyProjectileCollisions()

    self.shape:move(self.vx*dt, 0)
    self.shape:rotate(self.dr*dt)
    self.x, self.y = self.shape:center()
end

function Orbitter:draw()
    love.graphics.setColor(hp_color)
    if self.hit_flash then love.graphics.setColor(default_color) end
    self.shape:draw('line')
    love.graphics.setColor(default_color)
end

function Orbitter:destroy()
    Orbitter.super.destroy(self)
end

function Orbitter:hit(damage)
    if self.dead then return end

    self.hp = self.hp - (damage or 100)
    if self.hp <= 0 then
        playGameEnemyDie()
        current_room.score = current_room.score + 500
        self.dead = true
        if not current_room.player.no_ammo_drop then self.area:addGameObject('Ammo', self.x, self.y) end
        self.area:addGameObject('EnemyDeathEffect', self.x, self.y, {color = hp_color, w = 3*self.w})

        for _, projectile in ipairs(self.projectiles) do projectile:setHoming() end
        self.projectiles = nil
    else
        self.hit_flash = true
        self.timer:after('hit_flash', 0.2, function() self.hit_flash = false end)
    end
end
